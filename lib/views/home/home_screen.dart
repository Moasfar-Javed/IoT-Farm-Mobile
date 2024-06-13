import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/crop/list/crop_list_response.dart';
import 'package:farm/models/api/hardware/add/associate_hardware_response.dart';
import 'package:farm/models/api/hardware/hardware.dart';
import 'package:farm/models/api/weather/hourly.dart';
import 'package:farm/models/api/weather/weather.dart';
import 'package:farm/models/event_bus/refresh_crops.dart';
import 'package:farm/models/screen_args/crop_args.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/services/hardware_service.dart';
import 'package:farm/services/user_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/bottom_sheets/add_crop_sheet.dart';
import 'package:farm/widgets/bottom_sheets/view_notifications_sheet.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

class HomeScreen extends StatefulWidget {
  static final eventBus = EventBus();
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool showPageLoading = true;
  bool showSignoutLoading = false;
  bool isLoadingPairButton = false;
  bool isPairingSuccess = false;
  bool isCodeInputValid = false;
  UserService userService = UserService();
  CropService cropService = CropService();
  HardwareService hardwareService = HardwareService();
  Weather? weather;
  List<Crop>? crops;
  final TextEditingController _codeController = TextEditingController();
  final focusNode = FocusNode();
  Position? position;

  @override
  void initState() {
    _determinePosition();
    super.initState();
    HomeScreen.eventBus.on<RefreshCropsEvent>().listen(
      (event) {
        if (mounted) {
          _getCropListWithWeather();
        }
      },
    );
  }

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      position = null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied && mounted) {
        position = null;
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      position = null;
    }

    position = await Geolocator.getCurrentPosition();
    _getCropListWithWeather();
  }

  _getCropListWithWeather() async {
    cropService
        .getCropListAndWeather(position?.latitude, position?.longitude)
        .then((value) {
      setState(() {
        showPageLoading = false;
      });
      PrefUtil().setLastLatitude = position?.latitude ?? 0.0;
      PrefUtil().setLastLongitude = position?.longitude ?? 0.0;
      if (value.error == null) {
        CropListResponse response = value.snapshot;
        if (response.success ?? false) {
          weather = response.data?.weather;
          crops = response.data?.crops;
        } else {
          ToastUtil.showToast(response.message ?? "");
          print(response.message);
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
        print(value.error);
      }
    });
  }

  String _greetBasedOnTime() {
    DateTime now = DateTime.now();

    int hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 18) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    return greeting;
  }

  _signOutUser() async {
    setState(() {
      showSignoutLoading = true;
    });
    final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Sign out',
        message: 'Are you sure you want to sign out of the farm?');
    if (result == OkCancelResult.ok) {
      await FirebaseAuth.instance.signOut();
      await userService.signOutUser();
      PrefUtil().setUserId = "";
      PrefUtil().setUserToken = "";
      PrefUtil().setUserPhoneOrEmail = "";
      PrefUtil().setUserRole = "";
      PrefUtil().setUserLoggedIn = false;
      setState(() {
        showSignoutLoading = false;
      });
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(signinRoute, (route) => false);
      }
    } else {
      setState(() {
        showSignoutLoading = false;
      });
    }
  }

  _associateHardware(Crop crop, String code) async {
    setState(() {
      isLoadingPairButton = true;
    });
    hardwareService.associateHardware(code, crop.title ?? "").then((value) {
      setState(() {
        isLoadingPairButton = false;
      });
      if (value.error == null) {
        AssociateHardwareResponse response = value.snapshot;
        if (response.success ?? false) {
          _codeController.text = "";
          Hardware? hardware = response.data!.hardware;
          int index =
              crops!.indexWhere((element) => element.title == crop.title);
          crops![index].hardware = hardware;

          setState(() {});
          ToastUtil.showToast("Hardware kit paired successfully");
          Navigator.of(context).pop();
        } else {
          ToastUtil.showToast(response.message ?? "");
          setState(() {
            isLoadingPairButton = false;
            _codeController.text = "";
          });
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
        setState(() {
          isLoadingPairButton = false;
          _codeController.text = "";
        });
      }
    });
  }

  _openNotifLogs() {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return const ViewNotificationsSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _showAddCropFlow();
        },
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Row(
                children: [
                  Text(
                    _greetBasedOnTime(),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ColorStyle.lightTextColor),
                  ),
                  const Spacer(),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: ColorStyle.darkPrimaryColor,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                      ),
                      onPressed: () => _openNotifLogs(),
                      color: ColorStyle.whiteColor,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Ink(
                    decoration: const ShapeDecoration(
                      color: ColorStyle.darkPrimaryColor,
                      shape: CircleBorder(),
                    ),
                    child: showSignoutLoading
                        ? const CircularProgressIndicator(
                            color: ColorStyle.lightTextColor,
                            strokeWidth: 2,
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.logout_outlined,
                            ),
                            onPressed: () => _signOutUser(),
                            color: ColorStyle.whiteColor,
                            visualDensity: VisualDensity.compact,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: showPageLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          weather == null
                              ? Container()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Today’s Weather",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: ColorStyle.lightTextColor),
                                    ),
                                    const SizedBox(height: 20),
                                    _buildWeatherWidget(),
                                  ],
                                ),
                          const SizedBox(height: 30),
                          const Text(
                            "Your Crops",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: ColorStyle.lightTextColor),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: crops!.isEmpty
                                ? _buildEmptyCropsWidget()
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: crops!.length,
                                    itemBuilder: (context, index) =>
                                        _buildCropTileWidget(index),
                                  ),
                          ),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _showAddCropFlow() async {
    Crop? addedCrop = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return const AddCropSheet();
      },
    );

    if (addedCrop != null) {
      if (crops != null) {
        crops!.add(addedCrop);
      } else {
        crops = [addedCrop];
      }
      setState(() {});

      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        _pairHardwareDialog(addedCrop);
        // bool? isPaired = await showModalBottomSheet(
        //   useRootNavigator: true,
        //   isScrollControlled: true,
        //   useSafeArea: true,
        //   context: context,
        //   builder: (BuildContext ctx) {
        //     return const PairHardwareSheet();
        //   },
        // );
      });
    }
  }

  _buildCropTileWidget(int index) {
    return GestureDetector(
      onTap: () {
        if (crops![index].hardware == null) {
          _pairHardwareDialog(crops![index]);
        } else {
          Navigator.of(context).pushNamed(
            cropDetailsRoute,
            arguments: CropArgs(cropName: crops![index].title!),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ColorStyle.secondaryBackgroundColor,
          border: const Border(
              left: BorderSide(color: ColorStyle.primaryColor, width: 6)),
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 10,
                color: ColorStyle.blackColor.withOpacity(0.1))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              crops![index].title ?? "",
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorStyle.textColor),
            ),
            Text(
                (crops![index].hardware != null)
                    ? crops![index].cropHealthStatus ?? "Undetermined"
                    : "Hardware Unpaired",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorStyle.alertColor))
          ],
        ),
      ),
    );
  }

  _buildEmptyCropsWidget() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            child: SvgPicture.asset('assets/svgs/home_image.svg'),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            "You currently have no crops added press \"+\" to add some and get started",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: ColorStyle.lightTextColor),
          ),
        ),
      ],
    );
  }

  _buildWeatherWidget() {
    return Container(
      width: double.maxFinite,
      height: 155,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorStyle.secondaryBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${weather?.current?.temperature2M?.round()}° ${_getWeatherDescription(weather!.current!.weatherCode!)}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.textColor),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
                decoration: BoxDecoration(
                    color: ColorStyle.lightTextColor,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  (weather?.current?.precipitation?.round() == 0)
                      ? "No Rain"
                      : "${weather?.current?.precipitation?.round()}% Rain",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorStyle.backgroundColor),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.maxFinite,
            height: 80,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: weather?.hourly?.length ?? 0,
                itemBuilder: (context, index) =>
                    _buildDayWeatherWidget(index, weather!.hourly![index])),
          )
        ],
      ),
    );
  }

  _buildDayWeatherWidget(int index, Hourly data) {
    return Container(
      margin: EdgeInsets.only(left: index == 0 ? 0 : 10, right: 10),
      child: Column(
        children: [
          Text(
            DateFormat("ha").format(data.time!),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorStyle.textColor),
          ),
          const SizedBox(
            height: 5,
          ),
          SvgPicture.asset(
            "assets/svgs/weather/${_getWeatherSVG(data.weatherCode!)}",
            height: 30,
            width: 30,
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            "${data.temperature2M?.round()}° (${data.precipitationProbability?.round()}%)",
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ColorStyle.textColor),
          ),
        ],
      ),
    );
  }

  String _getWeatherDescription(int code) {
    Map<int, String> weatherDescriptions = {
      0: 'Clear',
      1: 'Clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Fog',
      51: 'Drizzle',
      53: 'Drizzle',
      55: 'Drizzle',
      56: 'Drizzle',
      57: 'Drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      66: 'Light rain',
      67: 'Heavy rain',
      71: 'Snow fall',
      73: 'Snow fall',
      75: 'Heavy snow fall',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with hail',
      99: 'Thunderstorm with hail'
    };

    return weatherDescriptions[code] ?? 'Unknown weather code';
  }

  String _getWeatherSVG(int code) {
    if (code == 1 || code == 2 || code == 3) {
      return 'cloud.svg';
    } else if (code == 45 || code == 48) {
      return 'cloud.svg';
    } else if (code == 51 ||
        code == 53 ||
        code == 55 ||
        code == 56 ||
        code == 57 ||
        code == 61 ||
        code == 63 ||
        code == 65 ||
        code == 66 ||
        code == 67 ||
        code == 80 ||
        code == 81 ||
        code == 82) {
      return 'rain.svg';
    } else if (code == 71 ||
        code == 73 ||
        code == 75 ||
        code == 77 ||
        code == 85 ||
        code == 86) {
      return 'snow.svg';
    } else if (code == 95 || code == 96 || code == 99) {
      return 'thunder.svg';
    } else {
      return 'sun.svg';
    }
  }

  _pairHardwareDialog(Crop crop) {
    Dialog errorDialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      elevation: 2.0,
      backgroundColor: ColorStyle.secondaryBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25.0),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Center(
                child: Text(
                  "Pair Hardware Kit",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorStyle.textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text(
                  "Please enter the pairing code shipped with your farm hardware kit",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: ColorStyle.textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                controller: _codeController,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.text,
                defaultPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                  color: ColorStyle.secondaryPrimaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(300),
                )),
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsRetrieverApi,
                focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: ColorStyle.secondaryPrimaryColor.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                        color: ColorStyle.primaryColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w600)),
                submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: ColorStyle.lightTextColor,
                      borderRadius: BorderRadius.circular(300),
                    ),
                    textStyle: const TextStyle(
                        color: ColorStyle.primaryColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w600)),
                onChanged: (value) {
                  _codeController.text = _codeController.text.toUpperCase();
                  if (value.length < 6) {
                    setState(() {
                      isCodeInputValid = false;
                    });
                  } else {
                    setState(() {
                      isCodeInputValid = true;
                    });
                  }
                },
                onCompleted: (value) {
                  setState(() {
                    isCodeInputValid = true;
                  });
                  //_associateHardware(crop, _codeController.text);
                },
                showCursor: true,
                cursor: cursor,
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                    height: 55,
                    width: double.maxFinite,
                    child: CustomRoundedButton(
                      "Pair",
                      () {
                        _associateHardware(crop, _codeController.text);
                      },
                      widgetButton: isLoadingPairButton
                          ? LoadingUtil.showInButtonLoader()
                          : null,
                      // borderColor: ColorStyle.whiteColor,
                      borderColor: ColorStyle.whiteColor,
                      buttonBackgroundColor: isCodeInputValid
                          ? ColorStyle.secondaryPrimaryColor
                          : ColorStyle.secondaryPrimaryColor.withOpacity(0.3),
                      textColor: ColorStyle.whiteColor,
                      waterColor: ColorStyle.primaryColor,
                    )),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: SizedBox(
                    height: 55,
                    width: double.maxFinite,
                    child: CustomRoundedButton(
                      "Maybe later",
                      () {
                        Navigator.of(context).pop();
                      },
                      borderColor: ColorStyle.secondaryPrimaryColor,
                      buttonBackgroundColor: ColorStyle.whiteColor,
                      textColor: ColorStyle.secondaryPrimaryColor,
                      waterColor: ColorStyle.primaryColor,
                    )),
              )
            ],
          ),
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => errorDialog,
        barrierColor: const Color(0x59000000));
  }

  final defaultPinTheme = const PinTheme(
    width: 40,
    height: 40,
    textStyle: TextStyle(
        color: Color.fromRGBO(70, 69, 66, 1),
        fontSize: 25,
        fontWeight: FontWeight.w400),
  );

  final cursor = Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: 21,
      height: 1,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(137, 146, 160, 1),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
