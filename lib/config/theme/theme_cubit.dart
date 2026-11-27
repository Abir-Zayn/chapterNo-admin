// Cubit managing Light and Dark ThemeMode across the ChapterNo Admin UI.
// Defaults to ThemeMode.light and provides toggle/setMode actions.
import 'imports/theme_cubit_imports.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit([super.initialMode = ThemeMode.light]);

  void toggle() {
    emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setMode(ThemeMode mode) => emit(mode);
}
