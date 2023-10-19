import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:gain/game.dart';

enum BirdState { fly, hit }

class Bird extends SpriteAnimationGroupComponent with HasGameRef<Gain> {
  final double plusOffset;
  final double minusOffset;
  Bird({super.position, super.size, this.minusOffset = 0, this.plusOffset = 0});

  static const double birdSpeed = 0.05;
  static const double moveSpeed = 40;
  static const double tileSize = 16;
  late SpriteAnimation flyAnime;
  late SpriteAnimation hitAnime;
  double xdir = -1;
  double posRange = 0;
  double negRange = 0;

  bool wasJumpedOn(double playerBottom) {
    return playerBottom < (y + (height / 3));
  }

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    negRange = position.x - minusOffset * tileSize;
    posRange = position.x + plusOffset * tileSize;
    _loadAnimations();
    add(CircleHitbox());
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (position.x >= posRange) {
      xdir = -1;
      flipHorizontallyAroundCenter();
    } else if (position.x <= negRange) {
      xdir = 1;
      flipHorizontallyAroundCenter();
    }
    position.x += xdir * moveSpeed * dt;
    super.update(dt);
  }

  void die() async {
    FlameAudio.play("landOnEnemy.wav", volume: game.volume);
    current = BirdState.hit;
    await animationTicker?.completed;
    animationTicker?.reset();
    removeFromParent();
  }

  void _loadAnimations() {
    flyAnime = _createSpriteAnime();
    hitAnime = _createSpriteAnime(name: "Hit", amount: 5)..loop = false;
    animations = {
      BirdState.fly: flyAnime,
      BirdState.hit: hitAnime,
    };
    current = BirdState.fly;
  }

  SpriteAnimation _createSpriteAnime({String name = "Flying", int amount = 9}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/BlueBird/$name (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: birdSpeed,
        textureSize: Vector2(32, 32),
      ),
    );
  }
}
