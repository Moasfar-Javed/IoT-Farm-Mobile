import 'dart:collection';
import 'dart:convert';

import 'package:farm/keys/api_keys.dart';
import 'package:farm/models/api/base/base_response.dart';
import 'package:farm/models/api/crop/add/add_crop_response.dart';
import 'package:farm/models/api/crop/list/crop_list_response.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:http/http.dart' as http;

class CropService {
  Future<BaseResponse> getCropListAndWeather() async {
    try {
      var url = Uri.parse(ApiKeys.getCropListAndWeather);

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

  Future<BaseResponse> addCrop(
    String title,
    String preferredReleaseDuration,
    String preferredReleaseTime,
    bool automaticIrrigation,
    bool maintainLogs,
  ) async {
    try {
      var params = HashMap();
      params["title"] = title;
      params["preferred_release_duration"] = preferredReleaseDuration;
      params["preferred_release_time"] = preferredReleaseTime;
      params["automatic_irrigation"] = automaticIrrigation;
      params["maintain_logs"] = maintainLogs;
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
}
