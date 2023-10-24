import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gain/game.dart';

class Fire extends SpriteAnimationComponent with HasGameRef<Gain> {
  Fire({super.position, super.size});
  late SpriteAnimation anime;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox());
    anime = SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Fire/On (16x32).png"),
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.12,
        textureSize: Vector2(16, 32),
      ),
    );
    animation = anime;
    return super.onLoad();
  }
}
