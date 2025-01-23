import 'package:flutter/material.dart';
import 'package:versus/src/resources/repository.dart';

class BaseProvider extends ChangeNotifier {
  final repository = Repository();
}
