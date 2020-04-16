import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:meteoshipflutter/blocks/splash_bloc.dart';
import 'package:meteoshipflutter/utils/colors.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenState();
}

class SplashScreenState extends State {
  var block;
  var _isLoaderVisible = true;

  @override
  void initState() {
    super.initState();
    block = SplashBloc((error) => onError(error));
    block.fetchData(startNewScreen);
  }

  void onError(String error) async {
    setState(() {
      _isLoaderVisible = false;
    });
    var dialog = AlertDialog(
      title: Text("Ooooops"),
      content: Text(error),
    );
    await showDialog(context: context, child: dialog);
  }

  void startNewScreen() {
    Navigator.pushReplacementNamed(context, "/weather");
  }

  @override
  Widget build(context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: splashScreenColor,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    child: Center(
                      child: SvgPicture.asset('assets/images/splash.svg'),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 32.0),
                    child: Text(
                      "Meteosheep",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 36.0,
                      ),
                    ),
                  ),
                  Text(
                    "Current weather and weather forecast",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(bottom: 32.0),
                  child: Visibility(
                    visible: _isLoaderVisible,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    block.dispose();
    super.dispose();
  }
}
