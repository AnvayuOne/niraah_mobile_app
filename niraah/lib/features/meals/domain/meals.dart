import 'package:equatable/equatable.dart';

/// The meal scanner and meal log as the server returns them (spec 010 §6, spec 009 "Meal scan"),
/// matching packages/contracts/src/ai.ts `MealScanResult` and member.ts `Meal`, `MealDay`, `Foods`.
/// Every nutrient figure comes from the food table on the server, never from the model (constitution §7.9).

class Nutrients extends Equatable {
  const Nutrients({this.energyKcal, required this.proteinG, required this.carbohydrateG, required this.fatG, required this.fibreG, this.glycaemicIndex});

  /// Null when calories are hidden for her (spec 010 §6 rule 7).
  final double? energyKcal;
  final double proteinG;
  final double carbohydrateG;
  final double fatG;
  final double fibreG;
  final int? glycaemicIndex;

  @override
  List<Object?> get props => <Object?>[energyKcal, proteinG, carbohydrateG, fatG, fibreG, glycaemicIndex];
}

class FoodRef extends Equatable {
  const FoodRef({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => <Object?>[id, name];
}

/// Household units the server accepts (spec 009 meal_scan prompt).
const List<String> portionUnits = <String>['katori', 'piece', 'cup', 'plate', 'glass', 'tablespoon', 'teaspoon', 'slice', 'bowl', 'serving'];

sealed class ScanItem extends Equatable {
  const ScanItem({required this.count, required this.unit});

  final double count;
  final String unit;
}

class MatchedItem extends ScanItem {
  const MatchedItem({required this.food, required super.count, required super.unit, required this.nutrients, required this.confidence});

  final FoodRef food;
  final Nutrients nutrients;
  final double confidence;

  @override
  List<Object?> get props => <Object?>[food, count, unit, nutrients, confidence];
}

/// The scan was unsure or the dish is not in the food table: she identifies it (spec 009 AC36).
class NotSureItem extends ScanItem {
  const NotSureItem({required this.label, required super.count, required super.unit});

  final String label;

  @override
  List<Object?> get props => <Object?>[label, count, unit];
}

sealed class ScanResult {
  const ScanResult();
}

class ScanOk extends ScanResult {
  const ScanOk({required this.items, required this.totals, required this.tags, required this.caloriesHidden});

  final List<ScanItem> items;
  final Nutrients totals;
  final List<String> tags;
  final bool caloriesHidden;
}

class ScanNoFood extends ScanResult {
  const ScanNoFood(this.message);
  final String message;
}

/// No model could serve it; manual logging still works (spec 009 "Meal scan", spec 010 §6 rule 3).
class ScanUnavailable extends ScanResult {
  const ScanUnavailable();
}

class ScanLimit extends ScanResult {
  const ScanLimit({required this.limit, this.refillsAt});
  final int limit;
  final String? refillsAt;
}

class FoodOption extends Equatable {
  const FoodOption({required this.id, required this.name, required this.regionalNames});

  final String id;
  final String name;
  final List<String> regionalNames;

  @override
  List<Object?> get props => <Object?>[id, name, regionalNames];
}

enum MealSlot { breakfast, lunch, dinner, snack }

class MealItemInput {
  const MealItemInput({required this.foodId, required this.count, required this.unit});

  final String foodId;
  final double count;
  final String unit;
}

class LoggedItem extends Equatable {
  const LoggedItem({required this.name, required this.grams, this.portion, required this.nutrients});

  final String name;
  final double grams;
  final String? portion;
  final Nutrients nutrients;

  @override
  List<Object?> get props => <Object?>[name, grams, portion, nutrients];
}

class Meal extends Equatable {
  const Meal({required this.id, required this.eatenAt, required this.slot, required this.source, required this.items, required this.totals, required this.tags, this.suggestion});

  final String id;
  final DateTime eatenAt;
  final MealSlot slot;
  final String source;
  final List<LoggedItem> items;
  final Nutrients totals;
  final List<String> tags;

  /// One short, kind suggestion when a model served it (spec 010 §6 rule 4).
  final String? suggestion;

  @override
  List<Object?> get props => <Object?>[id, eatenAt, slot, source, items, totals, tags, suggestion];
}

class MealDay extends Equatable {
  const MealDay({required this.date, required this.meals, required this.totals, required this.caloriesHidden, this.privacyNote});

  final String date;
  final List<Meal> meals;
  final Nutrients totals;
  final bool caloriesHidden;
  final String? privacyNote;

  @override
  List<Object?> get props => <Object?>[date, meals, totals, caloriesHidden, privacyNote];
}

abstract class MealsRepository {
  /// Sends the photo (JPEG, base64) for the AI to identify; nothing is saved (spec 010 §6 rule 2).
  Future<ScanResult> scan(String photoBase64);

  Future<List<FoodOption>> searchFoods(String query);

  /// Saves a meal she confirmed; nutrients are computed on the server from the food table.
  Future<Meal> save({required DateTime eatenAt, required MealSlot slot, required bool fromScan, required List<MealItemInput> items});

  Future<MealDay> today();

  /// Days with meals logged in the last 30 days, newest first.
  Future<List<MealHistoryDay>> history();

  /// Her active meal plan from her dietitian, or null when she has none.
  Future<MealPlan?> mealPlan();
}

/// A day with meals logged, from `GET /me/meals/history` (spec 010 §6 rule 5: "a history").
class MealHistoryDay extends Equatable {
  const MealHistoryDay({required this.day, required this.meals});

  /// `YYYY-MM-DD` in her time zone.
  final String day;
  final int meals;

  @override
  List<Object?> get props => <Object?>[day, meals];
}

/// One dish on her dietitian's meal plan, in household units, with the dietitian's note and alternatives.
class MealPlanItem extends Equatable {
  const MealPlanItem({required this.name, required this.count, required this.unit, required this.nutrients, this.notes, this.alternatives = const <String>[]});

  final String name;
  final double count;
  final String unit;
  final Nutrients nutrients;
  final String? notes;
  final List<String> alternatives;

  @override
  List<Object?> get props => <Object?>[name, count, unit, nutrients, notes, alternatives];
}

class MealPlanSlot extends Equatable {
  const MealPlanSlot({required this.slot, required this.items, required this.totals});

  /// `early_morning`, `breakfast`, `mid_morning`, `lunch`, `evening_snack`, `dinner` or `bedtime`.
  final String slot;
  final List<MealPlanItem> items;
  final Nutrients totals;

  @override
  List<Object?> get props => <Object?>[slot, items, totals];
}

class MealPlanDay extends Equatable {
  const MealPlanDay({required this.dayIndex, required this.date, required this.note, required this.slots, required this.totals});

  final int dayIndex;
  final String date;
  final String? note;
  final List<MealPlanSlot> slots;
  final Nutrients totals;

  @override
  List<Object?> get props => <Object?>[dayIndex, date, note, slots, totals];
}

/// Her active meal plan from her dietitian (spec 012 §4 "Publishing" 2, AC12; spec 010 §6 rule 5), never a draft.
/// Energy figures are absent when calorie content is suppressed for her (spec 012 AC16).
class MealPlan extends Equatable {
  const MealPlan({required this.id, required this.title, required this.startDate, required this.endDate, required this.dietitian, required this.days});

  final String id;
  final String? title;
  final String startDate;
  final String? endDate;
  final String? dietitian;
  final List<MealPlanDay> days;

  @override
  List<Object?> get props => <Object?>[id, title, startDate, endDate, dietitian, days];
}
