class UserDetails {
  final String? fireUid;
  final String? phoneOrEmail;
  final String? role;
  final String? authToken;
  final DateTime? createdOn;
  final dynamic deletedOn;

  UserDetails({
    this.fireUid,
    this.phoneOrEmail,
    this.role,
    this.authToken,
    this.createdOn,
    this.deletedOn,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        fireUid: json["fire_uid"],
        phoneOrEmail: json["phone_or_email"],
        role: json["role"],
        authToken: json["auth_token"],
        createdOn: json["created_on"] == null
            ? null
            : DateTime.parse(json["created_on"]),
        deletedOn: json["deleted_on"],
      );

  Map<String, dynamic> toJson() => {
        "fire_uid": fireUid,
        "phone_or_email": phoneOrEmail,
        "role": role,
        "auth_token": authToken,
        "created_on": createdOn?.toIso8601String(),
        "deleted_on": deletedOn,
      };
}
