/// ## Trading Charts
///
/// Simple library to display charts types usually used in trading.
///
/// Both series types can be mixed in one chart, but the name of the class used determines
/// which one of the series will be used as reference for bounds calculation.
///

library trading_charts;

export 'src/common_utils.dart';
export 'src/candlestick_chart/candlestick_chart.dart';
export 'src/line_chart/line_chart.dart';
