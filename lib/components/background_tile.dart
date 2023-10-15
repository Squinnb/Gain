import 'dart:async';

import 'package:flame/components.dart';
import 'package:gain/game.dart';

class BackgroundTile extends SpriteComponent with HasGameRef<Gain> {
  String color;
  BackgroundTile({Vector2? position, this.color = "Gray"}) : super(position: position);

  @override
  FutureOr<void> onLoad() {
    size = Vector2.all(64);
    sprite = Sprite(game.images.fromCache("Background/$color.png"));
    return super.onLoad();
  }
}
