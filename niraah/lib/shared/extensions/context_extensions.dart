import 'package:flutter/material.dart';

import '../../design_system/theme/theme_extensions.dart';

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;
  AppSemantics? get semantics => theme.extension<AppSemantics>();
}
