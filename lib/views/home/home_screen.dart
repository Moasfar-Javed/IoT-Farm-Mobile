import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:farm/keys/route_keys.dart';
import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/crop/list/crop_list_response.dart';
import 'package:farm/models/api/hardware/add/associate_hardware_response.dart';
import 'package:farm/models/api/hardware/hardware.dart';
import 'package:farm/models/api/weather/weather.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/services/hardware_service.dart';
import 'package:farm/services/user_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/bottom_sheets/add_crop_sheet.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';

class HomeScreen extends StatefulWidget {
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

  @override
  void initState() {
    _getCropListWithWeather();
    super.initState();
  }

  _getCropListWithWeather() async {
    cropService.getCropListAndWeather().then((value) {
      setState(() {
        showPageLoading = false;
      });
      if (value.error == null) {
        CropListResponse response = value.snapshot;
        if (response.success ?? false) {
          weather = response.data!.weather;
          crops = response.data!.crops;
        } else {
          ToastUtil.showToast(response.message ?? "");
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
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
                      onPressed: () {},
                      color: ColorStyle.lightTextColor,
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
                            color: ColorStyle.lightTextColor,
                            visualDensity: VisualDensity.compact,
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Today’s Weather",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.lightTextColor),
              ),
              const SizedBox(height: 20),
              _buildWeatherWidget(),
              const SizedBox(height: 30),
              const Text(
                "Your Crops",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: ColorStyle.lightTextColor),
              ),
              const SizedBox(height: 20),
              //_buildEmptyCropsWidget(),
              Expanded(
                child: showPageLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: crops!.length,
                        itemBuilder: (context, index) =>
                            _buildCropTileWidget(index),
                      ),
              ),
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
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          color: ColorStyle.secondaryBackgroundColor,
          border: Border(
              left: BorderSide(color: ColorStyle.primaryColor, width: 6)),
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(8),
          ),
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
            Text(crops![index].cropHealthStatus ?? "Undetermined",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ColorStyle.lightPrimaryColor))
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
            "You currently have no crops added press here to add some",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: ColorStyle.lightTextColor),
          ),
        ),
        SvgPicture.asset('assets/svgs/tutorial_arrow_image.svg'),
      ],
    );
  }

  _buildWeatherWidget() {
    return Container(
      width: double.maxFinite,
      height: 150,
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
              const Text(
                "21°\tSunny",
                style: TextStyle(
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
                child: const Text(
                  "10% Rain",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorStyle.backgroundColor),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  _buildDayWeatherWidget() {
    return Container();
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
                defaultPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                  color: ColorStyle.backgroundColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(300),
                )),
                androidSmsAutofillMethod:
                    AndroidSmsAutofillMethod.smsRetrieverApi,
                focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: BoxDecoration(
                      color: ColorStyle.backgroundColor.withOpacity(0.6),
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
                  _associateHardware(crop, _codeController.text);
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
                      borderColor: ColorStyle.whiteColor,
                      buttonBackgroundColor: isCodeInputValid
                          ? ColorStyle.whiteColor
                          : Colors.transparent,
                      textColor: isCodeInputValid
                          ? ColorStyle.blackColor
                          : ColorStyle.whiteColor,
                      waterColor: Colors.black12,
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
