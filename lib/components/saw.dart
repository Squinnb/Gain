import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:gain/game.dart';

class Saw extends SpriteAnimationComponent with HasGameRef<Gain> {
  bool isVertical;
  final double offPositive;
  final double offNegative;
  Saw({Vector2? position, Vector2? size, required this.isVertical, required this.offNegative, required this.offPositive})
      : super(position: position, size: size);

  static const double spinSpeed = 0.07;
  static const double moveSpeed = 50;
  static const double tileSize = 16;
  double xydir = 1;
  double posRange = 0;
  double negRange = 0;

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    if (isVertical) {
      negRange = position.y - offNegative * tileSize;
      posRange = position.y + offPositive * tileSize;
    } else {
      negRange = position.x - offNegative * tileSize;
      posRange = position.x + offPositive * tileSize;
    }
    animation = _createSpriteAnime();
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (isVertical) {
      _moveVert(dt);
    } else {
      _moveHorz(dt);
    }
    super.update(dt);
  }

  SpriteAnimation _createSpriteAnime() {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Saw/On (38x38).png"),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: spinSpeed,
        textureSize: Vector2.all(38),
      ),
    );
  }

  void _moveHorz(double dt) {
    if (position.x >= posRange) {
      xydir = -1;
    } else if (position.x <= negRange) {
      xydir = 1;
    }
    position.x += xydir * moveSpeed * dt;
  }

  void _moveVert(double dt) {
    if (position.y >= posRange) {
      xydir = -1;
    } else if (position.y <= negRange) {
      xydir = 1;
    }
    position.y += xydir * moveSpeed * dt;
  }
}
