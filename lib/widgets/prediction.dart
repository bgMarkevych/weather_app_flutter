import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meteoshipflutter/blocks/prediction_block.dart';

class PredictionWidget extends StatefulWidget {
  @override
  _PredictionWidgetState createState() => _PredictionWidgetState();
}

class _PredictionWidgetState extends State<PredictionWidget>
    with TickerProviderStateMixin {

  PredictionBlock _block;

  AnimationController _rotationAnimationController;
  AnimationController _positionAnimationController;
  Animation<double> _rotationAnimation;
  Animation<Offset> _positionAnimation;

  @override
  void initState() {
    _block = PredictionBlock();
    _rotationAnimationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _positionAnimationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _rotationAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_rotationAnimationController);
    _rotationAnimationController.repeat(reverse: true);
    _positionAnimation = Tween(begin: Offset(-0.8, 0.0), end: Offset(0.8, 0.0))
        .animate(_positionAnimationController);
    _positionAnimationController.repeat(reverse: true);
    _block.startFlow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlideTransition(
              position: _positionAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: SvgPicture.asset(
                  "assets/images/sheep_for_animation.svg",
                  width: 100,
                ),
              ),
            ),
            SizedBox(height: 32),
            StreamBuilder<DataStatus>(
              stream: _block.dataStatusStream,
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Container();
                }
                return Text(
                  snapshot.data == DataStatus.loading ? "Loading..." : snapshot.data == DataStatus.training ? "Training..." : "Prediction in concole",
                  style: TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rotationAnimationController.dispose();
    _positionAnimationController.dispose();
    super.dispose();
  }
}
