import 'package:farm/models/api/weather/current.dart';
import 'package:farm/models/api/weather/hourly.dart';

class Weather {
  final Current? current;
  final List<Hourly>? hourly;

  Weather({
    this.current,
    this.hourly,
  });

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        current:
            json["current"] == null ? null : Current.fromJson(json["current"]),
        hourly: json["hourly"] == null
            ? []
            : List<Hourly>.from(json["hourly"]!.map((x) => Hourly.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "current": current?.toJson(),
        "hourly": hourly == null
            ? []
            : List<dynamic>.from(hourly!.map((x) => x.toJson())),
      };
}
