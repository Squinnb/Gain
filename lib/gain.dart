import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/levels/level.dart';

class Gain extends FlameGame with HasKeyboardHandlerComponents {
  late final CameraComponent cam;
  Player player = Player();
  late JoystickComponent joystick;

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); // into cache
    final wrld = Level(player: player, levelName: "level-01");
    cam = CameraComponent.withFixedResolution(
        world: wrld, width: 640, height: 360);
    cam.viewfinder.anchor = Anchor.topLeft;
    addAll([cam, wrld]);
    addJoystick();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    updateJoystick();
    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 16, paint: BasicPalette.white.paint()),
      background: CircleComponent(radius: 32, paint: BasicPalette.gray.paint()),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
  }

  void updateJoystick() {
    if (joystick.direction == JoystickDirection.left ||
        joystick.direction == JoystickDirection.upLeft ||
        joystick.direction == JoystickDirection.downLeft) {
      player.xMovement = -1;
    } else if (joystick.direction == JoystickDirection.right ||
        joystick.direction == JoystickDirection.upRight ||
        joystick.direction == JoystickDirection.downRight) {
      player.xMovement = 1;
    } else if (joystick.direction == JoystickDirection.idle) {
      player.xMovement = 0;
    } else {
      player.xMovement = 0;
    }
  }
}
