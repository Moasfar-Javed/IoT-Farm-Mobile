import 'package:farm/main.dart';
import 'package:farm/models/api/crop/add/add_crop_response.dart';
import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/models/api/crop/types/crop_types_response.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/picker_util.dart';
import 'package:farm/utility/pref_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:farm/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

class AddCropSheet extends StatefulWidget {
  final Crop? crop;
  const AddCropSheet({super.key, this.crop});

  @override
  State<AddCropSheet> createState() => _AddCropSheetState();
}

class _AddCropSheetState extends State<AddCropSheet> {
  final TextEditingController _cropTitleController = TextEditingController();
  Crop? crop;
  final TextEditingController _releaseTimeController = TextEditingController();
  List<String> cropTypes = [];
  String selectedType = "";
  bool smartIrrigation = true;
  bool maintainLogs = true;
  bool isInputValid = false;
  DateTime? _releaseTime;
  bool isLoadingResponse = false;

  CropService cropService = CropService();

  @override
  initState() {
    crop = widget.crop;

    _getCropTypes();
    if (crop != null) {
      _cropTitleController.text = crop?.title ?? "";
      _releaseTimeController.text = DateFormat('hh:mm a')
          .format(toLocalTime(crop!.preferredReleaseTime!));
      _releaseTime = crop!.preferredReleaseTime!;
      selectedType = crop?.type ?? "";
      smartIrrigation = crop?.automaticIrrigation ?? false;
      maintainLogs = crop?.maintainLogs ?? false;
      Future.delayed(Durations.long1).then((value) => _fieldValidation());
    }
    _cropTitleController.addListener(() => _fieldValidation());
    _releaseTimeController.addListener(() => _fieldValidation());

    super.initState();
  }

  _getCropTypes() async {
    cropService.getCropTypes().then((value) {
      if (value.error == null) {
        CropTypesResponse response = value.snapshot;
        if (response.success ?? false) {
          cropTypes = response.data?.cropTypes ?? [];
          setState(() {});
        } else {
          ToastUtil.showToast(response.message ?? "");
        }
      } else {
        ToastUtil.showToast(value.error ?? "");
      }
    });
  }

  _fieldValidation() {
    if (selectedType != "" &&
        _cropTitleController.text != "" &&
        _releaseTimeController.text != "") {
      setState(() {
        isInputValid = true;
      });
    } else {
      if (isInputValid) {
        setState(() {
          isInputValid = false;
        });
      }
    }
  }

  _updateCropOnServer() {
    if (!isInputValid) {
      ToastUtil.showToast("All fields are required");
    } else {
      setState(() {
        isLoadingResponse = true;
      });
      cropService
          .updateCrop(
        crop!.title!,
        _cropTitleController.text.trim(),
        selectedType,
        _releaseTime!.toUtc().toString(),
        smartIrrigation,
        maintainLogs,
      )
          .then((value) {
        setState(() {
          isLoadingResponse = false;
        });
        if (value.error == null) {
          AddCropResponse response = value.snapshot;

          if (response.success ?? false) {
            Crop? addedCrop = response.data!.crop;
            Navigator.of(context).pop(addedCrop);
          } else {
            ToastUtil.showToast(response.message ?? "");
          }
        } else {
          ToastUtil.showToast(value.error ?? "");
        }
      });
    }
  }

  _addCropToServer() {
    if (!isInputValid) {
      ToastUtil.showToast("All fields are required");
    } else {
      setState(() {
        isLoadingResponse = true;
      });
      cropService
          .addCrop(
        _cropTitleController.text.trim(),
        selectedType,
        _releaseTime!.toUtc().toString(),
        smartIrrigation,
        maintainLogs,
        PrefUtil().getLastLatitude,
        PrefUtil().getLastLongitude,
      )
          .then((value) {
        setState(() {
          isLoadingResponse = false;
        });
        if (value.error == null) {
          AddCropResponse response = value.snapshot;

          if (response.success ?? false) {
            Crop? addedCrop = response.data!.crop;
            Navigator.of(context).pop(addedCrop);
          } else {
            ToastUtil.showToast(response.message ?? "");
          }
        } else {
          ToastUtil.showToast(value.error ?? "");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: AbsorbPointer(
        absorbing: isLoadingResponse,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).viewInsets.bottom == 0
                  ? MediaQuery.of(context).size.height * 0.65
                  : MediaQuery.of(context).size.height * 0.9,
            ),
            child: Scaffold(
              body: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: ColorStyle.backgroundColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                crop != null
                                    ? "Edit Crop/Zone"
                                    : "Create Crop/Zone",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: ColorStyle.textColor),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              CustomTextField(
                                controller: _cropTitleController,
                                hint: "Crop Title",
                                fieldColor: ColorStyle.backgroundColor,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              cropTypes.isEmpty
                                  ? Container()
                                  : Container(
                                      width: double.infinity,
                                      height: 60,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: ColorStyle
                                                .secondaryPrimaryColor
                                                .withOpacity(0.7)),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: selectedType == ""
                                              ? null
                                              : selectedType,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedType = value!;
                                            });
                                            _fieldValidation();
                                          },
                                          items: cropTypes
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          hint: const Text(
                                            "Crop Type",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    ColorStyle.lightTextColor),
                                          ),
                                        ),
                                      ),
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  TimeOfDay? timeOfDay =
                                      await PickerUtil.openTimePicker(context);
                                  if (timeOfDay != null) {
                                    final now = DateTime.now();
                                    final time = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        timeOfDay.hour,
                                        timeOfDay.minute);
                                    _releaseTimeController.text =
                                        DateFormat('h:mm a').format(time);
                                    _releaseTime = time;
                                  }
                                },
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: CustomTextField(
                                    controller: _releaseTimeController,
                                    hint: "Preffered Release Time",
                                    fieldColor: ColorStyle.backgroundColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Automatic Smart Irrigation",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    FlutterSwitch(
                                        width: 40.0,
                                        height: 20.0,
                                        toggleSize: 13.0,
                                        borderRadius: 20.0,
                                        showOnOff: false,
                                        activeColor: ColorStyle.primaryColor,
                                        // inactiveColor: ColorStyle.whiteColor,
                                        value: smartIrrigation,
                                        onToggle: (value) {
                                          setState(() {
                                            smartIrrigation = value;
                                          });
                                        })
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Maintain Logs",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    const Spacer(),
                                    FlutterSwitch(
                                        width: 40.0,
                                        height: 20.0,
                                        toggleSize: 13.0,
                                        borderRadius: 20.0,
                                        showOnOff: false,
                                        activeColor: ColorStyle.primaryColor,
                                        // inactiveColor: ColorStyle.whiteColor,
                                        value: maintainLogs,
                                        onToggle: (value) {
                                          setState(() {
                                            maintainLogs = value;
                                          });
                                        })
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 55,
                        width: double.infinity,
                        child: CustomRoundedButton(
                          crop != null ? "Save Changes" : "Add New Crop / Zone",
                          () {
                            if (crop != null) {
                              _updateCropOnServer();
                            } else {
                              _addCropToServer();
                            }
                          },
                          widgetButton: isLoadingResponse
                              ? LoadingUtil.showInButtonLoader()
                              : null,
                          borderColor: ColorStyle.whiteColor,
                          buttonBackgroundColor: isInputValid
                              ? ColorStyle.secondaryPrimaryColor
                              : ColorStyle.secondaryPrimaryColor
                                  .withOpacity(0.3),
                          textColor: ColorStyle.whiteColor,
                          waterColor: ColorStyle.primaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
