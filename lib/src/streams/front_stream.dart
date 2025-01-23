import 'package:rxdart/rxdart.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/resources/repository.dart';

class FrontProvider {
  final _fetcher = PublishSubject<UserModel?>();
  final repository = Repository();

  Stream<UserModel?> get member => _fetcher.stream;

  doLogin(String email, String password) async {
    try {
      UserModel? list = await repository.doLogin(email, password);
      _fetcher.sink.add(list);
    } catch (e) {
      _fetcher.sink.addError(e);
    }
  }

  clear() {
    _fetcher.close();
  }
}

final frontStreamBuilder = FrontProvider();
