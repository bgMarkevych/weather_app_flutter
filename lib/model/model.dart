import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:meteoshipflutter/model/data/data_model.dart';
import 'package:meteoshipflutter/model/storage/database.dart';
import 'package:meteoshipflutter/neural_network.dart';
import 'package:meteoshipflutter/utils/date_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

const SPLASH_SCREEN = "SPLASH_SCREEN";
const CACHE_TIME = "CACHE_TIME";
const ONE_HOUR = 3600000;

class Model {
  Dio _dio;
  DataBaseHelper _dataBaseHelper;
  String _appKey = "2c437fe0199f45ba9884e1923c9c264a";
  Perceptron _perceptron;

  Model(this._dio, this._dataBaseHelper) {
    _perceptron = Perceptron();
  }

  Future<void> fetchData(String lat, String lon) async {
    Map<String, dynamic> parameters = {"lat": lat, "lon": lon, "key": _appKey};
    CurrentWeather currentWeather = await loadCurrentWeather(parameters);
    List<HourlyForecast> hourlyForecast =
    await loadHourlyForecast(parameters, currentWeather.timeZone);
    List<DailyForecast> dailyForecasts = await loadDailyForecasts(parameters);
    await saveSplashScreenFlag();
    await _dataBaseHelper.saveCurrentWeather(currentWeather);
    await _dataBaseHelper.saveHourlyForecasts(hourlyForecast);
    await _dataBaseHelper.saveDailyForecasts(dailyForecasts);
  }

  Future<ForecastData> updateData() async {
    var weather = await _dataBaseHelper.getCurrentWeather();
    Map<String, dynamic> parameters = {
      "lat": weather.lat,
      "lon": weather.lon,
      "key": _appKey
    };
    CurrentWeather currentWeather = await loadCurrentWeather(parameters);
    List<HourlyForecast> hourlyForecast =
    await loadHourlyForecast(parameters, currentWeather.timeZone);
    List<DailyForecast> dailyForecasts = await loadDailyForecasts(parameters);
    await saveSplashScreenFlag();
    await _dataBaseHelper.saveCurrentWeather(currentWeather);
    await _dataBaseHelper.saveHourlyForecasts(hourlyForecast);
    await _dataBaseHelper.saveDailyForecasts(dailyForecasts);
    return getForecastData();
  }

  void saveCacheTime() async {
    var dateTime = DateTime.now();
    var preferences = await SharedPreferences.getInstance();
    await preferences.setInt(CACHE_TIME, dateTime.millisecondsSinceEpoch);
  }

  Future<bool> needToUpdateCache() async {
    var preferences = await SharedPreferences.getInstance();
    int previousTime = preferences.getInt(CACHE_TIME);
    int now = DateTime
        .now()
        .millisecondsSinceEpoch;
    return now - previousTime > ONE_HOUR;
  }

  Future<CurrentWeather> loadCurrentWeather(Map<String, dynamic> parametrs) {
    saveCacheTime();
    return _dio.get("/v2.0/current", queryParameters: parametrs).then((value) {
      return CurrentWeather.fromJson(
          (value.data["data"][0] as Map<String, dynamic>));
    });
  }

  Future<List<HourlyForecast>> loadHourlyForecast(
      Map<String, dynamic> parameters, String timeZone) {
    initializeTimeZones();
    final location = getLocation(timeZone);
    final date = TZDateTime.from(DateTime.now(), location);
    var hours = 24 - date.hour;
    parameters.putIfAbsent(
        "hours", () => hours == 24 ? 23.toString() : hours.toString());
    return _dio
        .get("/v2.0/forecast/hourly", queryParameters: parameters)
        .then((value) {
      List<HourlyForecast> response = (value.data["data"] as List<dynamic>)
          .map((e) => HourlyForecast.fromJson(e))
          .toList();
      return response;
    });
  }

  Future<List<DailyForecast>> loadDailyForecasts(
      Map<String, dynamic> parametrs) {
    parametrs.remove("hours");
    parametrs.putIfAbsent("days", () => "15");
    return _dio.get("/v2.0/forecast/daily", queryParameters: parametrs).then(
            (value) =>
            (value.data["data"] as List<dynamic>)
                .map((e) => DailyForecast.fromJson(e))
                .toList());
  }

  Future<void> saveSplashScreenFlag() async {
    var preferences = await SharedPreferences.getInstance();
    await preferences.setBool(SPLASH_SCREEN, true);
  }

  Future<bool> needToShowSplash() async {
    var preferences = await SharedPreferences.getInstance();
    var result = preferences.getBool(SPLASH_SCREEN);
    return result == null ? true : !result;
  }

  Future<ForecastData> getForecastData() async {
    bool needToUpdateData = await needToUpdateCache();
    if (needToUpdateData) {
      return updateData();
    }
    var current = await _dataBaseHelper.getCurrentWeather();
    var hourly = await _dataBaseHelper.getHourlyForecast();
    var daily = await _dataBaseHelper.getDailyForecasts();
    return ForecastData(CurrentForecast(current, hourly), daily);
  }

  Future<void> loadTrainingData() async {
    var forecast = await _dataBaseHelper.getCurrentWeather();
    var finalList = <HistoricalForecast>[];
    for (int i = 0; i < 12; i++) {
      var dates = getHistoricalDates(i);
      Map<String, String> parameters = {
        "key": _appKey,
        "lat": forecast.lat.toString(),
        "lon": forecast.lon.toString(),
        "start_date": dates["startDate"],
        "end_date": dates["endDate"]
      };
      var result = await _dio
          .get("https://api.weatherbit.io/v2.0/history/daily",
          queryParameters: parameters)
          .then((value) {
        var result = value.data["data"];
        print(value.data);
        return result;
      }).then((value) =>
          (value as List<dynamic>)
              .map((e) => HistoricalForecast.fromJson(e))
              .toList());
      finalList.addAll(result);
    }
    await _dataBaseHelper.saveHistoricalForecasts(finalList);
  }

  Future<void> trainNetwork() async {
    _perceptron.train(1000, 0.75);
    // var sun = await _dataBaseHelper.getHistoricalForecastByCode(113);
    // _perceptron.predictTest(sun.neuron);
    // _perceptron.predictTest();
//  _perceptron.trainTest();
  }

  Future<void> predictWeather() async {
    var rain = await _dataBaseHelper.getHistoricalForecastByCode(353);
    _perceptron.predict(rain);
  }

}
