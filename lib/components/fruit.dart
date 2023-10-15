import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gain/game.dart';

class Fruit extends SpriteAnimationComponent with HasGameRef<Gain> {
  String fruitType;
  Fruit({this.fruitType = "Cherries", Vector2? position, Vector2? size}) : super(position: position, size: size);

  final double stepTime = 0.05;
  bool _collected = false;

  @override
  FutureOr<void> onLoad() {
    animation = createSpriteAnime(fruitType, 17);
    add(RectangleHitbox(position: Vector2(10, 10), size: Vector2(12, 12)));
    return super.onLoad();
  }

  void collect() async {
    if (!_collected) {
      animation = createSpriteAnime("Collected", 6, loop: _collected);
      _collected = true;
      await Future.delayed(const Duration(milliseconds: 300));
      removeFromParent();
    }
  }

  SpriteAnimation createSpriteAnime(String imgName, int amount, {bool loop = true}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$imgName.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: loop,
      ),
    );
  }
}
