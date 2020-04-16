import 'dart:developer';

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:meteoshipflutter/model/data/data_model.dart';

class DataBaseHelper {
  static const String CURRENT_WEATHER_TABLE_NAME = "current_weather";
  static const String HOURLY_FORECAST_TABLE_NAME = "hourly_forecast";
  static const String DAILY_FORECAST_TABLE_NAME = "daily_forecast";

  DataBaseHelper();

  Database _database;

  Future<void> saveCurrentWeather(CurrentWeather item) async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    await _database.transaction((txn) async {
      txn.rawQuery("DELETE FROM " + CURRENT_WEATHER_TABLE_NAME);
      txn.insert(CURRENT_WEATHER_TABLE_NAME, item.toMap());
    });
  }

  Future<void> saveDailyForecasts(List<DailyForecast> items) async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    await _database.transaction((txn) async {
      txn.rawQuery("DELETE FROM " + DAILY_FORECAST_TABLE_NAME);
      items.forEach((element) async {
        await txn.insert(DAILY_FORECAST_TABLE_NAME, element.toMap());
      });
    });
  }

  Future<void> saveHourlyForecasts(List<HourlyForecast> items) async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    await _database.transaction((txn) async {
      txn.rawQuery("DELETE FROM " + HOURLY_FORECAST_TABLE_NAME);
      items.forEach((element) async {
        await txn.insert(HOURLY_FORECAST_TABLE_NAME, element.toMap());
      });
    });
  }

  Future<CurrentWeather> getCurrentWeather() async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    List<Map> result =
        await _database.query(CURRENT_WEATHER_TABLE_NAME, columns: [
      "rh",
      "pod",
      "pres",
      "cityName",
      "windSpd",
      "sunset",
      "sunrise",
      "datetime",
      "lon",
      "lat",
      "timeZone",
      "temp",
      "appTemp",
      "icon",
      "code",
      "id"
    ]);
    return CurrentWeather.fromMap(result[0]);
  }

  Future<List<HourlyForecast>> getHourlyForecast() async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    List<Map> result = await _database.query(HOURLY_FORECAST_TABLE_NAME,
        columns: ["pod", "datetime", "temp", "icon", "code", "id"]);
    return result.map((e) => HourlyForecast.fromMap(e)).toList();
  }

  Future<List<DailyForecast>> getDailyForecasts() async {
    if (_database == null) {
      _database = await _provideDatabase();
    }
    List<Map> result =
        await _database.query(DAILY_FORECAST_TABLE_NAME, columns: [
      "rh",
      "pres",
      "sunsetTs",
      "sunriseTs",
      "windSpd",
      "cityName",
      "appMaxTemp",
      "datetime",
      "minTemp",
      "maxTemp",
      "temp",
      "icon",
      "code",
      "id"
    ]);
    return result.map((e) => DailyForecast.fromMap(e)).toList();
  }

  Future<Database> _provideDatabase() async {
    var databasesPath = await getDatabasesPath();
    String path = databasesPath + 'demo.db';

    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(_provideCurrentWeatherTableCreationString());
      await db.execute(_provideDailyForecastTableCreationString());
      await db.execute(_provideHourlyForecastTableCreationString());
    });
    return database;
  }

  String _provideCurrentWeatherTableCreationString() {
    return 'CREATE TABLE current_weather ' +
        '(id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'rh INTEGER, ' +
        'pod TEXT, ' +
        'pres REAL,' +
        'windSpd REAL,' +
        'cityName TEXT,' +
        'timeZone TEXT,' +
        'sunset TEXT,' +
        'sunrise TEXT,' +
        'datetime TEXT,' +
        'temp REAL,' +
        'appTemp REAL,' +
        'lon REAL,' +
        'lat REAL,' +
        'icon TEXT,' +
        'code TEXT' +
        ')';
  }

  String _provideDailyForecastTableCreationString() {
    return 'CREATE TABLE daily_forecast ' +
        '(id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'rh INTEGER, ' +
        'pres REAL,' +
        'sunsetTs INTEGER,' +
        'sunriseTs INTEGER,' +
        'windSpd REAL,' +
        'appMaxTemp REAL,' +
        'datetime TEXT,' +
        'cityName TEXT,' +
        'temp REAL,' +
        'minTemp REAL,' +
        'maxTemp REAL,' +
        'icon TEXT,' +
        'code TEXT' +
        ')';
  }

  String _provideHourlyForecastTableCreationString() {
    return 'CREATE TABLE hourly_forecast ' +
        '(id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
        'datetime TEXT,' +
        'temp REAL,' +
        'pod TEXT,' +
        'code TEXT,' +
        'icon TEXT' +
        ')';
  }
}
