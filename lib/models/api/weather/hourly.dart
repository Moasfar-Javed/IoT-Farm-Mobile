class Hourly {
  final DateTime? time;
  final double? temperature2M;
  final double? apparentTemperature;
  final double? precipitationProbability;
  final double? precipitation;
  final int? weatherCode;
  final int? isDay;

  Hourly({
    this.time,
    this.temperature2M,
    this.apparentTemperature,
    this.precipitationProbability,
    this.precipitation,
    this.weatherCode,
    this.isDay,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) => Hourly(
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
        temperature2M: json["temperature2m"]?.toDouble(),
        apparentTemperature: json["apparentTemperature"]?.toDouble(),
        precipitationProbability: json["precipitationProbability"]?.toDouble(),
        precipitation: json["precipitation"]?.toDouble(),
        weatherCode: json["weatherCode"],
        isDay: json["isDay"],
      );

  Map<String, dynamic> toJson() => {
        "time": time?.toIso8601String(),
        "temperature2m": temperature2M,
        "apparentTemperature": apparentTemperature,
        "precipitationProbability": precipitationProbability,
        "precipitation": precipitation,
        "weatherCode": weatherCode,
        "isDay": isDay,
      };
}
