class Irrigation {
  final num? releaseDuration;
  final dynamic soilCondition;
  final bool? waterOn;
  final bool? manual;
  final DateTime? releasedOn;
  final DateTime? createdOn;
  final dynamic deletedOn;

  Irrigation({
    this.releaseDuration,
    this.soilCondition,
    this.waterOn,
    this.manual,
    this.releasedOn,
    this.createdOn,
    this.deletedOn,
  });

  factory Irrigation.fromJson(Map<String, dynamic> json) => Irrigation(
        releaseDuration: json["release_duration"],
        soilCondition: json["soil_condition"],
        waterOn: json["water_on"],
        manual: json["manual"],
        releasedOn: json["released_on"] == null
            ? null
            : DateTime.parse(json["released_on"]),
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        deletedOn: json["deleted_on"],
      );

  Map<String, dynamic> toJson() => {
        "release_duration": releaseDuration,
        "soil_condition": soilCondition,
        "water_on": waterOn,
        "manual": manual,
        "released_on": releasedOn?.toIso8601String(),
        "created_on": createdOn?.toIso8601String(),
        "deleted_on": deletedOn,
      };
}
