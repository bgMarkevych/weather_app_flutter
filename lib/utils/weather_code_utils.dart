import 'package:meteoshipflutter/model/data/data_model.dart';

const List<int> _codesList = [
  395,
  392,
  389,
  386,
  377,
  374,
  371,
  368,
  365,
  362,
  359,
  356,
  353,
  350,
  338,
  335,
  332,
  329,
  326,
  323,
  320,
  317,
  314,
  311,
  308,
  305,
  302,
  299,
  296,
  293,
  284,
  281,
  266,
  263,
  260,
  248,
  230,
  227,
  200,
  185,
  182,
  179,
  176,
  143,
  122,
  119,
  116,
  113
];

Map<double, int> getNormalizedCodesTable() {
  Map<double, int> normalizedCodesTable = {};
  _codesList.forEach((element) => normalizedCodesTable.putIfAbsent(
      normalizeInput(
          element.toDouble(), HistoricalForecast.max_weather_code.toDouble()),
      () => element));
  return normalizedCodesTable;
}

///------------------------------------------------------
/// Normalization function to convert your values into new ones in specified range
/// [x] - your value
/// [xMid] - max value of input range
///------------------------------------------------------
double normalizeInput(double x, double maxValue) {
  return x * 100 / maxValue / 100;
}

double getOneOrZero(int code) {
  return code > 284 ? 1.0 : 0.0;
}
