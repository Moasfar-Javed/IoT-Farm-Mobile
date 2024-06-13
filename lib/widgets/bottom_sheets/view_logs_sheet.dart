import 'package:farm/main.dart';
import 'package:farm/models/api/irrigation/irrigation.dart';
import 'package:farm/models/api/reading/reading.dart';
import 'package:farm/styles/color_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewLogsSheet extends StatefulWidget {
  final List<Irrigation>? irrigations;
  final List<Reading>? readings;
  const ViewLogsSheet({super.key, this.irrigations, this.readings});

  @override
  State<ViewLogsSheet> createState() => _ViewLogsSheetState();
}

class _ViewLogsSheetState extends State<ViewLogsSheet> {
  List<Irrigation>? irrigations;
  List<Reading>? readings;
  late bool forReadings;

  @override
  void initState() {
    irrigations = widget.irrigations;
    readings = widget.readings;
    if (readings != null) {
      forReadings = true;
    } else {
      forReadings = false;
    }
    super.initState();
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            forReadings ? "Moisture Logs" : "Irrigation Logs",
                            style: const TextStyle(
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
                      height: 10,
                    ),
                    forReadings
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 15),
                            decoration: BoxDecoration(
                              color: ColorStyle.darkPrimaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Average",
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: ColorStyle.whiteColor),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    "${_getAvgReading()}%",
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: ColorStyle.whiteColor),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: ColorStyle.darkPrimaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Status",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: ColorStyle.whiteColor),
                                    ),
                                    Text(
                                      _getWaterStatus(),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ColorStyle.whiteColor),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: ColorStyle.darkPrimaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Average",
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: ColorStyle.whiteColor),
                                    ),
                                    Text(
                                      _getAvgRelease(),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: ColorStyle.whiteColor),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                        child: Scrollbar(
                      thumbVisibility: true,
                      child: ListView.builder(
                        itemCount: forReadings
                            ? readings!.length
                            : irrigations!.length,
                        itemBuilder: (context, index) => forReadings
                            ? _buildReadingWidget(index)
                            : _buildIrrigationWidget(index),
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getAvgRelease() {
    num totalDuration = 0;
    num avgDuration = 0;
    if (irrigations!.isNotEmpty) {
      for (var irrigation in irrigations!) {
        totalDuration += irrigation.releaseDuration!;
      }
      avgDuration = totalDuration / irrigations!.length;
    }
    return "${formatToFixedOnePoint(avgDuration)} mins";
  }

  String _getWaterStatus() {
    if (irrigations!.isEmpty) {
      return "WATER OFF";
    } else {
      if (irrigations!.first.waterOn ?? false) {
        return "WATER ON";
      } else {
        return "WATER OFF";
      }
    }
  }

  String _getAvgReading() {
    num totalDuration = 0;
    num avgDuration = 0;
    if (readings!.isNotEmpty) {
      for (var reading in readings!) {
        totalDuration += reading.moisture!;
      }
      avgDuration = totalDuration / readings!.length;
    }
    return "${formatToFixedOnePoint(avgDuration)}";
  }

  _buildReadingWidget(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: ColorStyle.whiteColor,
        border: Border(
          bottom: BorderSide(
            color: ColorStyle.lightPrimaryColor,
          ),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildDetailsCellWidget(
                  "Value", "${readings![index].moisture!}%"),
              Text(
                DateFormat('dd MMMM, yy - hh:mm a')
                    .format(toLocalTime(readings![index].createdOn!)),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.secondaryPrimaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildIrrigationWidget(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: ColorStyle.whiteColor,
        border: Border.all(
          // bottom: BorderSide(
          color: ColorStyle.lightPrimaryColor,
          // ),
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 10,
              color: ColorStyle.blackColor.withOpacity(0.1))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (irrigations![index].manual ?? false) ? "Manual" : "Smart",
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ColorStyle.textColor),
                ),
              ),
              Text(
                DateFormat('dd MMMM, yy - hh:mm a')
                    .format(toLocalTime(irrigations![index].releasedOn!)),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: ColorStyle.secondaryPrimaryColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildDetailsCellWidget(
                  "Duration",
                  "${irrigations![index].releaseDuration} mins",
                ),
                _buildDetailsCellWidget(
                    "Soil Status",
                    capitalizeFirstLetter(
                        irrigations![index].soilCondition ?? "---")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildDetailsCellWidget(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}
