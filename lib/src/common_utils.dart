import 'package:flutter/material.dart';

class Candlestick {
  final int timestamp;
  final double open;
  double high;
  double low;
  double close;

  Candlestick({
    @required this.timestamp,
    @required this.open,
    @required this.high,
    @required this.low,
    @required this.close,
  });
}

class Point {
  final int timestamp;
  double y;

  Point({@required this.timestamp, @required this.y});
}

class CandlestickSerie {
  final String name;
  List<Candlestick> candles;
  double wickWidth;
  double ratioCandleSpace;
  Paint bullPaint;
  Paint bearPaint;
  Paint dojiPaint;

  CandlestickSerie({
    @required this.name,
    this.candles,
    this.wickWidth = 1.0,
    this.ratioCandleSpace = 0.8,
    this.bullPaint,
    this.bearPaint,
    this.dojiPaint,
  }) {
    candles ??= [];
    bullPaint ??= Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;
    bearPaint ??= Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    dojiPaint ??= Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke;
  }
}

class LineSerie {
  final String name;
  final Color color;
  List<Point> points;

  LineSerie({@required this.name, @required this.color, this.points}) {
    this.points ??= [];
  }
}

class ScatterSerie {
  final String name;
  final List<Point> points;
  final Color color;
  final double pointSize;

  ScatterSerie({@required this.name, @required this.points, @required this.color, this.pointSize = 10});
}

class StraightLineSerie {
  final String name;
  final double y;
  final Color color;

  StraightLineSerie({@required this.name, @required this.y, @required this.color});
}
