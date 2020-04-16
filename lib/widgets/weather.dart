import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meteoshipflutter/blocks/weather_blocks.dart';
import 'package:meteoshipflutter/model/data/data_model.dart';
import 'package:meteoshipflutter/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'maps.dart';

typedef ColorValue = Function(Color);

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherBlock _weatherBlock = new WeatherBlock();
  AnimationController _animationController;
  Animation<double> _rotationAnimation;

  int _selectedMenuItem = 0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _rotationAnimation =
        Tween<double>(begin: 0.0, end: 360.0).animate(_animationController);
    _animationController.repeat();
    _weatherBlock.getData();
    super.initState();
  }

  @override
  void dispose() {
    _weatherBlock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController = new PageController();
    return StreamBuilder<Color>(
        stream: _weatherBlock.colorStream,
        initialData: sunnyColor,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: snapshot.data,
            body: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: StreamBuilder<ForecastData>(
                            stream: _weatherBlock.forecastStream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: PageView(
                                  controller: pageController,
                                  onPageChanged: (position) {
                                    if (position == 0) {
                                      _weatherBlock.pushColor(
                                          WeatherState.getDayNightColor(
                                              snapshot.data.currentForecast,
                                              WeatherState.getWeatherStateById(
                                                  snapshot.data.currentForecast
                                                      .code)));
                                    } else {
                                      _weatherBlock.pushColor(
                                          WeatherState.getDayNightColor(
                                              snapshot.data.dailyForecasts[0],
                                              WeatherState.getWeatherStateById(
                                                  snapshot
                                                      .data
                                                      .dailyForecasts[0]
                                                      .code)));
                                    }
                                    setState(() {
                                      _selectedMenuItem = position;
                                    });
                                  },
                                  children: <Widget>[
                                    CurrentWeatherWidget(
                                        snapshot.data.currentForecast),
                                    DailyForecastWidget(
                                        snapshot.data.dailyForecasts,
                                        _weatherBlock),
                                  ],
                                ),
                              );
                            }),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          StreamBuilder<Map<String, double>>(
                              stream: _weatherBlock.coordinatesStream,
                              builder: (context, snapshot) {
                                return InkWell(
                                  onTap: () async {
                                    LatLng result =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (builder) => MapsWidget(
                                              snapshot.data["lat"],
                                              snapshot.data["lon"])),
                                    );
                                    if (result == null) {
                                      return;
                                    }
                                    _weatherBlock.fetchData(result.latitude,
                                        result.longitude, _selectedMenuItem);
                                  },
                                  child: StreamBuilder<String>(
                                      stream: _weatherBlock.cityNameStream,
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Text("");
                                        }
                                        return Text(snapshot.data,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600));
                                      }),
                                );
                              }),
                          SizedBox(width: 10),
                          SvgPicture.asset("assets/images/arrow_down.svg"),
                        ],
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: StreamBuilder<bool>(
                              initialData: false,
                              stream: _weatherBlock.dataAnimationStream,
                              builder: (context, snapshot) {
                                print(snapshot.data.toString() + " animation");
                                return Container(
                                  child: InkWell(
                                    onTap: () {
                                      _weatherBlock
                                          .refreshData(_selectedMenuItem);
                                    },
                                    child: snapshot.data
                                        ? RotationTransition(
                                            turns: _rotationAnimation,
                                            child: SvgPicture.asset(
                                                "assets/images/refresh-button.svg"),
                                          )
                                        : SvgPicture.asset(
                                            "assets/images/refresh-button.svg"),
                                  ),
                                );
                              }),
                        ),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 70,
                    margin: EdgeInsets.only(bottom: 8),
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            pageController.animateToPage(0,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                            setState(() => _selectedMenuItem = 0);
                          },
                          child: Column(
                            children: <Widget>[
                              BottomMenuItem("assets/images/current_date.svg",
                                  "Current Date"),
                              Container(
                                  height: 2,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: _selectedMenuItem == 0
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                  ))
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            pageController.animateToPage(1,
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeIn);
                            setState(() => _selectedMenuItem = 1);
                          },
                          child: Column(
                            children: <Widget>[
                              BottomMenuItem(
                                  "assets/images/daily_weather.svg", "16 Days"),
                              Container(
                                  height: 2,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: _selectedMenuItem == 1
                                        ? Colors.redAccent
                                        : Colors.transparent,
                                  ))
                            ],
                          ),
                        ),
                        BottomMenuItem(
                            "assets/images/predict_weather.svg", "Predict"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class BottomMenuItem extends StatelessWidget {
  final String _imgPath;
  final String _title;

  BottomMenuItem(this._imgPath, this._title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 32, left: 32, top: 8, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(_imgPath),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              _title,
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 12),
            ),
          )
        ],
      ),
    );
  }
}

class TopForecastContainer extends StatelessWidget {
  final Forecast _data;

  const TopForecastContainer(this._data, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = WeatherState.getWeatherStateById(_data.code);
    var dateFormat = new DateFormat("yyyy-MM-dd HH:mm");
    var dateTime = dateFormat.parse(_data.date);
    return Container(
      margin: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: MediaQuery.of(context).size.height * 0.15),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DateWidget(
                      dateTime.day.toString(),
                      new DateFormat.MMMM().format(dateTime),
                      dateTime.year.toString()),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SvgPicture.asset('assets/images/sun.svg'),
                      SizedBox(width: 8),
                      Text(
                        _data.sunrise.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SvgPicture.asset('assets/images/moon.svg'),
                      SizedBox(width: 8),
                      Text(
                        _data.sunset.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
              SvgPicture.asset(
                  Sheep.getImgPathByTemperature(_data.temperature.toInt()),
                  width: MediaQuery.of(context).size.height * 0.17)
            ],
          ),
          SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(WeatherState.getDayNightImage(_data.pod, state),
                  width: 50),
              SizedBox(width: 16),
              Text(
                _data.temperature.toInt().toString() + "°",
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w600),
              )
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 1,
                color: sunnyColor,
                width: MediaQuery.of(context).size.width * 0.33,
              ),
              Text("Details",
                  style: TextStyle(color: Colors.black87, fontSize: 18)),
              Container(
                height: 1,
                color: sunnyColor,
                width: MediaQuery.of(context).size.width * 0.33,
              ),
            ],
          )
        ],
      ),
    );
  }
}

class DateWidget extends StatelessWidget {
  final String _day;
  final String _month;
  final String _year;

  DateWidget(this._day, this._month, this._year);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          _day,
          style: TextStyle(
              color: Colors.white, fontSize: 64, fontWeight: FontWeight.w600),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _year,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 26),
            ),
            Text(
              _month,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
            ),
          ],
        ),
      ],
    );
  }
}

class DetailsContainer extends StatefulWidget {
  final Forecast forecast;
  final position;

  DetailsContainer(this.forecast, {this.position = -1});

  @override
  _DetailsContainerState createState() => _DetailsContainerState();
}

class _DetailsContainerState extends State<DetailsContainer> {
  int _currentPosition = 0;

  @override
  Widget build(BuildContext context) {
    PageController pageController = new PageController();
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: PageView(
              controller: pageController,
              onPageChanged: (index) =>
                  setState(() => _currentPosition = index),
              children: getForecasrDetailsPagerWidgetsList(
                  widget.forecast, pageController),
            ),
          ),
          SizedBox(height: 16),
          Flexible(
            flex: 1,
            child: !(widget.forecast is CurrentForecast)
                ? widget.position == 0
                    ? Center(
                        child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                        size: 50,
                      ))
                    : Container()
                : ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: 2,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        width: _currentPosition == index ? 15 : 10,
                        height: _currentPosition == index ? 15 : 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: sunnyColor,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

List<Widget> getForecasrDetailsPagerWidgetsList(
    final Forecast forecast, PageController pageController) {
  var list = <Widget>[];
  list.add(DetailsWidget(forecast.details));
  if (forecast is CurrentForecast) {
    var _scrollController = ScrollController();
    list.add(NotificationListener(
      onNotification: (t) {
        if (t is ScrollEndNotification) {
          if (_scrollController.position.pixels == 0.0) {
            pageController.animateToPage(0,
                duration: Duration(milliseconds: 500), curve: Curves.easeIn);
          }
        }
        return true;
      },
      child: ListView.builder(
          controller: _scrollController,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: forecast.hourlyForecasts.length,
          itemBuilder: (context, position) {
            WeatherState state = WeatherState.getWeatherStateById(
                forecast.hourlyForecasts[position].code);
            final DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
            DateTime dateTime =
                dateFormat.parse(forecast.hourlyForecasts[position].datetime);
            return Padding(
              padding: const EdgeInsets.only(right: 8, left: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    forecast.hourlyForecasts[position].temp.toInt().toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: WeatherState.getDayNightTextColor(
                            forecast.hourlyForecasts[position])),
                  ),
                  SizedBox(height: 8),
                  SvgPicture.asset(
                      WeatherState.getDayNightImage(
                          forecast.hourlyForecasts[position].pod, state),
                      width: 37,
                      height: 37),
                  SizedBox(height: 8),
                  Text(
                    dateTime.hour.toString().length == 1
                        ? "0" + dateTime.hour.toString() + ":00"
                        : dateTime.hour.toString() + ":00",
                    style: TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.black87),
                  ),
                ],
              ),
            );
          }),
    ));
  }
  return list;
}

class DetailsWidget extends StatelessWidget {
  final Map<String, dynamic> map;

  DetailsWidget(this.map);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DetailItem(map.keys.elementAt(0), map[map.keys.elementAt(0)],
                Colors.redAccent),
            SizedBox(height: 8),
            DetailItem(map.keys.elementAt(2), map[map.keys.elementAt(2)],
                Colors.lightBlueAccent),
            SizedBox(height: 8),
            DetailItem(map.keys.elementAt(4), map[map.keys.elementAt(4)],
                Colors.black87)
          ],
        ),
        SizedBox(width: 32),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DetailItem(map.keys.elementAt(1), map[map.keys.elementAt(1)],
                Colors.black87),
            SizedBox(height: 8),
            DetailItem(map.keys.elementAt(3), map[map.keys.elementAt(3)],
                Colors.black87),
            SizedBox(height: 8),
            DetailItem(map.keys.elementAt(5), map[map.keys.elementAt(5)],
                Colors.black87)
          ],
        )
      ],
    );
  }
}

class DetailItem extends StatelessWidget {
  final String _title;
  final String _value;
  final Color _valueColor;

  DetailItem(this._title, this._value, this._valueColor);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          _title + ":",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(width: 8),
        Text(
          _value,
          style: TextStyle(
              color: _valueColor, fontWeight: FontWeight.w600, fontSize: 16),
        )
      ],
    );
  }
}

class CurrentWeatherWidget extends StatelessWidget {
  final CurrentForecast _snapshot;

  CurrentWeatherWidget(this._snapshot);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(300, 100),
                topRight: Radius.elliptical(200, 15),
                bottomLeft: Radius.elliptical(200, 30),
                bottomRight: Radius.elliptical(200, 30),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.6,
          ),
        ),
        Column(
          verticalDirection: VerticalDirection.down,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              child: TopForecastContainer(_snapshot),
            ),
            SizedBox(height: 16),
            Container(child: DetailsContainer(_snapshot)),
          ],
        ),
      ],
    );
  }
}

class DailyForecastWidget extends StatefulWidget {
  final List<DailyForecast> _data;
  final WeatherBlock _weatherBlock;

  DailyForecastWidget(this._data, this._weatherBlock);

  @override
  _DailyForecastWidgetState createState() => _DailyForecastWidgetState();
}

class _DailyForecastWidgetState extends State<DailyForecastWidget>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return PageView(
      onPageChanged: (position) {
        widget._weatherBlock.pushColor(
            WeatherState.getWeatherStateById(widget._data[position].code)
                .color);
      },
      physics: BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: _getPagerItems(widget._data, context, this),
    );
  }

  List<Widget> _getPagerItems(final List<DailyForecast> _data,
      BuildContext context, TickerProvider tickerProvider) {
    var widgets = <Widget>[];
    for (int i = 0; i < _data.length; i++) {
      widgets.add(Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(300, 100),
                  topRight: Radius.elliptical(200, 15),
                  bottomLeft: Radius.elliptical(200, 30),
                  bottomRight: Radius.elliptical(200, 30),
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
            ),
          ),
          Column(
            verticalDirection: VerticalDirection.down,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                child: TopForecastContainer(_data[i]),
              ),
              SizedBox(height: 16),
              Container(
                  child: DetailsContainer(
                _data[i],
                position: i,
              )),
            ],
          ),
        ],
      ));
    }
    return widgets;
  }
}
