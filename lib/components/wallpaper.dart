import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:gain/game.dart';

class WallPaper extends ParallaxComponent<Gain> with HasGameRef<Gain> {
  String color;
  WallPaper({Vector2? position, this.color = "Gray"}) : super(position: position);

  FutureOr<void> onLoad() async {
    priority = -2;
    size = Vector2.all(64);
    parallax = await gameRef
        .loadParallax([ParallaxImageData("Background/$color.png")], baseVelocity: Vector2(0, -20), repeat: ImageRepeat.noRepeat, fill: LayerFill.none);

    return super.onLoad();
  }
}
