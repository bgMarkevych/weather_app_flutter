import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:meteoshipflutter/model/data/data_model.dart';
import 'package:meteoshipflutter/model/storage/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

const SPLASH_SCREEN = "SPLASH_SCREEN";

class Model {
  Dio _dio;
  DataBaseHelper _dataBaseHelper;
  String _appKey = "a2450fbf4c6f47d997cf3e325094e5d1";

  Model(this._dio, this._dataBaseHelper);

  Future<void> fetchData(String lat, String lon) async {
    Map<String, dynamic> parametrs = {"lat": lat, "lon": lon, "key": _appKey};
    CurrentWeather currentWeather = await loadCurrentWeather(parametrs);
    List<HourlyForecast> hourlyForecast =
        await loadHourlyForecast(parametrs, currentWeather.timeZone);
    List<DailyForecast> dailyForecasts = await loadDailyForecasts(parametrs);
    await saveSplashScreenFlag();
    await _dataBaseHelper.saveCurrentWeather(currentWeather);
    await _dataBaseHelper.saveHourlyForecasts(hourlyForecast);
    await _dataBaseHelper.saveDailyForecasts(dailyForecasts);
  }

  Future<ForecastData> updateData() async {
    var weather = await _dataBaseHelper.getCurrentWeather();
    Map<String, dynamic> parametrs = {
      "lat": weather.lat,
      "lon": weather.lon,
      "key": _appKey
    };
    CurrentWeather currentWeather = await loadCurrentWeather(parametrs);
    List<HourlyForecast> hourlyForecast =
        await loadHourlyForecast(parametrs, currentWeather.timeZone);
    List<DailyForecast> dailyForecasts = await loadDailyForecasts(parametrs);
    await saveSplashScreenFlag();
    await _dataBaseHelper.saveCurrentWeather(currentWeather);
    await _dataBaseHelper.saveHourlyForecasts(hourlyForecast);
    await _dataBaseHelper.saveDailyForecasts(dailyForecasts);
    return getForecastData();
  }

  Future<CurrentWeather> loadCurrentWeather(Map<String, dynamic> parametrs) {
    return _dio.get("/v2.0/current", queryParameters: parametrs).then((value) {
      return CurrentWeather.fromJson(
          (value.data["data"][0] as Map<String, dynamic>));
    });
  }

  Future<List<HourlyForecast>> loadHourlyForecast(
      Map<String, dynamic> parametrs, String timeZone) {
    initializeTimeZones();
    final location = getLocation(timeZone);
    final date = TZDateTime.from(DateTime.now(), location);
    var hours = 24 - date.hour;
    parametrs.putIfAbsent("hours", () => hours == 24 ? 23.toString() :hours.toString());
    return _dio
        .get("/v2.0/forecast/hourly", queryParameters: parametrs)
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
        (value) => (value.data["data"] as List<dynamic>)
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
    var current = await _dataBaseHelper.getCurrentWeather();
    var hourly = await _dataBaseHelper.getHourlyForecast();
    var daily = await _dataBaseHelper.getDailyForecasts();
    return ForecastData(CurrentForecast(current, hourly), daily);
  }
}
