import 'dart:async';

import 'package:dio/dio.dart';
import 'package:versus/src/apis/main_api.dart';
import 'package:versus/src/models/log_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/resources/helper.dart';

class LogApi extends MainApi {
  Future<List<LogModel>> getLogs({required DateTime time}) async {
    UserModel? user = await MainProvider().getMember();

    DateTime temp = time;
    DateTime date = new DateTime(temp.year, temp.month, temp.day, 0, 0, 0);
    DateTime date2 = new DateTime(temp.year, temp.month, temp.day, 23, 59, 59);

    dynamic response = await dio.get(kLogUrl,
        queryParameters: {
          "start_gte": date.toIso8601String(),
          "start_lte": date2.toIso8601String()
        },
        options: new Options(
            headers: {PARAM_AUTHORIZATION: "Bearer " + user!.jwt!}));
    return (response.data as List).map((e) => LogModel.fromJson(e)).toList();
  }

  Future<List<LogModel>> getLogs2({required DateTime time}) async {
    UserModel? user = await MainProvider().getMember();

    DateTime temp = time;
    DateTime date = new DateTime(temp.year, temp.month, temp.day, 0, 0, 0);
    DateTime date2 = new DateTime(temp.year, temp.month, temp.day, 23, 59, 59);

    dynamic response = await dio.get(kLog2Url,
        queryParameters: {
          "start_gte": date.toIso8601String(),
          "start_lte": date2.toIso8601String()
        },
        options: new Options(
            headers: {PARAM_AUTHORIZATION: "Bearer " + user!.jwt!}));
    return (response.data as List).map((e) => LogModel.fromJson(e)).toList();
  }

  Future<List<LogModel>> getLogs3({required DateTime time}) async {
    UserModel? user = await MainProvider().getMember();

    DateTime temp = time;
    DateTime date = new DateTime(temp.year, temp.month, temp.day, 0, 0, 0);
    DateTime date2 = new DateTime(temp.year, temp.month, temp.day, 23, 59, 59);

    dynamic response = await dio.get(kLog3Url,
        queryParameters: {
          "start_gte": date.toIso8601String(),
          "start_lte": date2.toIso8601String()
        },
        options: new Options(
            headers: {PARAM_AUTHORIZATION: "Bearer " + user!.jwt!}));
    return (response.data as List).map((e) => LogModel.fromJson(e)).toList();
  }
}
