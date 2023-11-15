import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import '/game.dart';

class Shitake extends SpriteAnimationComponent with HasGameRef<Gain> {
  Shitake({super.position, super.size});

  final double stepTime = 0.05;
  bool collected = false;

  @override
  FutureOr<void> onLoad() {
    animation = createSpriteAnime("Shitake", 1);
    add(RectangleHitbox(position: Vector2(10, 10), size: Vector2(12, 12)));
    return super.onLoad();
  }

  void collect() async {
    if (!collected) {
      collected = true;
      if (game.playSoundEffect) FlameAudio.play("pickupCoin1.wav", volume: game.volume);
      animation = createSpriteAnime("Collected", 6)..loop = false;
      await animationTicker?.completed;
      removeFromParent();
    }
  }

  SpriteAnimation createSpriteAnime(String imgName, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Shitake/$imgName.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
