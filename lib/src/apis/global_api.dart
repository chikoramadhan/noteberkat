import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:versus/src/apis/main_api.dart';
import 'package:versus/src/models/building_types_model.dart';
import 'package:versus/src/models/certificate_model.dart';
import 'package:versus/src/models/filter_model.dart';
import 'package:versus/src/models/photo_model.dart';
import 'package:versus/src/models/property_category_model.dart';
import 'package:versus/src/models/specific_location_model.dart';
import 'package:versus/src/models/toward_model.dart';
import 'package:versus/src/models/user_model.dart';
import 'package:versus/src/providers/main_provider.dart';
import 'package:versus/src/resources/helper.dart';

class GlobalApi extends MainApi {
  Future<dynamic> fetchVersion() async {
    Response response = await dio.get(kVersionUrl);
    return response.data;
  }

  Future<List<PropertyCategoryModel>> fetchCategory() async {
    Response response = await dio.get(kPropertyCategoryUrl);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kPropertyCategoryLower,
      jsonEncode(
        response.data,
      ),
    );
    return (response.data as List)
        .map((e) => PropertyCategoryModel.fromJson(e))
        .toList();
  }

  Future<List<SpecificLocationModel>> fetchLocation() async {
    Response response = await dio
        .get(kSpecificLocationUrl + "?_limit=-1&_sort=LokasiSpesifikName:ASC");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kSpecificLocationLower,
      jsonEncode(
        response.data,
      ),
    );
    return (response.data as List)
        .map((e) => SpecificLocationModel.fromJson(e))
        .toList();
  }

  Future<List<FilterModel>> fetchFilter() async {
    UserModel? user = await MainProvider().getMember();

    Response response = await dio.get(kFilterUrl,
        queryParameters: {
          "user": user!.user!.id.toString(),
          "_limit": -1,
          "_sort": "title:ASC"
        },
        options:
            new Options(headers: {PARAM_AUTHORIZATION: "Bearer " + user.jwt!}));

    return (response.data as List).map((e) => FilterModel.fromJson(e)).toList();
  }

  Future<List<BuildingTypesModel>> fetchBuildingTypes() async {
    Response response =
        await dio.get(kBuildingTypesUrl + "?_limit=-1&_sort=sort:ASC");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kBuildingTypeLower,
      jsonEncode(
        response.data,
      ),
    );
    return (response.data as List)
        .map((e) => BuildingTypesModel.fromJson(e))
        .toList();
  }

  Future<List<CertificateModel>> fetchCertificate() async {
    Response response = await dio.get(kCertificateUrl + "?_limit=-1");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kCertificateLower,
      jsonEncode(
        response.data,
      ),
    );
    return (response.data as List)
        .map((e) => CertificateModel.fromJson(e))
        .toList();
  }

  Future<List<TowardModel>> fetchToward() async {
    Response response = await dio.get(kTowardUrl + "?_limit=-1");
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(
      kTowardLower,
      jsonEncode(
        response.data,
      ),
    );
    return (response.data as List).map((e) => TowardModel.fromJson(e)).toList();
  }

  Future<PhotoModel> uploadPhoto(
      {required String path, int? id, String? ref, String? field}) async {
    File file = new File(path);

    String fileName = file.path.split('/').last;
    String ext = fileName.split(".").last;
    Map<String, dynamic> data = {
      "files": await MultipartFile.fromFile(file.path,
          filename: fileName, contentType: MediaType.parse("image/" + ext)),
    };

    if (id != null) {
      data['refId'] = id.toString();
    }

    if (ref != null) {
      data['ref'] = ref;
    }

    if (field != null) {
      data['field'] = field;
    }

    FormData formData = FormData.fromMap(data);

    Response response = await dio.post(kUploadUrl, data: formData);

    return PhotoModel.fromJson(response.data[0]);
  }
}
