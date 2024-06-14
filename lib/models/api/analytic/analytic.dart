class Analytic {
  final num? x;
  final num? y;

  Analytic({
    this.x,
    this.y,
  });

  factory Analytic.fromJson(Map<String, dynamic> json) => Analytic(
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
