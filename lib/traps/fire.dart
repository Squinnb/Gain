import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gain/game.dart';

enum FireState { off, on, start }

class Fire extends SpriteAnimationGroupComponent with HasGameRef<Gain> {
  Fire({super.position, super.size});
  int accTime = 0;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());
    animations = {
      FireState.off: _createAnimation(),
      FireState.on: _createAnimation(name: "On", amount: 3),
      FireState.start: _createAnimation(name: "Start", amount: 4)
    };
    current = FireState.off;
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    accTime++;
    if ((accTime / 60) > 2) {
      _toggleFire();
      accTime = 0;
    }
    super.update(dt);
  }

  SpriteAnimation _createAnimation({String name = "Off", int amount = 1}) {
    String dim = name != "Off" ? "(16x32)" : "(16x16)";
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Fire/$name $dim.png"),
      SpriteAnimationData.sequenced(amount: amount, stepTime: 0.12, textureSize: Vector2(16, 32), loop: name != "start"),
    );
  }

  bool isActive() {
    return current == FireState.on;
  }

  void _toggleFire() async {
    if (isActive()) {
      current = FireState.off;
    } else {
      // current = FireState.start;
      // await animationTicker?.completed;
      current = FireState.on;
    }
  }
}
