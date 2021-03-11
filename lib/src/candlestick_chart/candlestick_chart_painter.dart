import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../common_utils.dart';

import 'candlestick_chart_utils.dart';

class CandlestickChartPainter extends CustomPainter {
  final CandlestickChartController controller;
  ValueNotifier<int> startTimestamp;
  ValueNotifier<int> endTimestamp;

  CandlestickChartPainter({this.controller, this.startTimestamp, this.endTimestamp}) : super(repaint: startTimestamp);

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

    if (controller.data.candleSerie == null || controller.data.candleSerie.candles.isEmpty) {
      return;
    }

    List<Candlestick> candleSublist = [];
    int firstIndex = controller.data.candleSerie.candles.indexWhere((e) => e.timestamp >= startTimestamp.value);
    int lastIndex = controller.data.candleSerie.candles.indexWhere((e) => e.timestamp >= endTimestamp.value, firstIndex);
    if (firstIndex != -1) {
      candleSublist = controller.data.candleSerie.candles
          .sublist(firstIndex, lastIndex != -1 ? lastIndex : controller.data.candleSerie.candles.length);
    }
    List<LineSerie> lineSeriesSublist = [];
    if (controller.data.lineSeries.isNotEmpty) {
      for (LineSerie serie in controller.data.lineSeries) {
        if (serie.points.isNotEmpty) {
          lineSeriesSublist.add(LineSerie(
              name: serie.name,
              color: serie.color,
              points: serie.points.where((e) {
                return (e.timestamp >= startTimestamp.value) && (e.timestamp <= endTimestamp.value);
              }).toList()));
        }
      }
    }

    if (candleSublist.isEmpty) {
      return;
    }

    double maxY = candleSublist.map<double>((e) => e.high).reduce(max);
    double minY = candleSublist.map<double>((e) => e.low).reduce(min);
    if (lineSeriesSublist.isNotEmpty) {
      for (LineSerie serie in lineSeriesSublist) {
        double maxi = serie.points.map<double>((e) => e.y).reduce(max);
        double mini = serie.points.map<double>((e) => e.y).reduce(min);
        if (maxi > maxY) maxY = maxi;
        if (mini < minY) minY = mini;
      }
    }
    double margin = controller.settings.pricePercentMargin * (maxY - minY) / 100;
    maxY += margin;
    minY -= margin;

    controller.pixelsPerMs =
        (size.width - 2 * controller.settings.chartMargins) / (endTimestamp.value - startTimestamp.value);
    controller.pixelsPerUSDT = (size.height - 2 * controller.settings.chartMargins) / (maxY - minY);

    // Draw candles
    int msPerCandle = 60000; // If there is only one candle, then it is considered as a 5-min candle.
    if (controller.data.candleSerie.candles.length >= 2) {
      msPerCandle = controller.data.candleSerie.candles[1].timestamp - controller.data.candleSerie.candles[0].timestamp;
    }
    double bodySize =
        ((size.width - 2 * controller.settings.chartMargins) * msPerCandle * controller.data.candleSerie.ratioCandleSpace) /
            (controller.endTsNotifier.value - controller.startTsNotifier.value);
    for (Candlestick candle in candleSublist) {
      Paint paint;
      if (candle.open < candle.close) {
        paint = controller.data.candleSerie.bullPaint;
      } else if (candle.open > candle.close) {
        paint = controller.data.candleSerie.bearPaint;
      } else {
        paint = controller.data.candleSerie.dojiPaint;
      }
      // Draw up wick
      canvas.drawRect(
        Rect.fromLTRB(
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs -
              (controller.data.candleSerie.wickWidth / 2) +
              controller.settings.chartMargins,
          (maxY - candle.high) * controller.pixelsPerUSDT + controller.settings.chartMargins,
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs +
              (controller.data.candleSerie.wickWidth / 2) +
              controller.settings.chartMargins,
          (maxY - max(candle.open, candle.close)) * controller.pixelsPerUSDT + controller.settings.chartMargins,
        ),
        paint,
      );
      // Draw down wick
      canvas.drawRect(
        Rect.fromLTRB(
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs -
              (controller.data.candleSerie.wickWidth / 2) +
              controller.settings.chartMargins,
          (maxY - min(candle.open, candle.close)) * controller.pixelsPerUSDT + controller.settings.chartMargins,
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs +
              (controller.data.candleSerie.wickWidth / 2) +
              controller.settings.chartMargins,
          (maxY - candle.low) * controller.pixelsPerUSDT + controller.settings.chartMargins,
        ),
        paint,
      );

      // Draw body
      canvas.drawRect(
        Rect.fromLTRB(
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs -
              (bodySize / 2) +
              controller.settings.chartMargins,
          (maxY - candle.close) * controller.pixelsPerUSDT + controller.settings.chartMargins,
          (candle.timestamp - startTimestamp.value) * controller.pixelsPerMs +
              (bodySize / 2) +
              controller.settings.chartMargins,
          (maxY - candle.open) * controller.pixelsPerUSDT + controller.settings.chartMargins,
        ),
        paint,
      );
    }

    // Draw Line Series
    lineSeriesSublist.forEach((LineSerie serie) {
      List<Offset> displayedPoints = [];
      serie.points.forEach((Point point) {
        if (point.timestamp >= startTimestamp.value && point.timestamp <= endTimestamp.value) {
          displayedPoints.add(Offset(
            (point.timestamp - startTimestamp.value) * controller.pixelsPerMs + controller.settings.chartMargins,
            (maxY - point.y) * controller.pixelsPerUSDT + controller.settings.chartMargins,
          ));
        }
      });
      canvas.drawPoints(
          PointMode.polygon,
          displayedPoints,
          Paint()
            ..color = serie.color
            ..style = PaintingStyle.fill);
    });

    // Draw Scatter Series
    controller.data.scatterSeries.forEach((ScatterSerie serie) {
      canvas.drawPoints(
        PointMode.points,
        serie.points
            .where((point) => (point.timestamp >= startTimestamp.value && point.timestamp <= endTimestamp.value))
            .map((e) => Offset(
                  (e.timestamp - startTimestamp.value) * controller.pixelsPerMs + controller.settings.chartMargins,
                  (maxY - e.y) * controller.pixelsPerUSDT + controller.settings.chartMargins,
                ))
            .toList(),
        Paint()
          ..color = serie.color
          ..strokeCap = StrokeCap.round
          ..strokeWidth = serie.pointSize,
      );
    });

    // Draw StraightLine Series
    controller.data.straightLineSeries.forEach((StraightLineSerie serie) {
      List<Offset> bounds = [
        Offset(
          controller.settings.chartMargins,
          (maxY - serie.y) * controller.pixelsPerUSDT + controller.settings.chartMargins,
        ),
        Offset(
          size.width - controller.settings.chartMargins,
          (maxY - serie.y) * controller.pixelsPerUSDT + controller.settings.chartMargins,
        ),
      ];
      canvas.drawPoints(
        PointMode.lines,
        bounds,
        Paint()
          ..color = serie.color
          ..style = PaintingStyle.fill,
      );
    });

    // hide overlappping candles
    canvas.drawRect(Rect.fromLTRB(controller.settings.chartMargins - 1, controller.settings.chartMargins, 0, size.height),
        Paint()..color = controller.settings.backgroundColor);
    canvas.drawRect(
        Rect.fromLTRB(
            size.width - controller.settings.chartMargins + 1, controller.settings.chartMargins, size.width, size.height),
        Paint()..color = controller.settings.backgroundColor);

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
  bool shouldRepaint(CandlestickChartPainter oldDelegate) {
    return true;
  }
}
