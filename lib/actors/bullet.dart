import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:marvington_game/enemies/bird.dart';
import 'package:marvington_game/enemies/radish.dart';
import 'package:marvington_game/game.dart';
import 'package:marvington_game/levels/platform.dart';

class Bullet extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  double xdir;
  Bullet({super.position, super.size, required this.xdir});
  final double _speed = 300;
  final Vector2 velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() {
    if (xdir < 0) flipHorizontally();
    animation = _createSpriteAnimation();
    add(CircleHitbox(collisionType: CollisionType.active));
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    velocity.x = xdir * _speed;
    position.x += velocity.x * dt;
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bird) {
      other.die();
      removeFromParent();
    } else if (other is Radish) {
      other.die();
      removeFromParent();
    } else if (other is Platform) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
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
