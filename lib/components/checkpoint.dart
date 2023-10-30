import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '/actors/player.dart';
import '/game.dart';

class Checkpoint extends SpriteAnimationComponent with HasGameRef<Gain>, CollisionCallbacks {
  Checkpoint({super.position, super.size});
  double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    animation = _createSpriteAnime();
    add(RectangleHitbox(position: Vector2(18, 18), size: Vector2(12, 36), collisionType: CollisionType.passive));

    return super.onLoad();
  }

  void _raiseFlag() async {
    animation = _createSpriteAnime(name: "(Flag Out)", amount: 26);
    await animationTicker?.completed;
    animation = _createSpriteAnime(name: "(Flag Idle)", amount: 10);
    await animationTicker?.completed;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Player) {
      _raiseFlag();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  SpriteAnimation _createSpriteAnime({String name = "(No Flag)", int amount = 1}) {
    String imgUrl = "Items/Checkpoints/Checkpoint/Checkpoint $name.png";
    if (amount != 1) {
      imgUrl = "Items/Checkpoints/Checkpoint/Checkpoint $name(64x64).png";
    }
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(imgUrl),
      SpriteAnimationData.sequenced(amount: amount, stepTime: stepTime, textureSize: Vector2.all(64), loop: name == "(Flag Out)" ? false : true),
    );
  }
}
