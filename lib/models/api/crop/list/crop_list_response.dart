import 'dart:convert';

import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/weather/weather.dart';

CropListResponse cropListFromJson(String str) =>
    CropListResponse.fromJson(json.decode(str));

String cropListToJson(CropListResponse data) => json.encode(data.toJson());

class CropListResponse {
  final bool? success;
  final Data? data;
  final String? message;

  CropListResponse({
    this.success,
    this.data,
    this.message,
  });

  factory CropListResponse.fromJson(Map<String, dynamic> json) =>
      CropListResponse(
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
  final List<Crop>? crops;
  final Weather? weather;

  Data({
    this.crops,
    this.weather,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        crops: json["crops"] == null
            ? []
            : List<Crop>.from(json["crops"]!.map((x) => Crop.fromJson(x))),
        weather:
            json["weather"] == null ? null : Weather.fromJson(json["weather"]),
      );

  Map<String, dynamic> toJson() => {
        "crops": crops == null
            ? []
            : List<dynamic>.from(crops!.map((x) => x.toJson())),
        "weather": weather?.toJson(),
      };
}
