import 'dart:convert';

import 'package:farm/models/api/crop/crop.dart';

AddCropResponse addCropResponseFromJson(String str) =>
    AddCropResponse.fromJson(json.decode(str));

String addCropResponseToJson(AddCropResponse data) =>
    json.encode(data.toJson());

class AddCropResponse {
  final bool? success;
  final Data? data;
  final String? message;

  AddCropResponse({
    this.success,
    this.data,
    this.message,
  });

  factory AddCropResponse.fromJson(Map<String, dynamic> json) =>
      AddCropResponse(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data?.toJson(),
        "message": message,
      };
}

class Data {
  final Crop? crop;

  Data({
    this.crop,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
      );

  Map<String, dynamic> toJson() => {
        "crop": crop?.toJson(),
      };
}
