import 'package:flutter/material.dart';
import 'package:meteoshipflutter/model/di/di.dart';
import 'package:meteoshipflutter/widgets/splash.dart';
import 'package:meteoshipflutter/widgets/weather.dart';
import 'package:meteoshipflutter/utils/colors.dart';
import 'package:flutter/cupertino.dart';

import 'blocks/main_block.dart';

void main() {
  runApp(MeteoShipApp());
}

class MeteoShipApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MainBlock _mainBlock = MainBlock();
    return MaterialApp(
      routes: {"/weather": (context) => WeatherScreen()},
      debugShowCheckedModeBanner: false,
      theme: ThemeData(accentColor: splashScreenColor),
      home: StreamBuilder<bool>(
        builder: (context, event) {
          if (event.hasData) {
            if(!event.data){
              return WeatherScreen();
            }
            return SplashScreen();
          }
          return Scaffold(appBar: AppBar(),body: Text("hui"),);
        },
        stream: _mainBlock.screenStream,
      ),
    );
  }
}
