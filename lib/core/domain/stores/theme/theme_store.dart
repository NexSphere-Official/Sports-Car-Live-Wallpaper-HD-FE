import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/app_theme_mode.dart';
import 'theme_state.dart';

class ThemeStore extends Cubit<ThemeStoreState> {
  ThemeStore() : super(const ThemeStoreState(mode: AppThemeMode.system));

  AppThemeMode get mode => state.mode;

  void setMode(AppThemeMode mode) => emit(state.copyWith(mode: mode));
}
