import 'package:farm/models/api/analytic/analytic.dart';
import 'package:farm/models/api/analytic/response/analytics_response.dart';
import 'package:farm/services/crop_service.dart';
import 'package:farm/styles/color_style.dart';
import 'package:farm/utility/toast_util.dart';
import 'package:farm/widgets/line_chart.dart';

import 'package:flutter/material.dart';

class AnalyticsSheet extends StatefulWidget {
  final String cropName;
  const AnalyticsSheet({super.key, required this.cropName});

  @override
  State<AnalyticsSheet> createState() => _AnalyticsSheetState();
}

class _AnalyticsSheetState extends State<AnalyticsSheet> {
  List<Analytic> irrigationAnalytics = [];
  List<Analytic> readingsAnalytics = [];
  String irrigationFilter = "Daily";
  String readingFilter = "Daily";
  CropService cropService = CropService();
  bool showIrrigationLoading = false;
  bool showReadingLoading = false;

  List<Color> gradientColors = [
    ColorStyle.primaryColor,
    ColorStyle.lightPrimaryColor
  ];

  bool showAvg = false;

  @override
  void initState() {
    _getAnalytics(true);
    _getAnalytics(false);
    super.initState();
  }

  String _getFilter(bool forIrrigation) {
    String currFilter;
    if (forIrrigation) {
      currFilter = irrigationFilter;
    } else {
      currFilter = readingFilter;
    }

    print(currFilter);

    switch (currFilter) {
      case "Daily":
        {
          return "day";
        }
      case "Weekly":
        {
          return "week";
        }
      case "Monthly":
        {
          return "month";
        }
      default:
        {
          return "day";
        }
    }
  }

  _getAnalytics(bool forIrrigation) async {
    setState(() {
      forIrrigation ? showIrrigationLoading = true : showReadingLoading = true;
    });
    cropService
        .getAnalytics(
      forIrrigation,
      widget.cropName,
      _getFilter(forIrrigation),
    )
        .then((value) {
      if (value.error == null) {
        setState(() {
          forIrrigation
              ? showIrrigationLoading = false
              : showReadingLoading = false;
        });
        AnalyticsResponse response = value.snapshot;
        if (response.success ?? false) {
          forIrrigation
              ? irrigationAnalytics = response.data?.mappedData ?? []
              : readingsAnalytics = response.data?.mappedData ?? [];
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).viewInsets.bottom == 0
                ? MediaQuery.of(context).size.height * 0.8
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Analytics",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ColorStyle.primaryColor),
                          ),
                        ),
                        Ink(
                          decoration: const ShapeDecoration(
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            color: ColorStyle.secondaryPrimaryColor,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: (showIrrigationLoading && showReadingLoading)
                          ? const Center(
                              child: LinearProgressIndicator(),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Irrigations",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: ColorStyle.textColor),
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: irrigationFilter,
                                        iconSize: 24,
                                        elevation: 16,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: ColorStyle.lightTextColor),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            irrigationFilter = newValue!;
                                          });
                                          _getAnalytics(true);
                                        },
                                        items: <String>[
                                          'Daily',
                                          'Weekly',
                                          'Monthly',
                                        ] // List of dropdown items
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                  showIrrigationLoading
                                      ? const Center(
                                          child: LinearProgressIndicator(),
                                        )
                                      : CustomLineChart(
                                          chartData: irrigationAnalytics,
                                          filter: _getFilter(true),
                                        ),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          "Readings",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: ColorStyle.textColor),
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: irrigationFilter,
                                        iconSize: 24,
                                        elevation: 16,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: ColorStyle.lightTextColor),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            readingFilter = newValue!;
                                          });
                                          _getAnalytics(false);
                                        },
                                        items: <String>[
                                          'Daily',
                                          'Weekly',
                                          'Monthly',
                                        ] // List of dropdown items
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      )
                                    ],
                                  ),
                                  showReadingLoading
                                      ? const Center(
                                          child: LinearProgressIndicator(),
                                        )
                                      : CustomLineChart(
                                          chartData: readingsAnalytics,
                                          filter: _getFilter(false),
                                        )
                                ],
                              ),
                            ),
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
