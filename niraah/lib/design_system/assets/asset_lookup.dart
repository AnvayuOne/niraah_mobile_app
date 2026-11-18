import '../generated/niraah_assets.dart';

/// Resolves an asset id used in content documents (for example a question's
/// `illustration: "q01_age"`) to its generated asset.
///
/// Content from the API names images by id, so the app needs this lookup.
/// It only lists ids that content may refer to. Unknown ids return null and
/// the screen renders without the image rather than failing.
abstract final class NAssetLookup {
  static const Map<String, NImageAsset> _byId = <String, NImageAsset>{
    'q01_age': NImages.q01Age,
    'q02_cycle': NImages.q02Cycle,
    'q03_mood': NImages.q03Mood,
    'q04_symptoms': NImages.q04Symptoms,
    'q05_diet': NImages.q05Diet,
    'q06_activity': NImages.q06Activity,
    'q07_stress': NImages.q07Stress,
    'q08_sleep': NImages.q08Sleep,
    'q09_goal': NImages.q09Goal,
    'q10_support': NImages.q10Support,
    'screen02_mood_energetic': NImages.screen02MoodEnergetic,
    'screen02_mood_anxious': NImages.screen02MoodAnxious,
    'screen02_mood_fatigue': NImages.screen02MoodFatigue,
    'screen02_mood_hormonal': NImages.screen02MoodHormonal,
    'program-pcos': NImages.programPcos,
    'program-fertility': NImages.programFertility,
    'program-metabolic': NImages.programMetabolic,
    'program-pregnancy': NImages.programPregnancy,
  };

  static NImageAsset? image(String? id) => id == null ? null : _byId[id];
}
