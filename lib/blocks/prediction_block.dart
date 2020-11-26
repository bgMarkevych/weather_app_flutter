import 'dart:async';

import 'package:meteoshipflutter/blocks/base_block.dart';
import 'package:meteoshipflutter/model/di/di.dart';
import 'package:meteoshipflutter/model/model.dart';

class PredictionBlock extends BaseBlock {
  StreamController<DataStatus> _dataStateStreamController =
      new StreamController();
  Model _model = DIManager.model;

  void startFlow() async {
    _dataStateStreamController.sink.add(DataStatus.loading);
   await _model.loadTrainingData();
    _dataStateStreamController.sink.add(DataStatus.training);
    await _model.trainNetwork();
   await _model.predictWeather();
    _dataStateStreamController.sink.add(DataStatus.ok);
  }

  Stream<DataStatus> get dataStatusStream => _dataStateStreamController.stream;

  @override
  void dispose() {
    _dataStateStreamController.close();
    super.dispose();
  }
}

enum DataStatus { loading, training, predicting, ok }
