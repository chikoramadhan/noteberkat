import 'package:note_berkat/src/providers/main_provider.dart';

class AppProvider extends MainProvider {
  int _active = 0;

  int get active => _active;

  changePage(int page) {
    _active = page;

    notifyListeners();
  }

  clear() {
    _active = 0;
  }
}
