import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import '/actors/player.dart';
import '/levels/level.dart';

class Gain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late CameraComponent cam;
  Player player = Player();
  Set<String> levelNames = {"Blue World One", "Blue World Two", "Blue World Three"};
  double volume = 0.2;
  bool playSoundEffect = true;
  late Level currLevel;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // into cache
    _loadLevel("Blue World One");
    return super.onLoad();
  }

  void loadNextLevel(String levelName) {
    removeWhere((component) => component is Level);
    if (levelNames.contains(levelName)) {
      _loadLevel(levelName);
    } else {
      print("Name Error in tiled.");
    }
  }

  void _loadLevel(String levelName) {
    Level world = Level(levelName: levelName, player: player);
    currLevel = world;
    cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 320);
    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([world, cam]);
  }
}
