import 'dart:convert';

import 'package:farm/keys/api_keys.dart';
import 'package:farm/models/api/base/base_response.dart';
import 'package:farm/models/api/hardware/add/associate_hardware_response.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:http/http.dart' as http;

class HardwareService {
  Future<BaseResponse> associateHardware(String id, String cropName) async {
    try {
      var url = Uri.parse("${ApiKeys.associateHardware}?id=$id&name=$cropName");

      http.Response response = await http.post(url, headers: {
        "Authorization": "Bearer ${PrefUtil().getUserToken}",
        // "content-type": "application/json"
      });

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final AssociateHardwareResponse apiResponse =
            AssociateHardwareResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }
}
