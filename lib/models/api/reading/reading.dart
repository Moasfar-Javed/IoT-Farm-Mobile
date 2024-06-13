class Reading {
  final num? moisture;
  final DateTime? createdOn;
  final dynamic deletedOn;

  Reading({
    this.moisture,
    this.createdOn,
    this.deletedOn,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
        moisture: json["moisture"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        deletedOn: json["deleted_on"],
      );

  Map<String, dynamic> toJson() => {
        "moisture": moisture,
        "created_on": createdOn?.toIso8601String(),
        "deleted_on": deletedOn,
      };
}
