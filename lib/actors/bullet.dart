import 'dart:async';
import 'dart:io';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:marvington_game/game.dart';

class Bullet extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  double xdir;
  Bullet({super.position, super.size, required this.xdir});
  final double _speed = 20;
  final Vector2 velocity = Vector2.zero();

  FutureOr<void> onLoad() {
    debugMode = true;

    animation = _createSpriteAnimation();
    add(CircleHitbox(position: position, collisionType: CollisionType.active));
    return super.onLoad();
  }

  void update(double dt) {
    velocity.x = xdir * _speed;
    position.x += velocity.x * dt;
    super.update(dt);
  }

  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    removeFromParent();
    super.onCollision(intersectionPoints, other);
  }

  SpriteAnimation _createSpriteAnimation() {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Marvington/Marv Bullet.png"),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.11,
        textureSize: Vector2.all(16),
      ),
    );
  }
}
