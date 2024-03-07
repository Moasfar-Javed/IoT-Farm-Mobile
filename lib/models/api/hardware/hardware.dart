class Hardware {
  final String? sensorId;
  final DateTime? createdOn;
  final DateTime? deletedOn;

  Hardware({
    this.sensorId,
    this.createdOn,
    this.deletedOn,
  });

  factory Hardware.fromJson(Map<String, dynamic> json) => Hardware(
        sensorId: json["sensor_id"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        deletedOn: json["deleted_on"],
      );

  Map<String, dynamic> toJson() => {
        "sensor_id": sensorId,
        "created_on": createdOn?.toIso8601String(),
        "deleted_on": deletedOn?.toIso8601String(),
      };
}
