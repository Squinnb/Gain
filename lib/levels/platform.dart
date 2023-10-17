import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends PositionComponent with CollisionCallbacks {
  bool isPassable;
  Platform({super.position, super.size, this.isPassable = false});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: Vector2(size.x, isPassable ? (size.y / 3) : size.y), collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
