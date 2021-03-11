import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_utils.dart';

import 'line_chart_utils.dart';

class LineChartPainter extends CustomPainter {
  final LineChartController controller;
  ValueNotifier<int> startTimestamp;
  ValueNotifier<int> endTimestamp;

  LineChartPainter({this.controller, this.startTimestamp, this.endTimestamp}) : super(repaint: startTimestamp);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid and lines

    canvas.drawRect(
      Rect.fromLTRB(
        controller.settings.chartMargins,
        controller.settings.chartMargins,
        size.width - controller.settings.chartMargins,
        size.height - controller.settings.chartMargins,
      ),
      controller.settings.linesPaint,
    );

    if (controller.lineSerie == null || controller.lineSerie.points.isEmpty) {
      return;
    }

    List<Point> pointSublist = [];
    int firstIndex = controller.lineSerie.points.indexWhere((e) => e.timestamp >= startTimestamp.value);
    int lastIndex = controller.lineSerie.points.indexWhere((e) => e.timestamp >= endTimestamp.value, firstIndex);
    if (firstIndex != -1) {
      pointSublist =
          controller.lineSerie.points.sublist(firstIndex, lastIndex != -1 ? lastIndex : controller.lineSerie.points.length);
    }

    if (pointSublist.isEmpty) {
      return;
    }

    double maxY = pointSublist.map<double>((e) => e.y).reduce(max);
    double minY = pointSublist.map<double>((e) => e.y).reduce(min);
    double margin = controller.settings.pricePercentMargin * (maxY - minY) / 100;
    maxY += margin;
    minY -= margin;

    controller.pixelsPerMs =
        (size.width - 2 * controller.settings.chartMargins) / (endTimestamp.value - startTimestamp.value);
    controller.pixelsPerUSDT = (size.height - 2 * controller.settings.chartMargins) / (maxY - minY);

    // Draw Line Serie
    canvas.drawPoints(
        PointMode.polygon,
        pointSublist
            .map((point) => Offset(
                  (point.timestamp - startTimestamp.value) * controller.pixelsPerMs + controller.settings.chartMargins,
                  (maxY - point.y) * controller.pixelsPerUSDT + controller.settings.chartMargins,
                ))
            .toList(),
        Paint()
          ..color = controller.lineSerie.color
          ..style = PaintingStyle.fill);

    // Draw Y axis labels
    double intervalY = (size.height - 2 * controller.settings.chartMargins) / controller.settings.nbDivisionsYAxis;
    for (int i = 0; i < controller.settings.nbDivisionsYAxis + 1; ++i) {
      double yPos = controller.settings.chartMargins + i * intervalY;
      canvas.drawLine(
        Offset(controller.settings.chartMargins - 5, yPos),
        Offset(controller.settings.chartMargins, yPos),
        controller.settings.linesPaint,
      );
      if (controller.settings.gridVisible) {
        canvas.drawLine(
          Offset(size.width - controller.settings.chartMargins, yPos),
          Offset(controller.settings.chartMargins, yPos),
          controller.settings.gridPaint,
        );
      }

      double y = (controller.settings.chartMargins - yPos) / controller.pixelsPerUSDT + maxY;
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 10,
      );
      final textSpan = TextSpan(
        text: '${y.toStringAsFixed(2)}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.end,
      );
      textPainter.layout(
        minWidth: 40,
        maxWidth: 40,
      );
      textPainter.paint(
        canvas,
        Offset(controller.settings.chartMargins - 50, yPos - 7),
      );
    }

    // Draw X axis labels
    double intervalX = (size.width - 2 * controller.settings.chartMargins) / controller.settings.nbDivisionsXAxis;
    for (int i = 0; i < controller.settings.nbDivisionsXAxis + 1; ++i) {
      double xPos = controller.settings.chartMargins + i * intervalX;
      canvas.drawLine(
        Offset(xPos, size.height - controller.settings.chartMargins + 5),
        Offset(xPos, size.height - controller.settings.chartMargins),
        controller.settings.linesPaint,
      );
      if (controller.settings.gridVisible) {
        canvas.drawLine(
          Offset(xPos, controller.settings.chartMargins),
          Offset(xPos, size.height - controller.settings.chartMargins),
          controller.settings.gridPaint,
        );
      }

      int x = (endTimestamp.value - startTimestamp.value) * i ~/ controller.settings.nbDivisionsXAxis + startTimestamp.value;
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 10,
      );
      final textSpan = TextSpan(
        text: '${getStrFromDate(x)}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout(
        minWidth: 60,
        maxWidth: 60,
      );
      textPainter.paint(
        canvas,
        Offset(xPos - 30, size.height - controller.settings.chartMargins + 5),
      );
    }
  }

  String getStrFromDate(int ts) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(ts);
    DateTime startDate = DateTime.fromMillisecondsSinceEpoch(startTimestamp.value);
    DateTime endDate = DateTime.fromMillisecondsSinceEpoch(endTimestamp.value);
    if (startDate.year != endDate.year) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } else if (startDate.month != endDate.month) {
      return "${date.day.toString().padLeft(2, '0')} ${monthToStr(date.month)}";
    } else if (startDate.day != endDate.day) {
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } else {
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    }
  }

  String monthToStr(int m) {
    switch (m) {
      case 1:
        return "Jan";
        break;
      case 2:
        return "Feb";
        break;
      case 3:
        return "Mar";
        break;
      case 4:
        return "Apr";
        break;
      case 5:
        return "May";
        break;
      case 6:
        return "Jun";
        break;
      case 7:
        return "Jul";
        break;
      case 8:
        return "Aug";
        break;
      case 9:
        return "Sep";
        break;
      case 10:
        return "Oct";
        break;
      case 11:
        return "Nov";
        break;
      case 12:
        return "Dec";
        break;
      default:
        return "Unk";
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return true;
  }
}
