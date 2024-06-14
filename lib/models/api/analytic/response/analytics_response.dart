import 'dart:convert';

import 'package:farm/models/api/analytic/analytic.dart';

AnalyticsResponse analyticsResponseFromJson(String str) =>
    AnalyticsResponse.fromJson(json.decode(str));

String analyticsResponseToJson(AnalyticsResponse data) =>
    json.encode(data.toJson());

class AnalyticsResponse {
  final bool? success;
  final Data? data;
  final String? message;

  AnalyticsResponse({
    this.success,
    this.data,
    this.message,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) =>
      AnalyticsResponse(
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
  final List<num>? x;
  final List<num>? y;
  final List<Analytic>? mappedData;

  Data({
    this.x,
    this.y,
    this.mappedData,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        x: json["x"] == null ? [] : List<num>.from(json["x"]!.map((x) => x)),
        y: json["y"] == null ? [] : List<num>.from(json["y"]!.map((x) => x)),
        mappedData: json["mapped_data"] == null
            ? []
            : List<Analytic>.from(
                json["mapped_data"]!.map((x) => Analytic.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "x": x == null ? [] : List<dynamic>.from(x!.map((x) => x)),
        "y": y == null ? [] : List<dynamic>.from(y!.map((x) => x)),
        "mapped_data": mappedData == null
            ? []
            : List<dynamic>.from(mappedData!.map((x) => x.toJson())),
      };
}
