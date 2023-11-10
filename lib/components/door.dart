import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/game.dart';

class Door extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  String levelName;
  Door({super.position, super.size, required this.levelName});
  double stepTime = 0.01;

  @override
  FutureOr<void> onLoad() {
    priority = -2;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Background/Door/Door.png"),
      SpriteAnimationData.sequenced(amount: 1, stepTime: stepTime, textureSize: Vector2(24, 32), loop: false),
    );
    add(RectangleHitbox(position: Vector2(1, 0), size: Vector2(22, 32), collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
