import 'package:flutter/material.dart';

import '../common_utils.dart';

class LineChartSettings {
  bool gridVisible;
  double pricePercentMargin;
  double chartMargins;
  Color backgroundColor;
  int nbPtsInitiallyDisplayed;
  int maxPtsDisplayed;
  int nbDivisionsXAxis;
  int nbDivisionsYAxis;
  Paint linesPaint;
  Paint gridPaint;

  LineChartSettings({
    this.gridVisible = true,
    this.pricePercentMargin = 10.0,
    this.chartMargins = 100.0,
    this.backgroundColor,
    this.nbPtsInitiallyDisplayed = 100,
    this.maxPtsDisplayed = 300,
    this.nbDivisionsXAxis = 5,
    this.nbDivisionsYAxis = 5,
    this.linesPaint,
    this.gridPaint,
  }) {
    this.backgroundColor ??= Color.fromARGB(255, 35, 35, 55);
    linesPaint ??= Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    gridPaint ??= Paint()
      ..color = Color.fromARGB(25, 255, 255, 255)
      ..style = PaintingStyle.stroke;
  }
}

class LineChartController {
  LineSerie lineSerie;
  LineChartSettings settings;
  ValueNotifier<int> startTsNotifier;
  ValueNotifier<int> endTsNotifier;
  double pixelsPerMs = 0;
  double pixelsPerUSDT = 0;

  void setTimestamps(int start, int end) {
    startTsNotifier.value = start;
    endTsNotifier.value = end;
  }

  LineChartController({this.lineSerie, this.settings, int startTs, int endTs}) {
    this.settings ??= LineChartSettings();
    startTsNotifier = ValueNotifier(startTs ?? 0);
    endTsNotifier = ValueNotifier(endTs ?? 1);
  }
}
