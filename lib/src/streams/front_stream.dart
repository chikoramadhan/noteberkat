import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_berkat/src/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class FrontProvider {
  final _fetcher = PublishSubject<FirebaseUser>();
  final repository = Repository();

  Observable<FirebaseUser> get member => _fetcher.stream;

  doLogin(String email, String password) async {
    try {
      FirebaseUser list = await repository.doLogin(email, password);
      _fetcher.sink.add(list);
    } catch (e) {
      _fetcher.sink.addError(e);
    }
  }

  doRegister(String email, String password) async {
    try {
      FirebaseUser list = await repository.doRegister(email, password);
      _fetcher.sink.add(list);
    } catch (e) {
      _fetcher.sink.addError(e);
    }
  }

  Future sendToDatabase() async {
    FirebaseUser user = await repository.getUser();
    await repository.sendToDatabase(user: user);
  }

  clear() {
    _fetcher.close();
  }
}

final frontStreamBuilder = FrontProvider();
