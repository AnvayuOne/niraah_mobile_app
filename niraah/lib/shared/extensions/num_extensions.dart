extension NumExtensions on num {
  Duration get milliseconds => Duration(milliseconds: round());
  Duration get seconds => Duration(seconds: round());
}
