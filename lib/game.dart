import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/levels/level.dart';

class Gain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late CameraComponent cam;
  Player player = Player();
  List<String> levelNames = ["Grass Land", "Desert Plain", "Ice Mountain"];
  int _levelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // into cache
    _loadLevel();
    return super.onLoad();
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (_levelIndex < levelNames.length - 1) {
      _levelIndex++;
      _loadLevel();
    } else {
      // You beat the game
    }
  }

  void _loadLevel() {
    Level world = Level(levelName: levelNames[_levelIndex], player: player);
    cam = CameraComponent.withFixedResolution(world: world, width: 640, height: 320);
    cam.follow(player);
    addAll([world, cam]);
  }
}
