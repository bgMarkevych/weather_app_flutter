import 'dart:async';
import 'dart:developer' as debug;
import 'dart:math';
import 'dart:core';

import 'package:meteoshipflutter/utils/weather_code_utils.dart';

import 'model/data/data_model.dart';

class Perceptron {
  List<double> _expected;
  List<List<double>> _trainInput;
  List<List<double>> _weightsInputLayer;
  List<double> _weightHiddenLayer;

  ///------------------------------------------------------
  /// Map HistoricalForecast data list into list of neutrons
  ///------------------------------------------------------
  List<List<double>> _mapDataIntoNeurons(List<HistoricalForecast> data) {
    List<List<double>> output = <List<double>>[];
    data.forEach((element) {
      output.add(element.neuron);
    });
    return output;
  }

  ///------------------------------------------------------
  /// Init training data
  ///------------------------------------------------------
  void _initTrainingData(List<HistoricalForecast> data) {
    _trainInput = _mapDataIntoNeurons(data);
    _expected = _mapExpectations(data);
    _initWeights();
  }

  List<double> _mapExpectations(List<HistoricalForecast> data) {
    var expectations = <double>[];
    data.forEach((element) {
      expectations.add(element.result);
    });
    return expectations;
  }

  ///------------------------------------------------------
  /// Provide network training
  /// Need to init training data and weights before start [_initTrainingData]
  /// [learningRate] - constant of speed for training
  /// [epoch] - amount of times to run train algorithm
  ///------------------------------------------------------
  void _train(int index, double learningRate) {
    var hiddenLayer =
        _transferFunctionV2(_trainInput[index], _weightsInputLayer);
    var outputLayer = _transferFunctionV2(hiddenLayer, [_weightHiddenLayer]);
    var output = outputLayer[0];
//        print(output);

    /// hidden layer
//      debug.debugger();
    var errorHiddenLayer = output - _expected[index];
    var gradientHiddenLayer = output * (1 - output);

    /// delta weight hidden layer
    var dWeightHiddenLayer = errorHiddenLayer * gradientHiddenLayer;

//    debug.debugger();
    var newWeights = <double>[];
    for (int i = 0; i < hiddenLayer.length; i++) {
      newWeights.add(_countNewWeight(_weightHiddenLayer[i], hiddenLayer[i],
          dWeightHiddenLayer, learningRate));
    }
    _weightHiddenLayer.clear();
    _weightHiddenLayer.addAll(newWeights);

    /// input layer
//        debug.debugger();
    var errorInputLayer = <double>[];
    for (int i = 0; i < _weightHiddenLayer.length; i++) {
      errorInputLayer.add(dWeightHiddenLayer * _weightHiddenLayer[i]);
    }
    var gradientInputLayer = <double>[];
    for (int i = 0; i < hiddenLayer.length; i++) {
      gradientInputLayer.add(hiddenLayer[i] * (1 - hiddenLayer[i]));
    }

    /// delta weight input layer
//    debug.debugger();
    var dWeightInputLayer = <double>[];
    for (int i = 0; i < errorInputLayer.length; i++) {
      dWeightInputLayer.add(errorInputLayer[i] * gradientInputLayer[i]);
    }
//        debug.debugger();
    var newInputWeights = <List<double>>[];
    for (int i = 0; i < _weightsInputLayer.length; i++) {
      var sublist = <double>[];
      for (int j = 0; j < _weightsInputLayer[i].length; j++) {
        sublist.add(_countNewWeight(_weightsInputLayer[i][j],
            _trainInput[index][j], dWeightInputLayer[i], learningRate));
      }
      newInputWeights.add(sublist);
    }
    _weightsInputLayer.clear();
    _weightsInputLayer.addAll(newInputWeights);
  }

  static const prodTrainingInputs = <List<double>>[
    [0.0, 0.0, 1.0],
    [1.0, 1.0, 1.0],
    [1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0],
    [1.0, 1.0, 0.0],
    [1.0, 0.0, 0.0],
  ];

  static const prodTrainingResults = <double>[0.0, 1.0, 1.0, 1.0, 1.0, 0.0];

  Future<void> train(int epoch, double learningRate) async {
    return Future(() async {
      _trainInput = prodTrainingInputs;
      _expected = prodTrainingResults;
      _initWeights();
      for (int i = 0; i < epoch; i++) {
        print(i);
        for (int p = 0; p < _trainInput.length; p++) {
          _train(p, learningRate);
//          await Future.delayed(Duration(microseconds: 1));
        }
      }
    });
  }

  ///------------------------------------------------------
  /// Provide network predicting
  /// Need to train or init custom weights before predicting
  /// [train] or [_initInputData]
  ///------------------------------------------------------
  Future<int> predict(HistoricalForecast data) {
    return Future(() async {
      print(data.toMap());
      var hiddenLayer = _transferFunctionV2(data.neuron, _weightsInputLayer);
      var outputLayer = _transferFunctionV2(hiddenLayer, [_weightHiddenLayer]);
      print(outputLayer[0]);
//      print(dp(abs(outputLayer[0]), 5));
      return outputLayer[0].toInt();
    });
  }

  double dp(double val, int places){
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

//  int getNearestCode(double normalizedItem) {
//    print(normalizedItem);
//    var codesTable = getNormalizedCodesTable();
//    var normalizedCodes = <double>[];
//    codesTable.keys.forEach((element) => normalizedCodes.add(element));
//    double distance = abs(normalizedCodes[0] - normalizedItem);
//    int idx = 0;
//    for (int c = 1; c < normalizedCodes.length; c++) {
//      double cdistance = abs(normalizedCodes[c] - normalizedItem);
//      if (cdistance < distance) {
//        idx = c;
//        distance = cdistance;
//      }
//    }
//    return codesTable.entries
//        .firstWhere((element) => element.key == normalizedCodes[idx])
//        .value;
//  }

  ///------------------------------------------------------
  /// Return absolute value of [x]
  ///------------------------------------------------------
  double abs(double x) {
    return x < 0 ? -x : x;
  }

  ///------------------------------------------------------
  /// Init synapses weights according to neurons list size
  ///------------------------------------------------------
  void _initWeights() {
    if (_weightsInputLayer != null || _weightHiddenLayer != null) {
      return;
    }
    var random = Random(1);
    var weightInputLayer = <List<double>>[];
    var weightHiddenLayer = <double>[];
    for (int i = 0; i < 2; i++) {
      var sublist = <double>[];
      for (int j = 0; j < _trainInput[0].length; j++) {
        sublist.add((random.nextDouble() + 0.1) * 0.3);
      }
      weightInputLayer.add(sublist);
    }
    for (int i = 0; i < weightInputLayer.length; i++) {
      weightHiddenLayer.add((random.nextDouble() + 0.1) * 0.3);
    }
    _weightsInputLayer = weightInputLayer;
    _weightHiddenLayer = weightHiddenLayer;
  }

  ///------------------------------------------------------
  /// Function to transfer neurons and weight
  /// Returns new hidden layer
  /// [neurons] - matrix of neurons
  /// [weights] - matrix of equivalent weights
  ///------------------------------------------------------
  List<double> _transferFunctionV2(
      List<double> neurons, List<List<double>> weights) {
    var result = <double>[];
    for (int i = 0; i < weights.length; i++) {
      double sum = 0;
      for (int j = 0; j < neurons.length; j++) {
        sum += weights[i][j] * neurons[j];
      }
      result.add(_activationFunction(sum));
    }
    return result;
  }

  double _countNewWeight(
      double oldWeight, double output, double dWeight, double learningRate) {
    return oldWeight - output * dWeight * learningRate;
  }

  ///------------------------------------------------------
  /// Activation function
  /// Returns new potential output
  /// [x] - value from hidden layer
  ///------------------------------------------------------
  double _activationFunction(double x) {
    return 1 / (1 - pow(e, -x));
  }

  /// Testing network -------------------------------

  static List<List<double>> _testTrainInput = [
    [0.0, 0.0, 1.0],
    [1.0, 1.0, 1.0],
    [1.0, 0.0, 1.0],
    [0.0, 1.0, 1.0],
  ];

  static List<double> _testTrainExpected = [0.0, 1.0, 1.0, 0.0];

  void trainTest() {
    var _trainInput = _testTrainInput;
    var _expected = _testTrainExpected;

    var random = Random(1);

    _weightsInputLayer = <List<double>>[
      [
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble(),
      ],
      [
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble(),
      ]
    ];
    _weightHiddenLayer = [random.nextDouble(), random.nextDouble()];

    var learningRate = 0.2;

    for (int k = 0; k < 5000; k++) {
      for (int p = 0; p < _trainInput.length; p++) {
        var hiddenLayer =
            _transferFunctionV2(_trainInput[p], _weightsInputLayer);
        var outputLayer =
            _transferFunctionV2(hiddenLayer, [_weightHiddenLayer]);
        var output = outputLayer[0];
//        print(output);

        /// hidden layer
//      debug.debugger();
        var errorHiddenLayer = output - _expected[p];
        var gradientHiddenLayer = output * (1 - output);

        /// delta weight hidden layer
        var dWeightHiddenLayer = errorHiddenLayer * gradientHiddenLayer;

//    debug.debugger();
        var newWeights = <double>[];
        for (int i = 0; i < hiddenLayer.length; i++) {
          newWeights.add(_countNewWeight(_weightHiddenLayer[i], hiddenLayer[i],
              dWeightHiddenLayer, learningRate));
        }
        _weightHiddenLayer.clear();
        _weightHiddenLayer.addAll(newWeights);

        /// input layer
//        debug.debugger();
        var errorInputLayer = <double>[];
        for (int i = 0; i < _weightHiddenLayer.length; i++) {
          errorInputLayer.add(dWeightHiddenLayer * _weightHiddenLayer[i]);
        }
        var gradientInputLayer = <double>[];
        for (int i = 0; i < hiddenLayer.length; i++) {
          gradientInputLayer.add(hiddenLayer[i] * (1 - hiddenLayer[i]));
        }

        /// delta weight input layer
//    debug.debugger();
        var dWeightInputLayer = <double>[];
        for (int i = 0; i < errorInputLayer.length; i++) {
          dWeightInputLayer.add(errorInputLayer[i] * gradientInputLayer[i]);
        }
//        debug.debugger();
        var newInputWeights = <List<double>>[];
        for (int i = 0; i < _weightsInputLayer.length; i++) {
          var sublist = <double>[];
          for (int j = 0; j < _weightsInputLayer[i].length; j++) {
            sublist.add(_countNewWeight(_weightsInputLayer[i][j],
                _trainInput[p][j], dWeightInputLayer[i], learningRate));
          }
          newInputWeights.add(sublist);
        }
        _weightsInputLayer.clear();
        _weightsInputLayer.addAll(newInputWeights);
      }
    }
//    predictTest();
  }

  void predictTest([List<double> input = const [0.0, 0.0, 0.0]]) {
    var hiddenLayer = _transferFunctionV2(input, _weightsInputLayer);
    var outputLayer = _transferFunctionV2(hiddenLayer, [_weightHiddenLayer]);
    print(outputLayer[0]);
    print(outputLayer[0].toInt() == 0 || outputLayer[0] == double.infinity);
  }
}
