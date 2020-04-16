import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:meteoshipflutter/blocks/base_block.dart';
import 'package:meteoshipflutter/model/data/data_model.dart';
import 'package:meteoshipflutter/model/di/di.dart';
import 'package:meteoshipflutter/model/model.dart';

class WeatherBlock extends BaseBlock {
  Model _model;
  StreamController<ForecastData> _streamController;
  StreamController<String> _cityNameStreamController;
  StreamController<Color> _colorStreamController;
  StreamController<Map<String, double>> _coordinatesStreamController;
  StreamController<bool> _refreshDataAnimationStreamController;

  WeatherBlock() {
    _model = DIManager.model;
    _streamController = new StreamController();
    _cityNameStreamController = new StreamController();
    _colorStreamController = new StreamController();
    _coordinatesStreamController = new StreamController();
    _refreshDataAnimationStreamController = new StreamController();
  }

  void getData() {
    _refreshDataAnimationStreamController.sink.add(true);
    var s = _model.getForecastData().asStream().listen((event) {
      _streamController.sink.add(event);
      _coordinatesStreamController.sink.add({
        "lon": event.currentForecast.currentWeather.lon,
        "lat": event.currentForecast.currentWeather.lat
      });
      _cityNameStreamController.sink.add(event.currentForecast.city);
      var state = WeatherState.getWeatherStateById(event.currentForecast.code);
      _colorStreamController.sink
          .add(WeatherState.getDayNightColor(event.currentForecast, state));
      _refreshDataAnimationStreamController.sink.add(false);
    });
    this.addSubscription(s);
  }

  Stream<Map<String, double>> get coordinatesStream =>
      _coordinatesStreamController.stream;

  Stream<ForecastData> get forecastStream => _streamController.stream;

  Stream<String> get cityNameStream => _cityNameStreamController.stream;

  Stream<Color> get colorStream => _colorStreamController.stream;

  Stream<bool> get dataAnimationStream =>
      _refreshDataAnimationStreamController.stream;

  @override
  void dispose() {
    _streamController.close();
    _cityNameStreamController.close();
    _colorStreamController.close();
    _coordinatesStreamController.close();
    _refreshDataAnimationStreamController.close();
    super.dispose();
  }

  void pushColor(Color color) {
    _colorStreamController.sink.add(color);
  }

  void refreshData(int currentTab) {
    _refreshDataAnimationStreamController.sink.add(true);
    var s = _model.updateData().asStream().listen((event) {
      _streamController.sink.add(event);
      _coordinatesStreamController.sink.add({
        "lon": event.currentForecast.currentWeather.lon,
        "lat": event.currentForecast.currentWeather.lat
      });

      if (currentTab == 0) {
        _cityNameStreamController.sink.add(event.currentForecast.city);
        var state =
            WeatherState.getWeatherStateById(event.currentForecast.code);
        _colorStreamController.sink
            .add(WeatherState.getDayNightColor(event.currentForecast, state));
        _refreshDataAnimationStreamController.sink.add(false);
      } else {
        _cityNameStreamController.sink.add(event.currentForecast.city);
        var state =
            WeatherState.getWeatherStateById(event.dailyForecasts[0].code);
        _colorStreamController.sink
            .add(WeatherState.getDayNightColor(event.dailyForecasts[0], state));
        _refreshDataAnimationStreamController.sink.add(false);
      }
    });
    this.addSubscription(s);
  }

  void fetchData(double latitude, double longitude, int currentTab) async{
    _refreshDataAnimationStreamController.sink.add(true);
    await _model.fetchData(latitude.toString(), longitude.toString());
    var s = _model.getForecastData().asStream().listen((event) {
      _streamController.sink.add(event);
      _coordinatesStreamController.sink.add({
        "lon": event.currentForecast.currentWeather.lon,
        "lat": event.currentForecast.currentWeather.lat
      });
      if (currentTab == 0) {
        _cityNameStreamController.sink.add(event.currentForecast.city);
        var state =
        WeatherState.getWeatherStateById(event.currentForecast.code);
        _colorStreamController.sink
            .add(WeatherState.getDayNightColor(event.currentForecast, state));
        _refreshDataAnimationStreamController.sink.add(false);
      } else {
        _cityNameStreamController.sink.add(event.currentForecast.city);
        var state =
        WeatherState.getWeatherStateById(event.dailyForecasts[0].code);
        _colorStreamController.sink
            .add(WeatherState.getDayNightColor(event.dailyForecasts[0], state));
        _refreshDataAnimationStreamController.sink.add(false);
      }
    });
    this.addSubscription(s);
  }
}
