import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:gain/game.dart';

enum RadishState { idle, run, hit }

class Radish extends SpriteAnimationGroupComponent with HasGameRef<Gain> {
  final double plusOffset;
  final double minusOffset;
  Radish({super.position, super.size, this.minusOffset = 0, this.plusOffset = 0});

  static const double radishSpeed = 0.05;
  static const double moveSpeed = 50;
  static const double tileSize = 16;
  late SpriteAnimation runAnime;
  late SpriteAnimation idleAnime;
  late SpriteAnimation hitAnime;
  double xdir = -1;
  double posRange = 0;
  double negRange = 0;

  bool wasJumpedOn(double playerBottom) {
    return playerBottom < (y + (height / 2));
  }

  @override
  FutureOr<void> onLoad() {
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
    current = RadishState.hit;
    await animationTicker?.completed;
    animationTicker?.reset();
    removeFromParent();
  }

  void _loadAnimations() {
    idleAnime = _createSpriteAnime();
    runAnime = _createSpriteAnime(name: "Run", amount: 12);
    hitAnime = _createSpriteAnime(name: "Hit", amount: 5)..loop = false;
    animations = {
      RadishState.idle: idleAnime,
      RadishState.run: runAnime,
      RadishState.hit: hitAnime,
    };
    current = RadishState.run;
  }

  SpriteAnimation _createSpriteAnime({String name = "Idle 1", int amount = 6}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Radish/$name (30x38).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: radishSpeed,
        textureSize: Vector2(30, 38),
      ),
    );
  }
}
