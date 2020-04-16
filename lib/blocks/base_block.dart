import 'dart:async';

import 'package:flutter/material.dart';


typedef StringValue = Function(String);

abstract class BaseBlock {
  List<StreamSubscription> _subscriptions;
  StringValue _errorCallback;

  BaseBlock([StringValue errorCallback]) {
    this._errorCallback = errorCallback;
    _subscriptions = [];
  }

  void onError(Object error) {
    if (_errorCallback != null) {
      _errorCallback.call(error.toString());
    }
  }

  @protected
  void addSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void dispose() {
    _subscriptions.forEach((element) => element.cancel());
  }
}
