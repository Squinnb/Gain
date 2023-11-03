import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/game.dart';

enum FireState { off, on, start }

class Fire extends SpriteAnimationComponent with HasGameRef<Gain> {
  Fire({super.position, super.size});
  int accTime = 0;
  late Map<FireState, SpriteAnimation> animations;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());
    animations = {
      FireState.off: _createAnimation(),
      FireState.on: _createAnimation(name: "On", amount: 3),
      FireState.start: _createAnimation(name: "Start", amount: 6)..loop = false
    };
    animation = animations[FireState.off];
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    accTime++;
    if ((accTime / 60) > 3) {
      _toggleFire();
      accTime = 0;
    }
    super.update(dt);
  }

  SpriteAnimation _createAnimation({String name = "Off", int amount = 1}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Fire/Fire $name.png"),
      SpriteAnimationData.sequenced(amount: amount, stepTime: 0.12, textureSize: Vector2(16, 32)),
    );
  }

  bool isActive() {
    return animation == animations[FireState.on];
  }

  void _toggleFire() async {
    if (isActive()) {
      animation = animations[FireState.off];
    } else {
      animation = animations[FireState.start];
      await animationTicker?.completed;
      animation = animations[FireState.on];
    }
  }
}
