import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/custom_rounded_button.dart';
import 'package:farm/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            minHeight: MediaQuery.of(context).size.height * 0.7),
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
                            onChanged: (value) {
                              _fieldValidation();
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomTextField(
                            controller: _releaseDurationController,
                            hint: "Release Duration",
                            fieldColor: ColorStyle.backgroundColor,
                            onChanged: (value) {
                              _fieldValidation();
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          CustomTextField(
                            controller: _releaseTimeController,
                            hint: "Release Time",
                            fieldColor: ColorStyle.backgroundColor,
                            onChanged: (value) {
                              _fieldValidation();
                            },
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                const Text(
                                  "Automatic Smart Irrigation",
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                const Text(
                                  "Maintain Logs",
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                      "Pair Hardware",
                      () {
                        if (isInputValid) {
                          Map<String, dynamic> cropSettings = {
                            "crop_title": _cropTitleController.text,
                            "release_duration": _releaseDurationController.text,
                            "release_time": _releaseTimeController.text,
                            "smart_irrigation": smartIrrigation,
                            "maintain_logs": maintainLogs,
                          };
                          Navigator.of(context).pop(cropSettings);
                        } else {
                          ToastUtil.showToast("Please fill out all the fields");
                        }
                      },
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
    );
  }
}
