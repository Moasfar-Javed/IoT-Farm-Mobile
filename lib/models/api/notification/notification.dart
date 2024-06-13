class NotificationDetail {
  final Payload? payload;
  final DateTime? sentOn;

  NotificationDetail({
    this.payload,
    this.sentOn,
  });

  factory NotificationDetail.fromJson(Map<String, dynamic> json) => NotificationDetail(
        payload:
            json["payload"] == null ? null : Payload.fromJson(json["payload"]),
        sentOn:
            json["sent_on"] == null ? null : DateTime.parse(json["sent_on"]),
      );

  Map<String, dynamic> toJson() => {
        "payload": payload?.toJson(),
        "sent_on": sentOn?.toIso8601String(),
      };
}

class Payload {
  final String? id;
  final String? action;
  final String? title;
  final String? message;

  Payload({
    this.id,
    this.action,
    this.title,
    this.message,
  });

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        id: json["id"],
        action: json["action"],
        title: json["title"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "action": action,
        "title": title,
        "message": message,
      };
}
