import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '/actors/player.dart';
import '/levels/level.dart';

class Gain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  Player player = Player();
  Set<String> levelNames = {"Blue World One", "Blue World Two", "Blue World Three", "Blue World Four"};
  double volume = 0.2;
  bool playSoundEffect = true;
  double camWidth = 640;
  double camHeight = 320;
  CameraComponent cam = CameraComponent.withFixedResolution(width: 640, height: 320);
  late Level currWorld;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // into cache
    _loadLevel("Blue World One");
    add(cam);
    return super.onLoad();
  }

  void loadNextLevel(String levelName) {
    removeWhere((component) => component is Level);
    if (levelNames.contains(levelName)) {
      _loadLevel(levelName);
    }
  }

  void _loadLevel(String levelName) {
    Level world = Level(levelName: levelName, player: player);
    currWorld = world;
    cam.world = world;
    add(world);
  }
}
