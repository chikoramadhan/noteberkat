import 'package:firebase_database/firebase_database.dart';

class MainApi {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  FirebaseDatabase get database {
    _database.setPersistenceEnabled(true);
    _database.setPersistenceCacheSizeBytes(10000000);
    return _database;
  }
}
