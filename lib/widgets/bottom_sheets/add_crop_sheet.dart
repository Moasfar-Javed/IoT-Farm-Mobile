import 'package:farm/models/api/crop/add/add_crop_response.dart';
import 'package:farm/models/api/crop/crop.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/loading_util.dart';
import 'package:farm/utility/picker_util.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/buttons/custom_rounded_button.dart';
import 'package:farm/widgets/inputs/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

class AddCropSheet extends StatefulWidget {
  const AddCropSheet({super.key});

  @override
  State<AddCropSheet> createState() => _AddCropSheetState();
}

class _AddCropSheetState extends State<AddCropSheet> {
  final TextEditingController _cropTitleController = TextEditingController();
  final TextEditingController _releaseDurationController =
      TextEditingController();
  final TextEditingController _releaseTimeController = TextEditingController();
  bool smartIrrigation = true;
  bool maintainLogs = true;
  bool isInputValid = false;
  DateTime? _releaseTime;
  bool isLoadingResponse = false;

  CropService cropService = CropService();

  @override
  initState() {
    _cropTitleController.addListener(() => _fieldValidation());
    _releaseDurationController.addListener(() => _fieldValidation());
    _releaseTimeController.addListener(() => _fieldValidation());
    super.initState();
  }

  _fieldValidation() {
    if (_cropTitleController.text != "" &&
        _releaseDurationController.text != "" &&
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

  _addCropToServer() {
    if (!isInputValid) {
      ToastUtil.showToast("Please fill out all the fields");
    } else {
      setState(() {
        isLoadingResponse = true;
      });
      cropService
          .addCrop(
              _cropTitleController.text.trim(),
              _releaseDurationController.text.trim(),
              _releaseTime!.toIso8601String(),
              smartIrrigation,
              maintainLogs)
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
                            const Text(
                              "Create Crop/Zone",
                              style: TextStyle(
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
                            CustomTextField(
                              controller: _releaseDurationController,
                              hint: "Release Duration (mins)",
                              fieldColor: ColorStyle.backgroundColor,
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
                                  hint: "Release Time",
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  FlutterSwitch(
                                      width: 40.0,
                                      height: 20.0,
                                      toggleSize: 13.0,
                                      borderRadius: 20.0,
                                      showOnOff: false,
                                      activeColor: ColorStyle.darkPrimaryColor,
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  FlutterSwitch(
                                      width: 40.0,
                                      height: 20.0,
                                      toggleSize: 13.0,
                                      borderRadius: 20.0,
                                      showOnOff: false,
                                      activeColor: ColorStyle.darkPrimaryColor,
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
                        "Add New Crop / Zone",
                        () => _addCropToServer(),
                        widgetButton: isLoadingResponse
                            ? LoadingUtil.showInButtonLoader()
                            : null,
                        borderColor: ColorStyle.whiteColor,
                        buttonBackgroundColor: isInputValid
                            ? ColorStyle.whiteColor
                            : Colors.transparent,
                        textColor: isInputValid
                            ? ColorStyle.blackColor
                            : ColorStyle.whiteColor,
                        waterColor: Colors.black12,
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
    );
  }
}
