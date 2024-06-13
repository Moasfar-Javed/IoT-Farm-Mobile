import 'dart:convert';

import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/irrigation/irrigation.dart';
import 'package:farm/models/api/reading/reading.dart';

CropDetailResponse cropDetailResponseFromJson(String str) =>
    CropDetailResponse.fromJson(json.decode(str));

String cropDetailResponseToJson(CropDetailResponse data) =>
    json.encode(data.toJson());

class CropDetailResponse {
  final bool? success;
  final Data? data;
  final String? message;

  CropDetailResponse({
    this.success,
    this.data,
    this.message,
  });

  factory CropDetailResponse.fromJson(Map<String, dynamic> json) =>
      CropDetailResponse(
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
  final List<Reading>? readings;
  final List<Irrigation>? irrigations;

  Data({
    this.crop,
    this.readings,
    this.irrigations,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        crop: json["crop"] == null ? null : Crop.fromJson(json["crop"]),
        readings: json["readings"] == null
            ? []
            : List<Reading>.from(
                json["readings"]!.map((x) => Reading.fromJson(x))),
        irrigations: json["irrigations"] == null
            ? []
            : List<Irrigation>.from(
                json["irrigations"]!.map((x) => Irrigation.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "crop": crop?.toJson(),
        "readings": readings == null
            ? []
            : List<dynamic>.from(readings!.map((x) => x.toJson())),
        "irrigations": irrigations == null
            ? []
            : List<dynamic>.from(irrigations!.map((x) => x)),
      };
}
