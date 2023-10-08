import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gain/marvington_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  Gain game = Gain();
  runApp(GameWidget(game: kDebugMode ? Gain() : game)); // this ensures whole game reloads in dev mode
}
