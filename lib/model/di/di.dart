import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:meteoshipflutter/model/exception/error.dart';
import 'package:meteoshipflutter/model/storage/database.dart';
import 'package:meteoshipflutter/utils/location_service.dart';
import 'package:sqflite/sqflite.dart';

import '../model.dart';

class DIManager {
  static Dio _dio;
  static Model _model;
  static DataBaseHelper _dataBaseHelper;

  static void provide() {
    _dio = _provideDio();
    _dataBaseHelper = _provideDatabaseHelper();
    _model = _provideModel(_dio, _dataBaseHelper);
  }

  static Model _provideModel(Dio _dio, DataBaseHelper _dataBaseHelper) {
    return new Model(_dio, _dataBaseHelper);
  }

  static DataBaseHelper _provideDatabaseHelper() {
    return new DataBaseHelper();
  }

  static LocationService _provideLocationService() {
    return new LocationService();
  }

  static Dio _provideDio() {
    var dioOptions = BaseOptions(
      baseUrl: "http://api.weatherbit.io",
      connectTimeout: 5000,
      sendTimeout: 5000,
      receiveTimeout: 3000,
    );
    Dio _dio = Dio(dioOptions);
    // _dio.interceptors
    //     .add(InterceptorsWrapper(onRequest: (options, handler) async {
    //   var connectivityResult = await (Connectivity().checkConnectivity());
    //       if (connectivityResult == ConnectivityResult.none) {
    //         return _dio.close(ConnectionError());
    //       }
    //       return options;
    // }));
    _dio.interceptors.add(LogInterceptor(responseBody: true));
    return _dio;
  }

  static LocationService get locationService => _provideLocationService();

//  static Model get model => _model;
  static Model get model {
    return _model;
  }
}
