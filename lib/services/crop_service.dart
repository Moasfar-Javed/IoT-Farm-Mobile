import 'dart:collection';
import 'dart:convert';

import 'package:farm/keys/api_keys.dart';
import 'package:farm/models/api/base/base_response.dart';
import 'package:farm/models/api/crop/add/add_crop_response.dart';
import 'package:farm/models/api/crop/detail/crop_detail_response.dart';
import 'package:farm/models/api/crop/list/crop_list_response.dart';
import 'package:farm/models/api/crop/types/crop_types_response.dart';
import 'package:farm/models/api/generic/generic_response.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:http/http.dart' as http;

class CropService {
  Future<BaseResponse> getCropListAndWeather(
      double? latitude, double? longitude) async {
    try {
      var url = Uri.parse((latitude != null && longitude != null)
          ? "${ApiKeys.getCropListAndWeather}?latitude=$latitude&longitude=$longitude"
          : ApiKeys.getCropListAndWeather);

      http.Response response = await http.get(url, headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        // "content-type": "application/json"
      });

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final CropListResponse apiResponse =
            CropListResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> getCropDetail(String cropName) async {
    try {
      var url = Uri.parse("${ApiKeys.getCropDetail}?name=$cropName");

      http.Response response = await http.get(url, headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        // "content-type": "application/json"
      });

      print(url);
      print(response.body);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final CropDetailResponse apiResponse =
            CropDetailResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> manuallyRelease(int duration, String cropName) async {
    try {
      var params = HashMap();
      params["duration"] = duration;

      var url = Uri.parse("${ApiKeys.addManualRelease}?name=$cropName");

      http.Response response =
          await http.post(url, body: json.encode(params), headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        "content-type": "application/json"
      });

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final GenericResponse apiResponse =
            GenericResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> addCrop(
    String title,
    String type,
    String preferredReleaseTime,
    bool automaticIrrigation,
    bool maintainLogs,
    double latitude,
    double longitude,
  ) async {
    try {
      var params = HashMap();
      params["title"] = title;
      params["type"] = type;
      params["preferred_release_time"] = preferredReleaseTime;
      params["automatic_irrigation"] = automaticIrrigation;
      params["maintain_logs"] = maintainLogs;
      params["latitude"] = latitude;
      params["longitude"] = longitude;
      var url = Uri.parse(ApiKeys.createCrop);

      http.Response response =
          await http.post(url, body: json.encode(params), headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        "content-type": "application/json"
      });

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final AddCropResponse apiResponse =
            AddCropResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> updateCrop(
    String titleKey,
    String title,
    String type,
    String preferredReleaseTime,
    bool automaticIrrigation,
    bool maintainLogs,
  ) async {
    try {
      var params = HashMap();
      params["title"] = title;
      params["type"] = type;
      params["preferred_release_time"] = preferredReleaseTime;
      params["automatic_irrigation"] = automaticIrrigation;
      params["maintain_logs"] = maintainLogs;
      var url = Uri.parse("${ApiKeys.updateCrop}?name=$titleKey");

      print(url);
      print(params);

      http.Response response =
          await http.put(url, body: json.encode(params), headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        "content-type": "application/json"
      });

      print(response.body);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final AddCropResponse apiResponse =
            AddCropResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> deleteCrop(
    String title,
  ) async {
    try {
      var url = Uri.parse("${ApiKeys.removeCrop}?name=$title");

      print(url);

      http.Response response = await http.delete(url, headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        "content-type": "application/json"
      });

      print(response.body);

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final GenericResponse apiResponse =
            GenericResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> getCropTypes() async {
    try {
      var url = Uri.parse(ApiKeys.getCropTypes);

      http.Response response = await http.get(url, headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        // "content-type": "application/json"
      });

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final CropTypesResponse apiResponse =
            CropTypesResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }
}
