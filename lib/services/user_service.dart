import 'dart:collection';
import 'dart:convert';

import 'package:farm/keys/api_keys.dart';
import 'package:farm/models/api/base/base_response.dart';
import 'package:farm/models/api/generic/generic_response.dart';
import 'package:farm/models/api/user/user_response.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<BaseResponse> signInUser(
    String firebaseId,
    String emailOrNumber,
    String? fcmToken,
  ) async {
    try {
      var url = Uri.parse(ApiKeys.signinOrUp);

      var params = HashMap();
      params["fire_uid"] = firebaseId;
      params["phone_or_email"] = emailOrNumber;
      params["fcm_token"] = fcmToken;

      http.Response response = await http.post(url,
          body: json.encode(params),
          headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final UserResponse apiResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> refreshUserDetails() async {
    try {
      var url = Uri.parse(ApiKeys.getUserDetail);

      http.Response response = await http.get(url,
          headers: {"Authorization": "Bearer ${PrefUtil().getUserToken}"});

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        final UserResponse apiResponse = UserResponse.fromJson(responseBody);
        return BaseResponse(apiResponse, null);
      } else {
        return BaseResponse(null, response.body);
      }
    } catch (ex) {
      return BaseResponse(null, ex.toString());
    }
  }

  Future<BaseResponse> signOutUser() async {
    try {
      var url = Uri.parse(ApiKeys.signOutUser);

      http.Response response = await http.delete(url,
          headers: {"Authorization": "Bearer ${PrefUtil().getUserToken}"});

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
}
