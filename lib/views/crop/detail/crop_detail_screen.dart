import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:event_bus/event_bus.dart';
import 'package:farm/main.dart';
import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/crop/detail/crop_detail_response.dart';
import 'package:farm/models/api/generic/generic_response.dart';
import 'package:farm/models/api/irrigation/irrigation.dart';
import 'package:farm/models/api/reading/reading.dart';
import 'package:farm/models/event_bus/refresh_crops.dart';
import 'package:farm/models/screen_args/crop_args.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/views/home/home_screen.dart';
import 'package:farm/widgets/bottom_sheets/add_crop_sheet.dart';
import 'package:farm/widgets/bottom_sheets/analytics_sheet.dart';
import 'package:farm/widgets/bottom_sheets/view_logs_sheet.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:farm/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class CropDetailScreen extends StatefulWidget {
  final CropArgs arguments;
  static final eventBus = EventBus();
  const CropDetailScreen({super.key, required this.arguments});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  final TextEditingController _releaseDurationController =
      TextEditingController();
  CropService cropService = CropService();
  bool showPageLoading = false;
  bool isLoadingReleaseButton = false;
  bool isCodeInputValid = false;
  List<Irrigation> irrigations = [];
  List<Reading> readings = [];
  Crop? crop;
  bool hardwareConnected = false;
  DateTime lastRefreshed = DateTime.now();

  @override
  initState() {
    _getCropDetails();
    super.initState();
    CropDetailScreen.eventBus.on<RefreshCropsEvent>().listen(
      (event) {
        if (mounted && !showPageLoading) {
          _getCropDetails();
        }
      },
    );
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  num formatToFixedOnePoint(num input) {
    return num.parse(input.toStringAsFixed(1));
  }

  _getCropDetails() async {
    setState(() {
      showPageLoading = true;
    });
    cropService.getCropDetail(widget.arguments.cropName).then((value) {
      setState(() {
        showPageLoading = false;
      });

      if (value.error == null) {
        CropDetailResponse response = value.snapshot;
        if (response.success ?? false) {
          crop = response.data?.crop;
          readings = response.data?.readings ?? [];
          irrigations = response.data?.irrigations ?? [];
          hardwareConnected = response.data?.connection ?? false;
          lastRefreshed = DateTime.now();
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

  _deleteCrop() async {
    final result = await showOkCancelAlertDialog(
        context: context,
        title: 'Confirmation',
        message:
            'Are you sure you want to delete this crop. All the associated data will be deleted as well. This action is irreversible');
    if (result == OkCancelResult.ok) {
      setState(() {
        showPageLoading = true;
      });
      cropService.deleteCrop(widget.arguments.cropName).then((value) {
        setState(() {
          showPageLoading = false;
        });

        if (value.error == null) {
          GenericResponse response = value.snapshot;
          if (response.success ?? false) {
            HomeScreen.eventBus.fire(RefreshCropsEvent());
            Navigator.of(context).pop();
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
  }

  _manuallyRelease(int duration) async {
    setState(() {
      isLoadingReleaseButton = true;
    });
    cropService
        .manuallyRelease(duration, widget.arguments.cropName)
        .then((value) {
      setState(() {
        isLoadingReleaseButton = false;
      });

      if (value.error == null) {
        GenericResponse response = value.snapshot;
        if (response.success ?? false) {
          Navigator.of(context).pop();
          _getCropDetails();
          HomeScreen.eventBus.fire(RefreshCropsEvent());
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

  _startCropEditFlow() async {
    Crop? addedCrop = await showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return AddCropSheet(
          crop: crop,
        );
      },
    );

    if (addedCrop != null) {
      widget.arguments.cropName = addedCrop.title!;
      _getCropDetails();
      HomeScreen.eventBus.fire(RefreshCropsEvent());
    }
  }

  _openLogs(bool forReadings) async {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return ViewLogsSheet(
          readings: forReadings ? readings : null,
          irrigations: !forReadings ? irrigations : null,
        );
      },
    );
  }

  _openAnalytics() async {
    showModalBottomSheet(
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return AnalyticsSheet(
          cropName: widget.arguments.cropName,
        );
      },
    );
  }

  Color _getColorByHealth(String? health) {
    if (health == "poor") {
      return ColorStyle.errorColor;
    } else if (health == "needs_attention") {
      return ColorStyle.warningColor;
    } else if (health == "healthy") {
      return ColorStyle.primaryColor;
    } else {
      return ColorStyle.secondaryPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 25),
              _buildHeaderWidget(),
              const SizedBox(height: 5),
              Expanded(
                child: showPageLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            _buildHealthWidget(),
                            const SizedBox(height: 30),
                            _buildConnectionWidget(),
                            const SizedBox(height: 30),
                            _buildDetailsWidget(),
                            const SizedBox(height: 30),
                            _buildIrrigationWidget(),
                            const SizedBox(height: 30),
                            _buildMoistureWidget(),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildMoistureWidget() {
    return GestureDetector(
      onTap: () => _openLogs(true),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: ColorStyle.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 10,
                color: ColorStyle.blackColor.withOpacity(0.1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Moisture",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ColorStyle.primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    "assets/svgs/humidity_image.svg",
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Last Recorded: ",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ColorStyle.darkPrimaryColor),
                ),
                Text(
                  "${_getLastMoisture()}%",
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorStyle.darkPrimaryColor),
                ),
              ],
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                children: [
                  _buildDetailsCellWidget("Avg Value", "${_getAvgReading()}%"),
                  const VerticalDivider(
                    color: ColorStyle.secondaryPrimaryColor,
                  ),
                  _buildDetailsCellWidget("Last Recording", _getLastReading()),
                  const VerticalDivider(
                    color: ColorStyle.secondaryPrimaryColor,
                  ),
                  _buildDetailsCellWidget("Next Recording", _getNextReading()),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildIrrigationWidget() {
    return GestureDetector(
      onTap: () => _openLogs(false),
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: ColorStyle.whiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                offset: const Offset(0, 4),
                blurRadius: 10,
                color: ColorStyle.blackColor.withOpacity(0.1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Irrigation",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: ColorStyle.primaryColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    "assets/svgs/tap_image.svg",
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CustomRoundedButton(
                  "",
                  () => _manualReleaseDialog(),
                  leftPadding: 5,
                  rightPadding: 5,
                  widgetButton: const Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        color: ColorStyle.primaryColor,
                        size: 18,
                      ),
                      Text(
                        "Override",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.double,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ColorStyle.primaryColor),
                      ),
                    ],
                  ),
                  buttonBackgroundColor: ColorStyle.whiteColor,
                  borderColor: ColorStyle.whiteColor,
                  waterColor: ColorStyle.lightPrimaryColor,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: ColorStyle.darkPrimaryColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getWaterStatus(),
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.whiteColor),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                children: [
                  _buildDetailsCellWidget(
                    "Last Irrigation",
                    _getLastIrrigation(),
                  ),
                  const VerticalDivider(
                    color: ColorStyle.secondaryPrimaryColor,
                  ),
                  _buildDetailsCellWidget("Avg Release", _getAvgRelease()),
                  const VerticalDivider(
                    color: ColorStyle.secondaryPrimaryColor,
                  ),
                  _buildDetailsCellWidget("Soil Status", _getSoilStatus()),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildDetailsWidget() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: ColorStyle.whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 10,
              color: ColorStyle.blackColor.withOpacity(0.1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Details",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 25,
                width: 25,
                child: SvgPicture.asset(
                  "assets/svgs/info_image.svg",
                  color: ColorStyle.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailsCellWidget(
                  "Name", capitalizeFirstLetter(crop?.title ?? '')),
              _buildDetailsCellWidget(
                  "Type", capitalizeFirstLetter(crop?.type ?? '')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailsCellWidget(
                  "Release Time",
                  DateFormat("hh:mm a")
                      .format(toLocalTime(crop!.preferredReleaseTime!))),
              _buildDetailsCellWidget(
                  "Hardware ID",
                  crop?.hardware == null
                      ? 'Unpaired'
                      : crop?.hardware?.sensorId ?? ""),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDetailsCellWidget(
                  "Auto Irrigate", crop!.automaticIrrigation! ? "Yes" : "No"),
              _buildDetailsCellWidget(
                  "Keep Logs", crop!.maintainLogs! ? "Yes" : "No"),
            ],
          )
        ],
      ),
    );
  }

  _buildDetailsCellWidget(String title, String value, {bool alignEnd = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: ColorStyle.secondaryPrimaryColor),
          ),
          Text(
            value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorStyle.textColor),
          ),
        ],
      ),
    );
  }

  _buildConnectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorStyle.whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  color: ColorStyle.blackColor.withOpacity(0.1))
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    "assets/svgs/wifi_image.svg",
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Hardware Status",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ),
              Text(
                hardwareConnected ? "Connected" : "Offline",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: hardwareConnected
                        ? ColorStyle.primaryColor
                        : ColorStyle.warningColor),
              ),
            ],
          ),
        ),
        Visibility(
          visible: !hardwareConnected,
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.maxFinite,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: ColorStyle.secondaryPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: ColorStyle.secondaryPrimaryColor, width: 2)),
            child: const Text(
              "The sensor may come online automatically, try refreshing the page",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorStyle.secondaryPrimaryColor),
            ),
          ),
        ),
      ],
    );
  }

  _buildHealthWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ColorStyle.whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                  color: ColorStyle.blackColor.withOpacity(0.1))
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: SvgPicture.asset(
                  "assets/svgs/health_image.svg",
                  color: ColorStyle.primaryColor,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Health Status",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorStyle.primaryColor,
                  ),
                ),
              ),
              Text(
                crop?.cropHealthStatus == null
                    ? "Undermined"
                    : capitalizeFirstLetter(crop?.cropHealthStatus ?? ""),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getColorByHealth(crop?.cropHealthStatus)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: _getColorByHealth(crop?.cropHealthStatus).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _getColorByHealth(crop?.cropHealthStatus), width: 2)),
          child: Text(
            _getMessageByHealth(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ColorStyle.secondaryPrimaryColor),
          ),
        ),
      ],
    );
  }

  _buildHeaderWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Ink(
              decoration: const ShapeDecoration(
                // color: ColorStyle.darkPrimaryColor,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                ),
                onPressed: () => Navigator.of(context).pop(),
                color: ColorStyle.secondaryPrimaryColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  widget.arguments.cropName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: ColorStyle.lightTextColor),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Ink(
              decoration: const ShapeDecoration(
                color: ColorStyle.darkPrimaryColor,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () => _startCropEditFlow(),
                color: ColorStyle.whiteColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Ink(
              decoration: const ShapeDecoration(
                color: ColorStyle.darkPrimaryColor,
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                onPressed: () => _deleteCrop(),
                color: ColorStyle.whiteColor,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        Row(
          children: [
            CustomRoundedButton(
              "",
              () => _openAnalytics(),
              roundedCorners: 18,
              widgetButton: const Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: ColorStyle.whiteColor,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Analytics",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.double,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.whiteColor),
                  ),
                ],
              ),
              buttonBackgroundColor: ColorStyle.primaryColor,
              borderColor: ColorStyle.whiteColor,
              waterColor: ColorStyle.lightPrimaryColor,
            ),
            const SizedBox(width: 10),
            CustomRoundedButton(
              "",
              () => _getCropDetails(),
              roundedCorners: 18,
              widgetButton: const Row(
                children: [
                  Icon(
                    Icons.refresh_outlined,
                    color: ColorStyle.whiteColor,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Refresh",
                    style: TextStyle(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.double,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorStyle.whiteColor),
                  ),
                ],
              ),
              buttonBackgroundColor: ColorStyle.primaryColor,
              borderColor: ColorStyle.whiteColor,
              waterColor: ColorStyle.lightPrimaryColor,
            ),
            _buildDetailsCellWidget(
                "Last refreshed", DateFormat('hh:mm a').format(lastRefreshed),
                alignEnd: true)
          ],
        )
      ],
    );
  }

  String _getNextReading() {
    if (readings.isNotEmpty) {
      return DateFormat('hh:mm a').format(
        toLocalTime(
          readings.first.createdOn!.add(
            const Duration(hours: 1),
          ),
        ),
      );
    } else {
      return "---";
    }
  }

  String _getLastReading() {
    if (readings.isNotEmpty) {
      return DateFormat('hh:mm a').format(
        toLocalTime(readings.first.createdOn!),
      );
    } else {
      return "---";
    }
  }

  String _getAvgReading() {
    num totalDuration = 0;
    num avgDuration = 0;
    if (readings.isNotEmpty) {
      for (var reading in readings) {
        totalDuration += reading.moisture!;
      }
      avgDuration = totalDuration / readings.length;
    }
    return "${formatToFixedOnePoint(avgDuration)}";
  }

  String _getLastMoisture() {
    if (readings.isEmpty) {
      return "---";
    } else {
      return formatToFixedOnePoint(readings.first.moisture!).toString();
    }
  }

  String _getSoilStatus() {
    if (irrigations.isEmpty) {
      return "---";
    } else {
      return capitalizeFirstLetter(irrigations.first.soilCondition ?? "---");
    }
  }

  String _getAvgRelease() {
    num totalDuration = 0;
    num avgDuration = 0;
    if (irrigations.isNotEmpty) {
      for (var irrigation in irrigations) {
        totalDuration += irrigation.releaseDuration!;
      }
      avgDuration = totalDuration / irrigations.length;
    }
    return "${formatToFixedOnePoint(avgDuration)} mins";
  }

  String _getLastIrrigation() {
    if (irrigations.isEmpty) {
      return "---";
    } else {
      return DateFormat("hh:mm a")
          .format(toLocalTime(irrigations.first.createdOn!));
    }
  }

  String _getWaterStatus() {
    if (irrigations.isEmpty) {
      return "WATER OFF";
    } else {
      if (irrigations.first.waterOn ?? false) {
        return "WATER ON";
      } else {
        return "WATER OFF";
      }
    }
  }

  String _getMessageByHealth() {
    switch (crop?.cropHealthStatus) {
      case "poor":
        {
          return "This Crop/Zone is in need of urgent human care, please tend to it and irrigate or it may die out";
        }
      case "needs_attention":
        {
          return "This Crop/Zone is in need of human attention, please tend to it as it maybe at the risk of being dried out";
        }
      case "healthy":
        {
          return "This Crop/Zone is healthy";
        }
      default:
        {
          return "We need more data from your sensors to come in to evaluate the health status.\nExpected to be evaluated at the next ${DateFormat("hh:mm a").format(toLocalTime(crop!.preferredReleaseTime!))}";
        }
    }
  }

  _manualReleaseDialog() {
    _releaseDurationController.removeListener(() {});
    _releaseDurationController.text = "";
    Dialog errorDialog = Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      elevation: 2.0,
      backgroundColor: ColorStyle.secondaryBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25.0),
        child: StatefulBuilder(
          builder: (context, setState) {
            _releaseDurationController.addListener(() {
              int? value = int.tryParse(_releaseDurationController.text);
              if (value != null && value != 0) {
                isCodeInputValid = true;
              } else {
                isCodeInputValid = false;
              }
              print(isCodeInputValid);
              setState(() {});
            });
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Center(
                  child: Text(
                    "Manual Release",
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
                    "Please enter the duration (in mins). The water will turn off automatically after this period. This action can not be reversed",
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
                CustomTextField(
                  controller: _releaseDurationController,
                  hint: "Duration (mins)",
                  keyboardType: TextInputType.number,
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
                        "Release",
                        () {
                          int? duration =
                              int.tryParse(_releaseDurationController.text);
                          if (duration == null) return;

                          _manuallyRelease(duration);
                        },
                        widgetButton: isLoadingReleaseButton
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
              ],
            );
          },
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => errorDialog,
        barrierColor: const Color(0x59000000));
  }
}
