import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/apis/main_api.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/city_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/total_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/resources/helper.dart';

class NoteApi extends MainApi {
  StreamSubscription? _addListener, _changedListener, _deleteListener;

  Future<ChatModel> loadChat({required ChatModel chatModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kChatUrl + chatModel.id.toString(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return ChatModel.fromJson(response.data);
  }

  Future<ChatModel> loadArchive({required ChatModel chatModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kArchiveUrl + chatModel.id.toString(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return ChatModel.fromJson(response.data);
  }

  Future<ChatModel> loadTesting({required ChatModel chatModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTestingUrl + chatModel.id.toString(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return ChatModel.fromJson(response.data);
  }

  Future<RequestModel> loadRequest({required RequestModel requestModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kRequestUrl + requestModel.id.toString(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return RequestModel.fromJson(response.data);
  }

  Future<List<ChatModel>> fetchAllNote(
      {Map<String, dynamic>? param, bool? ignoreNull}) async {
    if (param == null) {
      param = {};
    }

    if (!param.containsKey(kTransactionTypeID + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kTransactionTypeID + "_null"] = false;
    }
    if (!param.containsKey(kParamPropertyCategory + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamPropertyCategory + "_null"] = false;
    }
    if (!param.containsKey(kParamSpecificLocation + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSpecificLocation + "_null"] = false;
    }

    if (!param.containsKey(kParamLimit)) {
      param[kParamLimit] = kMaxData;
    }

    if (param[kParamSort] == null &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSort] = kSortUpdatedAtDesc;
    }

    param[kAppsLower] = 5;
    param["pending"] = false;

    //param[kParamRequest] = false;

    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kChatUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => ChatModel.fromJson(e)).toList();

    /*

    _addListener = _query.onChildAdded.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .updateData(event.snapshot);
    });

    _changedListener = _query.onChildChanged.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .updateData(event.snapshot);
    });

    _deleteListener = _query.onChildRemoved.listen((event) {
      Provider.of<NoteProvider>(context, listen: false)
          .removeData(event.snapshot);
    });*/
  }

  Future<List<ChatModel>> fetchAllArchive(
      {Map<String, dynamic>? param, bool? ignoreNull}) async {
    if (param == null) {
      param = {};
    }

    if (!param.containsKey(kTransactionTypeID + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kTransactionTypeID + "_null"] = false;
    }
    if (!param.containsKey(kParamPropertyCategory + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamPropertyCategory + "_null"] = false;
    }
    if (!param.containsKey(kParamSpecificLocation + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSpecificLocation + "_null"] = false;
    }
    if (!param.containsKey(kParamLimit)) {
      param[kParamLimit] = kMaxData;
    }
    if (param[kParamSort] == null &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSort] = kSortUpdatedAtDesc;
    }

    param[kAppsLower] = 5;

    //param[kParamRequest] = false;

    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kArchiveUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => ChatModel.fromJson(e)).toList();
  }

  Future<List<ChatModel>> fetchAllTesting(
      {Map<String, dynamic>? param, bool? ignoreNull}) async {
    if (param == null) {
      param = {};
    }

    if (!param.containsKey(kTransactionTypeID + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kTransactionTypeID + "_null"] = false;
    }
    if (!param.containsKey(kParamPropertyCategory + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamPropertyCategory + "_null"] = false;
    }
    if (!param.containsKey(kParamSpecificLocation + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSpecificLocation + "_null"] = false;
    }
    if (!param.containsKey(kParamLimit)) {
      param[kParamLimit] = kMaxData;
    }
    if (param[kParamSort] == null &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSort] = kSortUpdatedAtDesc;
    }

    param[kAppsLower] = 5;

    //param[kParamRequest] = false;

    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTestingUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => ChatModel.fromJson(e)).toList();
  }

  Future<List<RequestModel>> fetchAllRequest(
      {Map<String, dynamic>? param, bool? ignoreNull}) async {
    if (param == null) {
      param = {};
    }

    if (!param.containsKey(kTransactionTypeID + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kTransactionTypeID + "_null"] = false;
    }
    if (!param.containsKey(kParamPropertyCategory + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamPropertyCategory + "_null"] = false;
    }
    if (!param.containsKey(kParamSpecificLocation + "_null") &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSpecificLocation + "_null"] = false;
    }
    if (!param.containsKey(kParamLimit)) {
      param[kParamLimit] = kMaxData;
    }
    if (param[kParamSort] == null &&
        (ignoreNull == null || ignoreNull == false)) {
      param[kParamSort] = kSortUpdatedAtDesc;
    }

    param[kAppsLower] = 5;

    //param[kParamRequest] = false;

    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kRequestUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List)
        .map((e) => RequestModel.fromJson(e))
        .toList();
  }

  Future<TotalModel> getTotal({Map<String, dynamic>? param}) async {
    if (param == null) {
      param = {};
    }

    param[kAppsLower] = 5;
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTotalUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return TotalModel.fromJson(response.data);
  }

  Future<TotalModel> getTotalArchive({Map<String, dynamic>? param}) async {
    if (param == null) {
      param = {};
    }

    param[kAppsLower] = 5;
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTotalArchiveUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return TotalModel.fromJson(response.data);
  }

  Future<TotalModel> getTotalTesting({Map<String, dynamic>? param}) async {
    if (param == null) {
      param = {};
    }

    param[kAppsLower] = 5;
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTotalTestingUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return TotalModel.fromJson(response.data);
  }

  Future<TotalModel> getTotalRequest({Map<String, dynamic>? param}) async {
    if (param == null) {
      param = {};
    }

    param[kAppsLower] = 5;
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTotalRequestUrl,
        queryParameters: param,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return TotalModel.fromJson(response.data);
  }

  Future<int?> fetchCount({Map<String, dynamic>? param}) async {
    if (param == null) {
      param = {};
    }

    param[kParamRequest] = false;

    Response response =
        await dio.get(kChatUrl + "count", queryParameters: param);

    return response.data;
  }

  Future<List<dynamic>?> uploadFile({required File file}) async {
    UserModel user = await MainProvider().getMember() as UserModel;
    String originalExtension = extension(file.path);

    String newFileName = '${file.path}$originalExtension';
    FormData formData = FormData.fromMap({
      'files': await MultipartFile.fromFile(
        file.path,
        filename: newFileName,
        contentType: MediaType.parse("text/plain"),
      ),
    });

    Response response = await dio.post(kUploadUrl,
        data: formData,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    print(newFileName);
    return response.data;
  }

  Future<dynamic> processRequest() async {
    UserModel user = await MainProvider().getMember() as UserModel;
    await dio.get(kProcessRequestUrl,
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return true;
  }

  Future<ChatModel> updateChat(
      {required Map<String, dynamic>? param, required String id}) async {
    UserModel user = await MainProvider().getMember() as UserModel;
    Response response;

    if (id == "-1") {
      response = await dio.post(kChatUrl,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    } else {
      response = await dio.put(kChatUrl + id,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    }

    return ChatModel.fromJson(response.data);
  }

  Future<ChatModel> updateTesting(
      {required Map<String, dynamic>? param, required String id}) async {
    UserModel user = await MainProvider().getMember() as UserModel;
    Response response;

    if (id == "-1") {
      response = await dio.post(kTestingUrl,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    } else {
      response = await dio.put(kTestingUrl + id,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    }

    return ChatModel.fromJson(response.data);
  }

  Future<RequestModel> updateRequest(
      {required Map<String, dynamic>? param, required String id}) async {
    UserModel user = await MainProvider().getMember() as UserModel;
    Response response;

    if (id == "-1") {
      response = await dio.post(kRequestUrl,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    } else {
      response = await dio.put(kRequestUrl + id,
          data: jsonEncode(param),
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    }

    return RequestModel.fromJson(response.data);
  }

  Future deleteChat({required List<String> ids}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    return await bulkDeleteChat(ids: ids);

    for (var id in ids) {
      await dio.delete(kChatUrl + id,
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    }

    return true;
  }

  Future deleteRequest({required List<String> ids}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    for (var id in ids) {
      await dio.delete(kRequestUrl + id,
          options: new Options(
              headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));
    }

    return true;
  }

  Future restoreChat({required List<String> ids}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    return await bulkRestoreChat(ids: ids);
  }

  Future bulkDeleteChat({required List<String> ids}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    await dio.post(kBulkDeleteChat,
        data: jsonEncode({"ids": ids}),
        options: new Options(
          headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!},
        ));
  }

  Future bulkRestoreChat({required List<String> ids}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    await dio.post(kBulkRestoreChat,
        data: jsonEncode({"ids": ids}),
        options: new Options(
          headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!},
        ));
  }

  Future<ChatModel> mergeChat({required List<int?> id}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.post(kMergeUrl,
        data: {"id": id},
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return ChatModel.fromJson(response.data);
  }

  Future<ChatModel> addChat({required ChatModel chatModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.post(kChatUrl,
        data: chatModel.toJson(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return ChatModel.fromJson(response.data);
  }

  Future<RequestModel> addRequest({required RequestModel requestModel}) async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.post(kRequestUrl,
        data: requestModel.toJson(),
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return RequestModel.fromJson(response.data);
  }

  Future<List<TagModel>> getTag() async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kTagUrl + "?_limit=-1&_sort=name:ASC",
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => TagModel.fromJson(e)).toList();
  }

  Future<List<CityModel>> getCity() async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(kCityUrl + "?_limit=-1&_sort=Title:ASC",
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => CityModel.fromJson(e)).toList();
  }

  Future<List<AreaModel>> getArea() async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(
      kAreaUrl + "?_limit=-1&_sort=Title:ASC",
      /*options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt})*/
    );

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kAreaLower,
      jsonEncode(
        response.data,
      ),
    );

    return (response.data as List).map((e) => AreaModel.fromJson(e)).toList();
  }

  Future<List<SubAreaModel>> getSubArea() async {
    UserModel user = await MainProvider().getMember() as UserModel;

    Response response = await dio.get(
      kSubAreaUrl + "?_limit=-1&_sort=Title:ASC",
      /*options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt})*/
    );

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kSubAreaLower,
      jsonEncode(
        response.data,
      ),
    );

    return (response.data as List)
        .map((e) => SubAreaModel.fromJson(e))
        .toList();
  }

  Future<String?> getUpdate({required String url}) async {
    Response response = await dio.get(url);

    return response.data['date'];
  }

  closeNote() {
    if (_addListener != null) _addListener!.cancel();
    if (_changedListener != null) _changedListener!.cancel();
    if (_deleteListener != null) _deleteListener!.cancel();
  }
}
