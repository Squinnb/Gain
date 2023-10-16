import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gain/game.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<Gain> {
  String fruitType;
  Fruit({this.fruitType = "Cherries", Vector2? position, Vector2? size}) : super(position: position, size: size);

  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    animation = createSpriteAnime(fruitType, 17);
    add(RectangleHitbox(position: Vector2(10, 10), size: Vector2(12, 12)));
    return super.onLoad();
  }

  void collect() async {
    animation = createSpriteAnime("Collected", 6)..loop = false;
    await animationTicker?.completed;
    removeFromParent();
  }

  SpriteAnimation createSpriteAnime(String imgName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$imgName.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
