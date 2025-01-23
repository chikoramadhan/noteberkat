import 'dart:async';
import 'dart:io';

import 'package:versus/src/apis/front_api.dart';
import 'package:versus/src/apis/global_api.dart';
import 'package:versus/src/apis/log_api.dart';
import 'package:versus/src/apis/master_api.dart';
import 'package:versus/src/apis/note_api.dart';
import 'package:versus/src/models/area_model.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/certificate_model.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/city_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/log_model.dart';
import 'package:versus/src/models/photo_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/request_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/sub_area_model.dart';
import 'package:versus/src/models/tag_model.dart';
import 'package:versus/src/models/total_model.dart';
import 'package:versus/src/models/toward_model.dart';
import 'package:versus/src/models/user_model.dart';

class Repository {
  final noteApi = NoteApi();
  final frontApi = FrontApi();
  final globalApi = GlobalApi();
  final reportApi = LogApi();
  final masterApi = MasterApi();

  Future<List<TagModel>> getTag() => noteApi.getTag();

  Future<List<CityModel>> getCity() => noteApi.getCity();

  Future<List<AreaModel>> getArea() => noteApi.getArea();

  Future<List<SubAreaModel>> getSubArea() => noteApi.getSubArea();

  Future<String?> getUpdate({required String url}) =>
      noteApi.getUpdate(url: url);

  Future<List<ChatModel>> fetchAllNote(
          {Map<String, dynamic>? param, bool? ignoreNull}) =>
      noteApi.fetchAllNote(param: param, ignoreNull: ignoreNull);

  Future<List<ChatModel>> fetchAllArchive(
          {Map<String, dynamic>? param, bool? ignoreNull}) =>
      noteApi.fetchAllArchive(param: param, ignoreNull: ignoreNull);

  Future<List<ChatModel>> fetchAllTesting(
          {Map<String, dynamic>? param, bool? ignoreNull}) =>
      noteApi.fetchAllTesting(param: param, ignoreNull: ignoreNull);

  Future<List<RequestModel>> fetchAllRequest(
          {Map<String, dynamic>? param, bool? ignoreNull}) =>
      noteApi.fetchAllRequest(param: param, ignoreNull: ignoreNull);

  Future<ChatModel> loadChat({required ChatModel chatModel}) =>
      noteApi.loadChat(chatModel: chatModel);

  Future<ChatModel> loadArchive({required ChatModel chatModel}) =>
      noteApi.loadArchive(chatModel: chatModel);

  Future<ChatModel> loadTesting({required ChatModel chatModel}) =>
      noteApi.loadTesting(chatModel: chatModel);

  Future<RequestModel> loadRequest({required RequestModel requestModel}) =>
      noteApi.loadRequest(requestModel: requestModel);

  Future<TotalModel> getTotal({Map<String, dynamic>? param}) =>
      noteApi.getTotal(param: param);

  Future<TotalModel> getTotalArchive({Map<String, dynamic>? param}) =>
      noteApi.getTotalArchive(param: param);

  Future<TotalModel> getTotalTesting({Map<String, dynamic>? param}) =>
      noteApi.getTotalTesting(param: param);

  Future<TotalModel> getTotalRequest({Map<String, dynamic>? param}) =>
      noteApi.getTotalRequest(param: param);

  Future<List<dynamic>?> uploadFile({required File file}) =>
      noteApi.uploadFile(file: file);

  Future<dynamic> processRequest() => noteApi.processRequest();

  Future<int?> fetchCount({Map<String, dynamic>? param}) =>
      noteApi.fetchCount(param: param);

  Future<ChatModel> updateChat(
          {Map<String, dynamic>? param, required String id}) =>
      noteApi.updateChat(param: param, id: id);

  Future<ChatModel> updateTesting(
          {Map<String, dynamic>? param, required String id}) =>
      noteApi.updateTesting(param: param, id: id);

  Future<RequestModel> updateRequest(
          {Map<String, dynamic>? param, required String id}) =>
      noteApi.updateRequest(param: param, id: id);

  Future deleteChat({required List<String> ids}) =>
      noteApi.deleteChat(ids: ids);

  Future deleteRequest({required List<String> ids}) =>
      noteApi.deleteRequest(ids: ids);

  Future restoreChat({required List<String> ids}) =>
      noteApi.restoreChat(ids: ids);

  Future<ChatModel> addChat({required ChatModel chatModel}) =>
      noteApi.addChat(chatModel: chatModel);

  Future<RequestModel> addRequest({required RequestModel requestModel}) =>
      noteApi.addRequest(requestModel: requestModel);

  Future<ChatModel> mergeChat({required List<int?> id}) =>
      noteApi.mergeChat(id: id);

  Future<dynamic> fetchVersion() => globalApi.fetchVersion();

  Future<List<PropertyCategoryModel>> fetchCategory() =>
      globalApi.fetchCategory();

  Future<List<SpecificLocationModel>> fetchLocation() =>
      globalApi.fetchLocation();

  Future<List<FilterModel>> fetchFilter() => globalApi.fetchFilter();

  Future<List<BuildingTypesModel>> fetchBuildingTypes() =>
      globalApi.fetchBuildingTypes();

  Future<List<CertificateModel>> fetchCertificate() =>
      globalApi.fetchCertificate();

  Future<List<TowardModel>> fetchToward() => globalApi.fetchToward();

  void closeNote() => noteApi.closeNote();

  Future<UserModel?> doLogin(String email, String password) =>
      frontApi.doLogin(email, password);

  Future<UserModel?> me({required UserModel user}) => frontApi.me(user: user);

  Future doLogout() => frontApi.doLogout();

  void sendToken({String? token, String? userId}) =>
      frontApi.sendToken(token, userId);

  Future deleteToken({String? token, String? userId}) =>
      frontApi.deleteToken(token, userId);

  Future logout({required UserModel user}) => frontApi.logout(user: user);

  Future<List<LogModel>> getLogs({required DateTime time}) =>
      reportApi.getLogs(time: time);

  Future<List<LogModel>> getLogs2({required DateTime time}) =>
      reportApi.getLogs2(time: time);

  Future<List<LogModel>> getLogs3({required DateTime time}) =>
      reportApi.getLogs3(time: time);

  Future<PhotoModel> uploadPhoto(
          {required String path, int? id, String? ref, String? field}) =>
      globalApi.uploadPhoto(path: path, id: id, field: field, ref: ref);

  Future<dynamic> addMaster(
          {required String url, required Map<String, dynamic> param}) =>
      masterApi.addMaster(url: url, param: param);

  Future<dynamic> updateMaster(
          {required String url, required Map<String, dynamic> param}) =>
      masterApi.updateMaster(url: url, param: param);

  Future<dynamic> deleteMaster({required String url}) =>
      masterApi.deleteMaster(url: url);
}
