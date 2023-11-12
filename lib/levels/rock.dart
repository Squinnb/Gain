import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:marvington_game/actors/bullet.dart';
import 'package:marvington_game/levels/platform.dart';
import '/game.dart';

class Rock extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  Rock({super.position, super.size});
  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox(collisionType: CollisionType.passive));
    animation = _spriteAnimation();
    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Bullet) {
      _break();
    }
  }

  SpriteAnimation _spriteAnimation({String name = "Rock", int amount = 1}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Terrain/$name.png"),
      SpriteAnimationData.sequenced(amount: amount, stepTime: 0.008, textureSize: Vector2.all(16)),
    );
  }

  void _break() async {
    animation = _spriteAnimation(name: "Rock Break", amount: 5)..loop = false;
    game.currWorld.removeWhere((component) => (component is Platform && component.position == position));
    game.player.platforms.removeWhere((Platform p) => p.position == position);
    await animationTicker?.completed;
    removeFromParent();
  }
}
