import 'dart:convert';

CropTypesResponse cropTypesResponseFromJson(String str) =>
    CropTypesResponse.fromJson(json.decode(str));

String cropTypesResponseToJson(CropTypesResponse data) =>
    json.encode(data.toJson());

class CropTypesResponse {
  final bool? success;
  final Data? data;
  final String? message;

  CropTypesResponse({
    this.success,
    this.data,
    this.message,
  });

  factory CropTypesResponse.fromJson(Map<String, dynamic> json) =>
      CropTypesResponse(
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
  final List<String>? cropTypes;

  Data({
    this.cropTypes,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        cropTypes: json["crop_types"] == null
            ? []
            : List<String>.from(json["crop_types"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "crop_types": cropTypes == null
            ? []
            : List<dynamic>.from(cropTypes!.map((x) => x)),
      };
}
