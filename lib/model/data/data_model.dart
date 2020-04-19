import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:meteoshipflutter/utils/colors.dart';
import 'package:meteoshipflutter/utils/weather_code_utils.dart';

class HourlyForecast {
  String datetime;
  double temp;
  String pod;

  String icon;
  String code;

  int id;

  bool isNight() {
    return pod == "n";
  }

  Map<String, dynamic> toMap() {
    return {
      "datetime": datetime,
      "temp": temp,
      "pod": pod,
      "icon": icon,
      "code": code,
    };
  }

  static HourlyForecast fromJson(Map<String, dynamic> data) {
    HourlyForecast hourlyWeather = new HourlyForecast();
    hourlyWeather.pod = data["pod"];
    hourlyWeather.datetime =
        data["timestamp_local"].replaceAll(new RegExp(r'T'), " ");
    hourlyWeather.temp = double.parse(data["temp"].toString());

    hourlyWeather.code = data["weather"]["code"].toString();
    hourlyWeather.icon = data["weather"]["icon"];

    return hourlyWeather;
  }

  static HourlyForecast fromMap(Map<String, dynamic> data) {
    HourlyForecast hourlyWeather = new HourlyForecast();
    hourlyWeather.pod = data["pod"];
    hourlyWeather.datetime = data["datetime"];
    hourlyWeather.temp = data["temp"];

    hourlyWeather.code = data["code"];
    hourlyWeather.icon = data["icon"];

    return hourlyWeather;
  }
}

class CurrentWeather implements Forecast {
  int rh;
  String pod;
  double pres;
  String cityName;
  double windSpd;
  String sunset;
  String timeZone;
  String sunrise;
  String datetime;
  double temp;
  double appTemp;

  double lon;
  double lat;

  String icon;
  String code;

  int id;

  Map<String, dynamic> toMap() {
    return {
      "rh": rh,
      "pod": pod,
      "pres": pres,
      "cityName": cityName,
      "timeZone": timeZone,
      "windSpd": windSpd,
      "sunset": sunset,
      "sunrise": sunrise,
      "datetime": datetime,
      "temp": temp,
      "appTemp": appTemp,
      "lon": lon,
      "lat": lat,
      "icon": icon,
      "code": code,
    };
  }

  static CurrentWeather fromJson(Map<String, dynamic> data) {
    CurrentWeather currentWeather = new CurrentWeather();
    currentWeather.rh = data["rh"];
    currentWeather.pod = data["pod"];
    currentWeather.pres = double.tryParse(data["pres"].toString());
    currentWeather.cityName = data["city_name"];
    currentWeather.windSpd = double.tryParse(data["wind_spd"].toString());
    currentWeather.sunset = data["sunset"];
    currentWeather.sunrise = data["sunrise"];
    currentWeather.timeZone = data["timezone"];
    currentWeather.datetime = data["ob_time"];
    currentWeather.lon = data["lon"];
    currentWeather.lat = data["lat"];
    currentWeather.temp = double.tryParse(data["temp"].toString());
    currentWeather.appTemp = double.tryParse(data["app_temp"].toString());

    currentWeather.code = data["weather"]["code"];
    currentWeather.icon = data["weather"]["icon"];

    return currentWeather;
  }

  static CurrentWeather fromMap(Map<String, dynamic> data) {
    CurrentWeather currentWeather = new CurrentWeather();
    currentWeather.rh = data["rh"];
    currentWeather.pod = data["pod"];
    currentWeather.pres = double.tryParse(data["pres"].toString());
    currentWeather.cityName = data["cityName"];
    currentWeather.windSpd = double.tryParse(data["windSpd"].toString());
    currentWeather.sunset = data["sunset"];
    currentWeather.sunrise = data["sunrise"];
    currentWeather.datetime = data["datetime"];
    currentWeather.lon = data["lon"];
    currentWeather.lat = data["lat"];
    currentWeather.timeZone = data["timeZone"];
    currentWeather.temp = double.tryParse(data["temp"].toString());
    currentWeather.appTemp = double.tryParse(data["appTemp"].toString());

    currentWeather.code = data["code"];
    currentWeather.icon = data["icon"];

    return currentWeather;
  }

  @override
  String get city => cityName;

  @override
  String get date => datetime;

  @override
  Map<String, String> get details => {
        "Temprature max": (temperature + 3).toInt().toString(),
        "Pressure": pres.toString() + " mb",
        "Temprature min": (temperature - 3).toInt().toString(),
        "Wind speed": windSpd.toString() + " m/s",
        "Feels like": appTemp.toInt().toString(),
        "Relative humidity": rh.toString() + " %"
      };

  @override
  double get temperature => temp;
}

class DailyForecast implements Forecast {
  int rh;
  double pres;
  int sunsetTs;
  int sunriseTs;
  double windSpd;
  double appMaxTemp;
  String datetime;
  String cityName;
  double temp;
  double minTemp;
  double maxTemp;

  String icon;
  String code;

  int id;

  Map<String, dynamic> toMap() {
    return {
      "rh": rh,
      "pres": pres,
      "sunsetTs": sunsetTs,
      "sunriseTs": sunriseTs,
      "windSpd": windSpd,
      "appMaxTemp": appMaxTemp,
      "datetime": datetime,
      "temp": temp,
      "minTemp": minTemp,
      "maxTemp": maxTemp,
      "cityName": cityName,
      "icon": icon,
      "code": code,
    };
  }

  static DailyForecast fromJson(Map<String, dynamic> data) {
    DailyForecast dailyWeather = new DailyForecast();
    dailyWeather.rh = data["rh"];
    dailyWeather.pres = double.parse(data["pres"].toString());
    dailyWeather.sunsetTs = data["sunset_ts"];
    dailyWeather.sunriseTs = data["sunrise_ts"];
    dailyWeather.windSpd = double.parse(data["wind_spd"].toString());
    dailyWeather.appMaxTemp = double.parse(data["app_max_temp"].toString());
    dailyWeather.maxTemp = double.parse(data["max_temp"].toString());
    dailyWeather.datetime = data["datetime"] + " 00:00:00";
    dailyWeather.temp = double.parse(data["temp"].toString());
    dailyWeather.minTemp = double.parse(data["min_temp"].toString());

    dailyWeather.code = data["weather"]["code"].toString();
    dailyWeather.icon = data["weather"]["icon"];

    return dailyWeather;
  }

  static DailyForecast fromMap(Map<String, dynamic> data) {
    DailyForecast dailyWeather = new DailyForecast();
    dailyWeather.rh = data["rh"];
    dailyWeather.pres = data["pres"];
    dailyWeather.sunsetTs = data["sunsetTs"];
    dailyWeather.sunriseTs = data["sunriseTs"];
    dailyWeather.windSpd = data["windSpd"];
    dailyWeather.appMaxTemp = data["appMaxTemp"];
    dailyWeather.maxTemp = data["maxTemp"];
    dailyWeather.datetime = data["datetime"];
    dailyWeather.temp = data["temp"];
    dailyWeather.minTemp = data["minTemp"];

    dailyWeather.code = data["code"];
    dailyWeather.icon = data["icon"];

    return dailyWeather;
  }

  @override
  String get city => cityName;

  @override
  String get date => datetime;

  @override
  Map<String, String> get details => {
        "Temprature max": (maxTemp).toString(),
        "Pressure": pres.toString() + " mb",
        "Temprature min": (minTemp).toString(),
        "Wind speed": windSpd.toString() + " m/s",
        "Feels like": appMaxTemp.toString(),
        "Relative humidity": rh.toString() + " %"
      };

  @override
  String get pod => "";

  @override
  String get sunrise => sunriseTs.toString();

  @override
  String get sunset => sunsetTs.toString();

  @override
  double get temperature => temp;
}

class Sheep {
  String imgPath;
  List<int> range;

  Sheep(this.imgPath, this.range);

  static List<Sheep> getList() {
    List<Sheep> sheeps = [];
    sheeps.add(Sheep("assets/sheeps/minus_5.svg", [0]));
    sheeps.add(Sheep("assets/sheeps/d_5.svg", [1, 5]));
    sheeps.add(Sheep("assets/sheeps/d_10.svg", [6, 10]));
    sheeps.add(Sheep("assets/sheeps/d_15.svg", [11, 15]));
    sheeps.add(Sheep("assets/sheeps/d_20.svg", [16, 20]));
    sheeps.add(Sheep("assets/sheeps/d_25.svg", [21, 25]));
    sheeps.add(Sheep("assets/sheeps/d_30.svg", [26]));
    return sheeps;
  }

  static String getImgPathByTemperature(int temperature) {
    Sheep sheep;
    List<Sheep> sheeps = getList();
    for (final it in sheeps) {
      if (it.range.length != 1 &&
          temperature >= it.range[0] &&
          temperature <= it.range[1]) {
        sheep = it;
        break;
      }
    }
    if (sheep == null) {
      if (temperature >= 0) {
        sheep = sheeps[0];
      } else {
        sheep = sheeps[sheeps.length - 1];
      }
    }
    return sheep.imgPath;
  }
}

abstract class Forecast {
  String get city;

  String get date;

  String get sunrise;

  String get sunset;

  double get temperature;

  String get pod;

  String get code;

  Map<String, dynamic> get details;
}

class WeatherState {
  List<String> codes;
  String imgPath;
  Color color;

  WeatherState(this.codes, this.imgPath, this.color);

  static List<WeatherState> getAllStates() {
    List<WeatherState> list = [];
    list.add(new WeatherState(["200", "201", "202", "230", "231", "232", "233"],
        "assets/weather/flash.svg", flashColor)); //Flash
    list.add(new WeatherState([
      "300",
      "301",
      "302",
      "500",
      "501",
      "502",
      "511",
      "520",
      "522",
      "521",
      "900"
    ], "assets/weather/rain.svg", rainColor)); //Rain
    list.add(new WeatherState(
        ["600", "601", "602", "611", "612", "621", "622", "623"],
        "assets/weather/snow.svg",
        snowColor)); //Snow
    list.add(new WeatherState(["610"], "assets/weather/snow_and_rain.svg",
        snowRainColor)); //Snow and Rain
    list.add(new WeatherState(["700", "711", "721", "731", "741", "751"],
        "assets/weather/fog.svg", fogColor)); //Fog
    list.add(new WeatherState(
        ["800", "801"], "assets/images/sun.svg", sunnyColor)); //Sun
    list.add(new WeatherState(["802", "803", "804"], "assets/weather/cloud.svg",
        cloudsColor)); //Clouds
    return list;
  }

  static WeatherState getWeatherStateById(String id) {
    for (WeatherState item in getAllStates()) {
      if (item.codes.contains(id)) {
        return item;
      }
    }
    return null;
  }

  static Color getDayNightColor(Forecast forecast, WeatherState state) {
    if (forecast.pod == "n" && state.color == sunnyColor) {
      return nightColor;
    }
    return state.color;
  }

  static Color getDayNightTextColor(HourlyForecast forecast) {
    if (forecast.pod == "n") {
      return textColorNight;
    }
    return textColorDay;
  }

  static String getDayNightImage(String pod, WeatherState state) {
    if (pod == "n" && state.color == sunnyColor) {
      return "assets/images/moon.svg";
    }
    return state.imgPath;
  }
}

class CurrentForecast implements Forecast {
  CurrentWeather _currentWeather;
  List<HourlyForecast> _hourlyForecasts;

  CurrentForecast(this._currentWeather, this._hourlyForecasts);

  @override
  String get city => _currentWeather.city;

  @override
  String get code => _currentWeather.code;

  @override
  String get date => _currentWeather.date;

  @override
  Map<String, String> get details => _currentWeather.details;

  @override
  String get pod => _currentWeather.pod;

  @override
  String get sunrise => _currentWeather.sunrise;

  @override
  String get sunset => _currentWeather.sunset;

  @override
  double get temperature => _currentWeather.temperature;

  List<HourlyForecast> get hourlyForecasts => _hourlyForecasts;

  CurrentWeather get currentWeather => _currentWeather;
}

class ForecastData {
  Forecast _currentForecast;
  List<DailyForecast> _dailyForecasts;

  ForecastData(this._currentForecast, this._dailyForecasts);

  List<DailyForecast> get dailyForecasts => _dailyForecasts;

  CurrentForecast get currentForecast => _currentForecast;
}

class HistoricalForecast {
  static const humidityMax = 100.0;
  static const precipMMMax = 163.0;
  static const pressureMax = 2026.0;
  static const winddirDegreeMax = 360.0;
  static const cloudcoverMax = 100.0;
  static const heatIndexCMax = 40.0;
  static const windSpeedMax = 222.24;

  static const weatherTempMax = 40.0;
  static const max_weather_code = 395;

  int year;
  int month;
  int day;
  double windspeedKmph;
  double humidity;
  double precipMM;
  double pressure;
  double winddirDegree;
  double cloudcover;
  double heatIndexC;

  int weatherCode;
  int tempC;

  static HistoricalForecast fromJson(Map<String, dynamic> json) {
    HistoricalForecast historicalForecast = HistoricalForecast();

    var date = json["date"];
    DateTime dateTime = DateFormat("yyyy-MM-dd").parse(date);
    historicalForecast.year = dateTime.year;
    historicalForecast.month = dateTime.month;
    historicalForecast.day = dateTime.day;
    historicalForecast.windspeedKmph =
        double.parse(json["hourly"][0]["windspeedKmph"]);
    historicalForecast.humidity = double.parse(json["hourly"][0]["humidity"]);
    historicalForecast.precipMM = double.parse(json["hourly"][0]["precipMM"]);
    historicalForecast.pressure = double.parse(json["hourly"][0]["pressure"]);
    historicalForecast.winddirDegree =
        double.parse(json["hourly"][0]["winddirDegree"]);
    historicalForecast.cloudcover =
        double.parse(json["hourly"][0]["cloudcover"]);
    historicalForecast.heatIndexC =
        double.parse(json["hourly"][0]["HeatIndexC"]);

    historicalForecast.weatherCode =
        int.parse(json["hourly"][0]["weatherCode"]);
    historicalForecast.tempC = int.parse(json["hourly"][0]["tempC"]);

    return historicalForecast;
  }

  Map<String, dynamic> toMap() {
    return {
      "year": year,
      "month": month,
      "day": day,
      "windspeedKmph": windspeedKmph,
      "humidity": humidity,
      "precipMM": precipMM,
      "pressure": pressure,
      "winddirDegree": winddirDegree,
      "weatherCode": weatherCode,
      "cloudcover": cloudcover,
      "heatIndexC": cloudcover,
      "tempC": tempC,
    };
  }

  static HistoricalForecast fromMap(Map<String, dynamic> map) {
    HistoricalForecast historicalForecast = HistoricalForecast();

    historicalForecast.year = map["year"];
    historicalForecast.month = map["month"];
    historicalForecast.day = map["day"];
    historicalForecast.windspeedKmph = map["windspeedKmph"];
    historicalForecast.humidity = map["humidity"];
    historicalForecast.precipMM = map["precipMM"];
    historicalForecast.pressure = map["pressure"];
    historicalForecast.winddirDegree = map["winddirDegree"];
    historicalForecast.cloudcover = map["cloudcover"];
    historicalForecast.heatIndexC = map["heatIndexC"];
    historicalForecast.weatherCode = map["weatherCode"];
    historicalForecast.tempC = map["tempC"];

    return historicalForecast;
  }

  List<double> get neuron {
    return <double>[
//      normalizeInput(humidity, humidityMax),
      cloudcover > 50 ? 1.0 : 0.0,
      humidity > 60 ? 1.0: 0.0,
      1.0
//      normalizeInput(tempC.toDouble(), weatherTempMax)
    ];
  }

  double get result => getOneOrZero(weatherCode);

}
