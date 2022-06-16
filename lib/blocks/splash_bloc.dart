import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:meteoshipflutter/model/di/di.dart';
import 'package:meteoshipflutter/model/exception/error.dart';
import 'package:meteoshipflutter/blocks/base_block.dart';

class SplashBloc extends BaseBlock {
  var _model = DIManager.model;
  var _locationService = DIManager.locationService;

  SplashBloc(StringValue errorCallback) : super(errorCallback);

  void fetchData(VoidCallback callback) {
    var subscription = getWeather().listen((event) {
      callback.call();
    }, onError: (e) => onError(e));
    addSubscription(subscription);
  }

  Stream<dynamic> getWeather() async* {
    var location = await getLocationsData();
    await _model.fetchData(
        location.latitude.toString(), location.longitude.toString());
    yield "response";
  }

  Future<LocationData> getLocationsData() async {
    bool isPermissionGranted = await _locationService.isPermissionGranted();
    if (!isPermissionGranted) {
      isPermissionGranted = await _locationService.requestPermission();
      if (!isPermissionGranted) {
        throw PermissionNotGranted();
      }
    }
    bool isServiceEnabled = await _locationService.isServiceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await _locationService.requestService();
      if (!isServiceEnabled) {
        throw ServiceNotEnabled();
      }
    }
    return _locationService.getLocationData();
  }
}
