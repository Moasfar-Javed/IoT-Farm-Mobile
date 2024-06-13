import 'package:farm/models/api/hardware/hardware.dart';

class Crop {
  final String? id;
  final String? userId;
  final String? title;
  final String? type;
  final DateTime? preferredReleaseTime;
  final bool? automaticIrrigation;
  final bool? maintainLogs;
  final dynamic cropHealthStatus;
  final double? latitude;
  final double? longitude;
  final DateTime? createdOn;
  final dynamic lastAnalyzedOn;
  final dynamic deletedOn;
  Hardware? hardware;

  Crop({
    this.id,
    this.userId,
    this.title,
    this.type,
    this.preferredReleaseTime,
    this.automaticIrrigation,
    this.maintainLogs,
    this.cropHealthStatus,
    this.latitude,
    this.longitude,
    this.createdOn,
    this.lastAnalyzedOn,
    this.deletedOn,
    this.hardware,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        id: json["_id"],
        userId: json["user_id"],
        title: json["title"],
        type: json["type"],
        preferredReleaseTime: json["preferred_release_time"] == null
            ? null
            : DateTime.parse(json["preferred_release_time"]),
        automaticIrrigation: json["automatic_irrigation"],
        maintainLogs: json["maintain_logs"],
        cropHealthStatus: json["crop_health_status"],
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        lastAnalyzedOn: json["last_analyzed_on"],
        deletedOn: json["deleted_on"],
        hardware: json["hardware"] == null
            ? null
            : Hardware.fromJson(json["hardware"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "user_id": userId,
        "title": title,
        "type": type,
        "preferred_release_time": preferredReleaseTime?.toIso8601String(),
        "automatic_irrigation": automaticIrrigation,
        "maintain_logs": maintainLogs,
        "crop_health_status": cropHealthStatus,
        "latitude": latitude,
        "longitude": longitude,
        "created_on": createdOn?.toIso8601String(),
        "last_analyzed_on": lastAnalyzedOn,
        "deleted_on": deletedOn,
        "hardware": hardware?.toJson(),
      };
}
