import 'package:flutter/material.dart';

import '../common_utils.dart';

class CandlestickChartData {
  CandlestickSerie candleSerie;
  List<LineSerie> lineSeries;
  List<ScatterSerie> scatterSeries;
  List<StraightLineSerie> straightLineSeries;

  CandlestickChartData({this.candleSerie, this.lineSeries, this.scatterSeries, this.straightLineSeries}) {
    lineSeries ??= [];
    scatterSeries ??= [];
    straightLineSeries ??= [];
  }
}

class CandlestickChartSettings {
  bool gridVisible;
  double pricePercentMargin;
  double chartMargins;
  Color backgroundColor;
  int nbCandlesInitiallyDisplayed;
  int maxCandlesDisplayed;
  int nbDivisionsXAxis;
  int nbDivisionsYAxis;
  Paint linesPaint;
  Paint gridPaint;

  CandlestickChartSettings({
    this.gridVisible = true,
    this.pricePercentMargin = 10.0,
    this.chartMargins = 100.0,
    this.backgroundColor,
    this.nbCandlesInitiallyDisplayed = 100,
    this.maxCandlesDisplayed = 300,
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

class CandlestickChartController {
  CandlestickChartData data;
  CandlestickChartSettings settings;
  ValueNotifier<int> startTsNotifier;
  ValueNotifier<int> endTsNotifier;
  double pixelsPerMs = 0;
  double pixelsPerUSDT = 0;

  void setTimestamps(int start, int end) {
    startTsNotifier.value = start;
    endTsNotifier.value = end;
  }

  CandlestickChartController({this.data, this.settings, int startTs, int endTs}) {
    this.data ??= CandlestickChartData();
    this.settings ??= CandlestickChartSettings();
    startTsNotifier = ValueNotifier(startTs ?? 0);
    endTsNotifier = ValueNotifier(endTs ?? 1);
  }
}
