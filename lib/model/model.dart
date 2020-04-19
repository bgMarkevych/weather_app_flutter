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
  String _appKey = "a2450fbf4c6f47d997cf3e325094e5d1";
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
        "key": "9383e914c44a4b5198b170544201604",
        "q": forecast.lat.toString() + "," + forecast.lon.toString(),
        "date": dates["startDate"],
        "enddate": dates["endDate"],
        "format": "json",
        "tp": "24",
      };
      var result = await _dio
          .get("http://api.worldweatheronline.com/premium/v1/past-weather.ashx",
          queryParameters: parameters)
          .then((value) {
        var result = value.data["data"]["weather"];
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
    _perceptron.trainTest();
    var rain = await _dataBaseHelper.getHistoricalForecastByCode(353);
   _perceptron.predictTest(rain.neuron);
    var sun = await _dataBaseHelper.getHistoricalForecastByCode(113);
    _perceptron.predictTest(sun.neuron);
    _perceptron.predictTest();
//  _perceptron.trainTest();
  }

}
