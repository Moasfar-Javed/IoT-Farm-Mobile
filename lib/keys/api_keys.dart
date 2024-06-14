class ApiKeys {
  static const String baseUrl = "https://farm.dijinx.com/api/v1/farm";
  //user
  static const String signinOrUp = "$baseUrl/user/auth";
  static const String getUserDetail = "$baseUrl/user/detail";
  static const String signOutUser = "$baseUrl/user/sign-out";
  static const String getNotification = "$baseUrl/notification/list";

  //crop
  static const String getCropListAndWeather = "$baseUrl/crop/list";
  static const String getCropTypes = "$baseUrl/crop/types";
  static const String createCrop = "$baseUrl/crop/create";
  static const String removeCrop = "$baseUrl/crop/remove";
  static const String updateCrop = "$baseUrl/crop/update";
  static const String getCropDetail = "$baseUrl/crop/detail";
  static const String addManualRelease = "$baseUrl/irrigation/manual-release";
  static const String getIrrigationsAnalytics = "$baseUrl/irrigation/analytics";
  static const String getReadingsAnalytics = "$baseUrl/reading/analytics";

  //hardware
  static const String associateHardware = "$baseUrl/hardware/associate";
  static const String disassociateHardware = "$baseUrl/hardware/disassociate";
}
