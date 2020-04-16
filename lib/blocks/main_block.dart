import 'dart:async';

import 'package:meteoshipflutter/blocks/base_block.dart';
import 'package:meteoshipflutter/model/di/di.dart';

class MainBlock extends BaseBlock {
  MainBlock() : super() {
    DIManager.provide();
  }

  Stream<bool> get screenStream async* {
    bool splashResult = await DIManager.model.needToShowSplash();
    yield splashResult;
  }
}
