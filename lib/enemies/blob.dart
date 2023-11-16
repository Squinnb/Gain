import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:marvington_game/actors/bullet.dart';
import '/game.dart';

enum BlobState { moving, hit }

class Blob extends SpriteAnimationGroupComponent with HasGameRef<Gain>, CollisionCallbacks {
  final double plusOffset;
  final double minusOffset;
  final bool flying;
  Blob({super.position, super.size, this.minusOffset = 0, this.plusOffset = 0, this.flying = false});
  static const double blobSpeed = 0.05;
  static const double moveSpeed = 50;
  static const double tileSize = 16;
  late SpriteAnimation moveAnime;
  late SpriteAnimation idleAnime;
  late SpriteAnimation hitAnime;
  double xdir = -1;
  double posRange = 0;
  double negRange = 0;
  bool beingHit = false;
  int _health = 1;
  bool dead = false;

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

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Bullet) {
      if (!beingHit && _health > 1) {
        beingHit = true;
        FlameAudio.play("landOnEnemy.wav", volume: game.volume);
        _health--;
        current = BlobState.hit;
        await animationTicker?.completed;
        current = BlobState.moving;
        beingHit = false;
      } else if (!beingHit && _health <= 1) {
        die();
      }
    }
  }

  void die() async {
    dead = true;
    FlameAudio.play("landOnEnemy.wav", volume: game.volume);
    current = BlobState.hit;
    await animationTicker?.completed;
    animationTicker?.reset();
    removeFromParent();
  }

  void _loadAnimations() {
    moveAnime = _createSpriteAnime(name: "Run", amount: flying ? 5 : 6);
    hitAnime = _createSpriteAnime(name: "Hit", amount: 4)..loop = false;
    animations = {
      BlobState.moving: moveAnime,
      BlobState.hit: hitAnime,
    };
    current = BlobState.moving;
  }

  SpriteAnimation _createSpriteAnime({required String name, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Enemies/Blob/${flying ? "Flying " : ""}Blob $name.png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: blobSpeed,
        textureSize: Vector2.all(flying ? 32 : 30),
      ),
    );
  }
}
