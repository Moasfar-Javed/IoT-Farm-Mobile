import 'package:farm/models/api/hardware/hardware.dart';

class Crop {
  String? title;
  String? preferredReleaseDuration;
  String? preferredReleaseTime;
  bool? automaticIrrigation;
  bool? maintainLogs;
  bool? hardwarePaired;
  String? cropHealthStatus;
  DateTime? createdOn;
  DateTime? deletedOn;
  String? nextIrrigation;
  String? optimalIrrigationTime;
  String? releaseDuration;
  Hardware? hardware;

  Crop({
    this.title,
    this.preferredReleaseDuration,
    this.preferredReleaseTime,
    this.automaticIrrigation,
    this.maintainLogs,
    this.hardwarePaired,
    this.cropHealthStatus,
    this.createdOn,
    this.deletedOn,
    this.nextIrrigation,
    this.optimalIrrigationTime,
    this.releaseDuration,
    this.hardware,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
        title: json["title"],
        preferredReleaseDuration: json["preferred_release_duration"],
        preferredReleaseTime: json["preferred_release_time"],
        automaticIrrigation: json["automatic_irrigation"],
        maintainLogs: json["maintain_logs"],
        hardwarePaired: json["hardware_paired"],
        cropHealthStatus: json["crop_health_status"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        deletedOn: json["deleted_on"],
        nextIrrigation: json["next_irrigation"],
        optimalIrrigationTime: json["optimal_irrigation_time"],
        releaseDuration: json["release_duration"],
        hardware: json["hardware"] == null
            ? null
            : Hardware.fromJson(json["hardware"]),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "preferred_release_duration": preferredReleaseDuration,
        "preferred_release_time": preferredReleaseTime,
        "automatic_irrigation": automaticIrrigation,
        "maintain_logs": maintainLogs,
        "hardware_paired": hardwarePaired,
        "crop_health_status": cropHealthStatus,
        "created_on": createdOn?.toIso8601String(),
        "deleted_on": deletedOn?.toIso8601String(),
        "next_irrigation": nextIrrigation,
        "optimal_irrigation_time": optimalIrrigationTime,
        "release_duration": releaseDuration,
        "hardware": hardware?.toJson(),
      };
}
