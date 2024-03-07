class Current {
  final DateTime? time;
  final double? temperature2M;
  final int? isDay;
  final double? precipitation;

  Current({
    this.time,
    this.temperature2M,
    this.isDay,
    this.precipitation,
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        temperature2M: json["temperature2m"]?.toDouble(),
        isDay: json["isDay"],
        precipitation: json["precipitation"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "time": time?.toIso8601String(),
        "temperature2m": temperature2M,
        "isDay": isDay,
        "precipitation": precipitation,
      };
}
