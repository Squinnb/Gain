import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/levels/level.dart';

class Gain extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late CameraComponent cam;
  Player player = Player();

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // into cache
    Level lvl = Level(levelName: "level-02", player: player);
    cam = CameraComponent.withFixedResolution(world: lvl, width: 940, height: 640);
    cam.follow(player);
    addAll([lvl, cam]);

    return super.onLoad();
  }
}
