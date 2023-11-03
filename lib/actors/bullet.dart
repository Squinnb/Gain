import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:marvington_game/enemies/bird.dart';
import 'package:marvington_game/enemies/radish.dart';
import 'package:marvington_game/game.dart';
import 'package:marvington_game/levels/platform.dart';

class Bullet extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  double xdir;
  Bullet({super.position, super.size, required this.xdir});
  final double _speed = 300;
  final Vector2 velocity = Vector2.zero();
  bool hasntHit = true;
  @override
  FutureOr<void> onLoad() {
    if (xdir < 0) flipHorizontally();
    animation = _createSpriteAnimation();
    add(CircleHitbox(collisionType: CollisionType.active));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (hasntHit) {
      velocity.x = xdir * _speed;
      position.x += velocity.x * dt;
    }
    super.update(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Bird) {
      other.die();
      _explode();
    } else if (other is Radish) {
      other.die();
      _explode();
    } else if (other is Platform) {
      FlameAudio.play("explosion.wav", volume: game.volume);
      _explode();
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  SpriteAnimation _createSpriteAnimation({String state = "Marv Bullet", int amount = 1, double ssize = 8}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Bullet/$state.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.03,
        textureSize: Vector2.all(ssize),
      ),
    );
  }

  void _explode() async {
    hasntHit = false;
    animation = _createSpriteAnimation(state: "Bullet Hit", amount: 7, ssize: 16)..loop = false;
    await animationTicker?.completed;
    removeFromParent();
  }
}
