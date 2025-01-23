import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:versus/src/apis/main_api.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/resources/helper.dart';

class MasterApi extends MainApi {
  Future<dynamic> addMaster(
      {required String url, required Map<String, dynamic> param}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.post(url,
        data: jsonEncode(param),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return response.data;
  }

  Future<dynamic> updateMaster(
      {required String url, required Map<String, dynamic> param}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.put(url,
        data: jsonEncode(param),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return response.data;
  }

  Future deleteMaster({required String url}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.delete(url,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return response.data;
  }
}
