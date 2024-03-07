class ApiKeys {
  static const String baseUrl = "http://192.168.100.228:3000/api/v1/farm";
  //user
  static const String signinOrUp = "$baseUrl/user/sign-in-or-up";
  static const String getUserDetail = "$baseUrl/user/detail";
  static const String signOutUser = "$baseUrl/user/sign-out";

  //crop
  static const String getCropListAndWeather = "$baseUrl/crop/list";
  static const String createCrop = "$baseUrl/crop/create";
  static const String removeCrop = "$baseUrl/crop/remove";
  static const String updateCrop = "$baseUrl/crop/update";

  //hardware
  static const String associateHardware = "$baseUrl/hardware/associate";
  static const String disassociateHardware = "$baseUrl/hardware/disassociate";
}
