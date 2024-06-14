import 'package:farm/models/api/analytic/analytic.dart';
import 'package:farm/styles/color_style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomLineChart extends StatefulWidget {
  final List<Analytic> chartData;
  final String filter;
  const CustomLineChart(
      {super.key, required this.chartData, required this.filter});

  @override
  State<CustomLineChart> createState() => _CustomLineChartState();
}

class _CustomLineChartState extends State<CustomLineChart> {
  List<Analytic> chartData = [];
  double horizontalWidth = 0.0;
  ScrollController controller = ScrollController();

  @override
  initState() {
    chartData = widget.chartData;
    horizontalWidth = (chartData.length + 2) * (20 + 12);
    super.initState();
  }

  String formatLargeNumber(num number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.round().toString();
    }
  }

  List<Color> gradientColors = [
    ColorStyle.lightPrimaryColor.withOpacity(0.7),
    ColorStyle.lightPrimaryColor.withOpacity(0),
  ];

  int _getYInterval() {
    if (chartData.isEmpty) {
      return 1;
    }
    num maxY = chartData.map((e) => e.y!).reduce((a, b) => a > b ? a : b);
    if (maxY == 0) {
      return 1;
    }
    int maxElements = 4;
    int interval = (maxY / maxElements).ceil();
    // print(interval);
    return interval;
  }

  double _getAvgYInterval() {
    num sum = 0;
    for (var data in chartData) {
      sum += data.y!;
    }
    return sum / chartData.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width > horizontalWidth
                ? MediaQuery.of(context).size.width
                : horizontalWidth,
            height: 200,
            child: LineChart(
              mainData(),
            ),
          ),
        ),
      ),
    );
  }

  Widget sideTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 12,
      color: ColorStyle.secondaryPrimaryColor,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(formatLargeNumber(value).toString(), style: style),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: ColorStyle.secondaryPrimaryColor);

    // Define the mappings
    List<String> hours = List.generate(24, (index) => "$index");
    const daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    String text;
    if (widget.filter == "day") {
      text = hours[value.toInt() % 24];
    } else if (widget.filter == "week") {
      text = daysOfWeek[value.toInt() % 7];
    } else if (widget.filter == "month") {
      text = months[value.toInt() % 12];
    } else {
      text = value.toString();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Text(text, style: style),
      ),
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _getYInterval().toDouble(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: ColorStyle.whiteColor,
            strokeWidth: 0,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: ColorStyle.whiteColor,
            strokeWidth: 0,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 33,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 33,
            interval: _getYInterval().toDouble(),
            getTitlesWidget: sideTitleWidgets,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineBarsData: [
        LineChartBarData(
          spots: chartData
              .map((e) => FlSpot(e.x!.toDouble(), e.y!.toDouble()))
              .toList(),
          isCurved: true,
          color: ColorStyle.primaryColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: _getAvgYInterval(),
            color: ColorStyle.alertColor,
            strokeWidth: 3,
            dashArray: [20, 10],
          ),
        ],
      ),
      lineTouchData: LineTouchData(
          getTouchedSpotIndicator: (barData, spotIndexes) => List.generate(
              spotIndexes.length,
              (index) => TouchedSpotIndicatorData(
                  FlLine(
                      strokeWidth: 15,
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ColorStyle.primaryColor.withOpacity(0),
                            ColorStyle.primaryColor.withOpacity(0.5),
                            ColorStyle.primaryColor.withOpacity(0)
                          ])),
                  FlDotData(
                    getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                        color: ColorStyle.whiteColor,
                        strokeColor: ColorStyle.primaryColor,
                        strokeWidth: 4,
                        radius: 6),
                  ))),
          touchTooltipData: const LineTouchTooltipData()
          // tooltipBgColor: ColorStyle.lightPrimaryColor),
          ),
    );
  }
}
