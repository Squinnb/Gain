import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Platform extends PositionComponent with CollisionCallbacks {
  bool isPassable;
  Platform({super.position, super.size, this.isPassable = false});

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(size: Vector2(size.x, (size.y / 3)), collisionType: CollisionType.passive));
    return super.onLoad();
  }
}
