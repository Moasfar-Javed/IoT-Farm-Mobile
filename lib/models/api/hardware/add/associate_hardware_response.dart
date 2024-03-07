import 'dart:convert';

import 'package:farm/models/api/hardware/hardware.dart';

AssociateHardwareResponse associateHardwareResponseFromJson(String str) =>
    AssociateHardwareResponse.fromJson(json.decode(str));

String associateHardwareResponseToJson(AssociateHardwareResponse data) =>
    json.encode(data.toJson());

class AssociateHardwareResponse {
  final bool? success;
  final Data? data;
  final String? message;

  AssociateHardwareResponse({
    this.success,
    this.data,
    this.message,
  });

  factory AssociateHardwareResponse.fromJson(Map<String, dynamic> json) =>
      AssociateHardwareResponse(
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
  final Hardware? hardware;

  Data({
    this.hardware,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        hardware: json["hardware"] == null
            ? null
            : Hardware.fromJson(json["hardware"]),
      );

  Map<String, dynamic> toJson() => {
        "hardware": hardware?.toJson(),
      };
}
