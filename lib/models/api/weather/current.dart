class Current {
  final DateTime? time;
  final double? temperature2M;
  final int? isDay;
  final double? precipitation;
  final int? weatherCode;

  Current({
    this.time,
    this.temperature2M,
    this.isDay,
    this.precipitation,
    this.weatherCode,
  });

  factory Current.fromJson(Map<String, dynamic> json) => Current(
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        temperature2M: json["temperature2m"]?.toDouble(),
        isDay: json["isDay"],
        precipitation: json["precipitation"]?.toDouble(),
        weatherCode: json["weatherCode"],
      );

  Map<String, dynamic> toJson() => {
        "time": time?.toIso8601String(),
        "temperature2m": temperature2M,
        "isDay": isDay,
        "precipitation": precipitation,
        "weatherCode": weatherCode,
      };
}
