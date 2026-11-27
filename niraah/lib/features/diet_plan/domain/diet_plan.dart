/// AI diet plan (spec 009 "AI diet plan"; spec 010 §6a). Values come from the server; nutrients are
/// computed there from the food table, never by a model.
library;

class FoodProfile {
  const FoodProfile({required this.foodChoice, required this.allergens, required this.noAllergies, required this.avoidedFoodIds, required this.cuisine, required this.fastingDays});

  factory FoodProfile.fromJson(Map<String, dynamic> j) => FoodProfile(
    foodChoice: j['foodChoice'] as String,
    allergens: (j['allergens'] as List<dynamic>).cast<String>(),
    noAllergies: j['noAllergies'] as bool,
    avoidedFoodIds: (j['avoidedFoodIds'] as List<dynamic>).cast<String>(),
    cuisine: j['cuisine'] as String,
    fastingDays: (j['fastingDays'] as List<dynamic>).map((dynamic d) => (d as num).toInt()).toList(),
  );

  final String foodChoice;
  final List<String> allergens;
  final bool noAllergies;
  final List<String> avoidedFoodIds;
  final String cuisine;

  /// 0 = Sunday … 6 = Saturday.
  final List<int> fastingDays;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'foodChoice': foodChoice,
    'allergens': allergens,
    'noAllergies': noAllergies,
    'avoidedFoodIds': avoidedFoodIds,
    'cuisine': cuisine,
    'fastingDays': fastingDays,
  };

  static const List<String> foodChoices = <String>['vegetarian', 'eggetarian', 'non_vegetarian', 'vegan', 'jain'];
  static const List<String> allAllergens = <String>['peanut', 'tree_nut', 'gluten', 'milk', 'egg', 'soy', 'sesame', 'mustard', 'fish', 'shellfish'];
  static const List<String> cuisines = <String>['pan_indian', 'north_indian', 'south_indian', 'east_indian', 'west_indian'];
}

class DietNutrients {
  const DietNutrients({required this.energyKcal, required this.proteinG, required this.carbohydrateG, required this.fatG, required this.fibreG});

  factory DietNutrients.fromJson(Map<String, dynamic> j) => DietNutrients(
    energyKcal: (j['energyKcal'] as num?)?.toDouble(),
    proteinG: (j['proteinG'] as num).toDouble(),
    carbohydrateG: (j['carbohydrateG'] as num).toDouble(),
    fatG: (j['fatG'] as num).toDouble(),
    fibreG: (j['fibreG'] as num).toDouble(),
  );

  final double? energyKcal;
  final double proteinG;
  final double carbohydrateG;
  final double fatG;
  final double fibreG;
}

class DietOption {
  const DietOption(this.id, this.name);
  final String id;
  final String name;
}

class DietItem {
  const DietItem({required this.id, required this.food, required this.count, required this.unit, required this.nutrients, required this.swaps});

  factory DietItem.fromJson(Map<String, dynamic> j) {
    final Map<String, dynamic> food = j['food'] as Map<String, dynamic>;
    final Map<String, dynamic> portion = j['portion'] as Map<String, dynamic>;
    return DietItem(
      id: j['id'] as String,
      food: DietOption(food['id'] as String, food['name'] as String),
      count: (portion['count'] as num).toDouble(),
      unit: portion['unit'] as String,
      nutrients: DietNutrients.fromJson(j['nutrients'] as Map<String, dynamic>),
      swaps: <DietOption>[for (final dynamic s in j['swaps'] as List<dynamic>) DietOption((s as Map<String, dynamic>)['id'] as String, s['name'] as String)],
    );
  }

  final String id;
  final DietOption food;
  final double count;
  final String unit;
  final DietNutrients nutrients;
  final List<DietOption> swaps;
}

class DietMeal {
  const DietMeal({required this.slot, required this.reason, required this.items, required this.totals});

  factory DietMeal.fromJson(Map<String, dynamic> j) => DietMeal(
    slot: j['slot'] as String,
    reason: j['reason'] as String?,
    items: <DietItem>[for (final dynamic i in j['items'] as List<dynamic>) DietItem.fromJson(i as Map<String, dynamic>)],
    totals: DietNutrients.fromJson(j['totals'] as Map<String, dynamic>),
  );

  final String slot;
  final String? reason;
  final List<DietItem> items;
  final DietNutrients totals;
}

class DietDay {
  const DietDay({required this.day, required this.date, required this.meals, required this.totals});

  factory DietDay.fromJson(Map<String, dynamic> j) => DietDay(
    day: (j['day'] as num).toInt(),
    date: DateTime.parse(j['date'] as String),
    meals: <DietMeal>[for (final dynamic m in j['meals'] as List<dynamic>) DietMeal.fromJson(m as Map<String, dynamic>)],
    totals: DietNutrients.fromJson(j['totals'] as Map<String, dynamic>),
  );

  final int day;
  final DateTime date;
  final List<DietMeal> meals;
  final DietNutrients totals;
}

/// What the plan screen shows (the server's `status`).
sealed class DietPlanState {
  const DietPlanState();

  factory DietPlanState.fromJson(Map<String, dynamic> j) => switch (j['status']) {
    'locked' => DietLocked((j['plans'] as List<dynamic>).cast<String>()),
    'needs_dietitian' => DietNeedsDietitian(j['message'] as String),
    'dietitian_plan' => const DietDietitianPlan(),
    'needs_profile' => const DietNeedsProfile(),
    'ready' => DietReady(
      madeByModel: j['madeBy'] == 'model',
      cautions: (j['cautions'] as List<dynamic>).cast<String>(),
      shortCaution: j['shortCaution'] as String,
      starterDataNote: j['starterDataNote'] as String?,
      caloriesHidden: j['caloriesHidden'] as bool,
      canMakeNewWeek: j['canMakeNewWeek'] as bool,
      days: <DietDay>[for (final dynamic d in j['days'] as List<dynamic>) DietDay.fromJson(d as Map<String, dynamic>)],
    ),
    _ => DietUnavailable((j['message'] as String?) ?? ''),
  };
}

class DietLocked extends DietPlanState {
  const DietLocked(this.plans);
  final List<String> plans;
}

class DietNeedsDietitian extends DietPlanState {
  const DietNeedsDietitian(this.message);
  final String message;
}

class DietDietitianPlan extends DietPlanState {
  const DietDietitianPlan();
}

class DietNeedsProfile extends DietPlanState {
  const DietNeedsProfile();
}

class DietUnavailable extends DietPlanState {
  const DietUnavailable(this.message);
  final String message;
}

class DietReady extends DietPlanState {
  const DietReady({
    required this.madeByModel,
    required this.cautions,
    required this.shortCaution,
    required this.starterDataNote,
    required this.caloriesHidden,
    required this.canMakeNewWeek,
    required this.days,
  });

  final bool madeByModel;
  final List<String> cautions;
  final String shortCaution;
  final String? starterDataNote;
  final bool caloriesHidden;
  final bool canMakeNewWeek;
  final List<DietDay> days;
}

abstract interface class DietPlanRepository {
  Future<DietPlanState> open();
  Future<DietPlanState> newWeek();
  Future<DietPlanState> swap(String itemId, String? foodId);
  Future<FoodProfile?> profile();
  Future<FoodProfile> saveProfile(FoodProfile profile);
  Future<List<DietOption>> foods();
}
