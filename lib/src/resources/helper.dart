import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:versus/src/models/chat_model.dart';
import 'package:versus/src/models/user_model.dart';

//const kBaseUrl = "https://api.versus.co.id/";
const kBaseUrl = "http://147.139.179.200:1337/";
const kHistoryUrl = kBaseUrl + "histories/";
const kLoginUrl = kHistoryUrl + "login/";
const kChatUrl = kBaseUrl + "chats/";
const kArchiveUrl = kBaseUrl + "archives/";
const kTestingUrl = kBaseUrl + "testings/";
const kRequestUrl = kBaseUrl + "requests/";
const kProcessRequestUrl = kRequestUrl + "process/";
const kBulkDeleteChat = kChatUrl + "bulkdelete/";
const kBulkRestoreChat = kChatUrl + "bulkRestore/";
const kTagUrl = kBaseUrl + "tags/";
const kCityUrl = kBaseUrl + "cities/";
const kFilterUrl = kBaseUrl + "filters/";
const kAreaUrl = kBaseUrl + "areas/";
const kSubAreaUrl = kBaseUrl + "sub-areas/";
const kTagUpdateUrl = kBaseUrl + "tagupdate/";
const kProvinsiUpdateUrl = kBaseUrl + "provinsiupdate/";
const kKotaUpdateUrl = kBaseUrl + "kotaupdate/";
const kAreaUpdateUrl = kBaseUrl + "areaupdate/";
const kSubareaUpdateUrl = kBaseUrl + "subareaupdate/";
const kLokasiUpdateUrl = kBaseUrl + "lokasiupdate/";
const kUploadUrl = kBaseUrl + "upload/";

const kLogUrl = kBaseUrl + "logs/";
const kLog2Url = kBaseUrl + "logcheckers/";
const kLog3Url = kBaseUrl + "logreports/";
const kTotalUrl = kChatUrl + "getTotal/";
const kTotalArchiveUrl = kChatUrl + "getTotalArchive/";
const kTotalTestingUrl = kChatUrl + "getTotalTesting/";
const kTotalRequestUrl = kChatUrl + "getTotalRequest/";
const kMergeUrl = kChatUrl + "merge/";
const kVersionUrl = kBaseUrl + "version/";
const kPropertyCategoryUrl = kBaseUrl + "property-categories/";
const kSpecificLocationUrl = kBaseUrl + "specific-locations/";
const kBuildingTypesUrl = kBaseUrl + "building-types/";
const kCertificateUrl = kBaseUrl + "certificates/";
const kTowardUrl = kBaseUrl + "towards/";
const kUserUrl = kBaseUrl + "users/";
const kMeUrl = kUserUrl + "me/";
const kLogoutUrl = kBaseUrl + "logins/logout/";
const kVersionApps = 0;

const kRouteApp = "frontPage";
const kRouteFrontPage = "loginPage";
const kRouteNoteAdd = "noteAdd";
const kRouteTestingAdd = "testingAdd";
const kRouteRequestAdd = "requestAdd";
const kRouteFriendAdd = "friendAdd";
const kRouteNoteShare = "noteShare";
const kRouteChat = "chat";
const kRouteArchive = "archive";
const kRouteRequest = "request";
const kRouteTesting = "testing";
const kRouteMerge = "merge";
const kRouteHistory = "history";

const kIdentifier = "identifier";
const kPassword = "password";
const kEmailLower = "email";
const kPasswordLower = "password";
const kIdentifierLower = "identifier";
const kMemberLower = "member";
const kRoomCodeLower = "roomcode";
const kDetailLower = "detail";
const kStatusLower = "status";
const kPengajarIdLower = "pengajar_id";
const kWorkDetailsLower = "work_details";
const kWorkDetailLower = "work_detail";
const kFilename = "Filename";
const kUserLower = "user";
const kUsersLower = "users";
const kLocationsLower = "locations";
const kNumberLower = "number";
const kChatLower = "chat";
const kAppsLower = "apps";
const kConfirmedLower = "confirmed";
const kTransaksiLower = "transaksi";
const kLokasiLower = "lokasi";
const kJenisLokasiLower = "jenis_lokasi";
const kVersionLower = "version";
const kPropertyCategoryLower = "propertycategory";
const kSpecificLocationLower = "specificlocation";
const kAreaLower = "area";
const kSubAreaLower = "subArea";
const kBuildingTypeLower = "buildingtype";
const kCertificateLower = "certificate";
const kTowardLower = "toward";
const kLtLower = "lt";
const kIdLower = "id";
const kLelangLower = "lelang";
const kMinusLower = "minus";
const kHargaJualLower = "hargajual";
const kPerMeterJualLower = "perMeterJual";
const kPerMeterSewaLower = "perMeterSewa";
const kFilterKategoriLower = "filterKategori";
const kBreakdownJualLower = "breakdownJual";
const kGlobalSewaLower = "globalsewa";
const kHargaSewaLower = "globalSewa";
const kKeywordLower = "keyword";
const kSpaceLower = "space";
const kOnlyNew = "onlyNew";
const kOnlyRequest = "onlyRequest";
const kOnlyMulti = "onlyMulti";
const kCheckLower = "check";
const kCheck2Lower = "check2";
const kCheck3Lower = "check3";
const kLelangMinusLower = "lelang_minus";
const kTagsLower = "tags";
const kAdminLower = "admin";
const kDateLower = "date";
const kCombinationLower = "combination";

const kLokasi = "Lokasi";
const kTransaksi = "Transaksi";
const kJual = "Jual";
const kSewa = "Sewa";
const kJualSewa = "Jual / Sewa";
const kLokasiSpesifik = "Lokasi Spesifik";
const kKategori = "Kategori";
const kTipeBangunan = "Tipe Bangunan";
const kFilter = "Filter";
const kSearch = "Search";
const kReset = "Reset";
const kLihatSemua = "Lihat Semua";
const kLuasTanah = "Luas Tanah";
const kLuasBangunan = "Luas Bangunan";
const kHargaJual = "Harga Jual";
const kHargaSewa = "Harga Sewa";
const kPerMeterJual = "Global /m2 Jual";
const kPerMeterSewa = "Global /m2 LT Sewa";
const kPropertyTypeID = "PropertyTypeID";
const kTransactionTypeID = "TransactionTypeID";
const kCariLokasi = "Cari Lokasi";
const kCariKota = "Cari Kota";
const kCariKategori = "Cari Kategori";
const kCariSertifikat = "Cari Sertifikat";
const kCariHadap = "Cari Hadap";
const kCariTipeBangunan = "Cari Tipe Bangunan";
const kTanggalChat = "Tanggal Chat";

const kParamLimit = "_limit";
const kParamStart = "_start";
const kParamContains = "_contains";
const kParamSort = "_sort";
const kParamRequest = "request";
const kSortUpdatedAtDesc = "updated_at:DESC";
const kSortPerMeterJualAsc = "perMeterJual:ASC";
const kSortHargaJualAsc = "HargaJual:ASC";
const kSortPerMeterSewaAsc = "perMeterSewa:ASC";
const kSortHargaSewaAsc = "HargaSewa:ASC";
const kSortGlobalSewaAsc = "globalSewa:ASC";
const kSortBreakdownJualAsc = "breakdownJual:ASC";
const kSortDateDesc = "date:DESC";
const kSortUpdateAgentDesc = "update_agent:DESC";
const kSortDateAsc = "date:ASC,id:ASC";
const kSortIdAsc = "id:ASC";
const kParamPropertyCategory = "property_category";
const kParamTransactionTypeID = "TransactionTypeID";
const kParamSpecificLocation = "specific_location";
const kParamSertifikatLower = "sertifikat";
const kParamHadapLower = "hadap";
const kParamBuildingType = "building_type";
const kParamHargaJual = "HargaJual";
const kParamHargaSewa = "HargaSewa";
const kParamLT = "LT";
const kParamLB = "LB";
const kParamStatusCode = "statusCode";

const kAlertEmailEmpty = "Email cannot empty";
const kAlertPasswordEmpty = "Password cannot empty";
const kAlertLoginError = "Login error";
const kAlertLoginSuccess = "Login success";

const kMinLT = 0;
const kMaxLT = 0;
const kMinHargaJual = 0;
const kMaxHargaJual = 0;
const kMinHargaSewa = 0;
const kMaxHargaSewa = 0;
const kMaxData = 20;

UserModel? userModel;

const PARAM_AUTHORIZATION = "Authorization";

bool isMarketing(UserModel? user) {
  return user != null && (user.user!.role!.type == "marketing");
}

bool isStaff(UserModel? user) {
  return user != null &&
      (user.user!.role!.type == "staff" || user.user!.role!.type == "admin");
}

bool isAdmin(UserModel? user) {
  return user != null && (user.user!.role!.type == "admin");
}

void chatToClipboard(
    List<ChatModel?> chats, UserModel? user, BuildContext context,
    {bool full = true}) {
  String text = "";
  ToastContext().init(context);
  chats.forEach((chat) {
    String photo = "";
    String notes = "";
    if ((isAdmin(user) || isMarketing(user)) &&
        chat!.photo != null &&
        chat.photo!.length > 0) {
      photo = "\n\nFoto : \n";
      photo +=
          "https://api.versus.co.id/chats/" + chat.id.toString() + "/photo";
    }

    if ((isAdmin(user) || isMarketing(user)) &&
        chat!.linkPhoto != null &&
        chat.linkPhoto!.isNotEmpty) {
      photo += "\n\nLink Foto: ";
      chat.linkPhoto!.split("\n").forEach((element) {
        photo += "\n" + element;
      });
    }

    if ((isAdmin(user) || isMarketing(user)) &&
        chat!.notes != null &&
        chat.notes!.isNotEmpty) {
      notes += "\nNotes: ";
      notes += "\n" + chat.notes!;
    }

    if (text.isNotEmpty) {
      text += "\n\n=====================\n\n";
    }

    text += chat!.chat!;
    text += chat.hargaClipboard(full);
    text += notes;
    text += photo;
  });

  if (text.isNotEmpty) {
    Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
    Toast.show("Text copied to clipboard");
  }
}

void showMessage(GlobalKey<ScaffoldState> key, String message) {
  ScaffoldMessenger.of(key.currentContext!).showSnackBar(SnackBar(
    content: Text(message),
    duration: Duration(seconds: 3),
  ));
}
