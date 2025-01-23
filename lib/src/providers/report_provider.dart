import 'package:versus/src/models/log_model.dart';
import 'package:versus/src/providers/main_provider.dart';

class ReportProvider extends MainProvider {
  Future<List<LogModel>> getLogs({required DateTime time}) async {
    List<LogModel> _list = await repository.getLogs(time: time);

    return _list;
  }

  Future<List<LogModel>> getLogs2({required DateTime time}) async {
    List<LogModel> _list = await repository.getLogs2(time: time);
    return _list;
  }

  Future<List<LogModel>> getLogs3({required DateTime time}) async {
    List<LogModel> _list = await repository.getLogs3(time: time);
    return _list;
  }
}
