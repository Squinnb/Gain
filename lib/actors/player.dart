import 'dart:async';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:gain/marvington_game.dart';
import 'package:gain/levels/platform.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent with HasGameRef<Gain>, KeyboardHandler, CollisionCallbacks {
  String character;
  late Vector2 _minClamp;
  late Vector2 _maxClamp;
  Player({pos, this.character = "Pink Man", required Rect levelBounds}) : super(position: pos, anchor: Anchor.center) {
    _minClamp = levelBounds.topLeft.toVector2() + size;
    _maxClamp = levelBounds.bottomRight.toVector2() - size;
  }

  final double stepTime = 0.05;
  double xDirection = 0.0;
  final double _moveSpeed = 100;
  final double _gravity = 10;
  final double _jumpSpeed = 300;
  bool _jumpPressed = false;
  bool _isOnGround = false;
  Vector2 velocity = Vector2.zero();
  Vector2 up = Vector2(0, -1);
  Vector2 down = Vector2(0, 1);

  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runningAnime;

  @override
  FutureOr<void> onLoad() {
    add(CircleHitbox(collisionType: CollisionType.active));
    _loadAllAnimations();
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateAnimation();
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool leftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    bool rightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);
    xDirection = 0;
    xDirection += leftKeyPressed ? -1 : 0;
    xDirection += rightKeyPressed ? 1 : 0;
    _jumpPressed = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = xDirection * _moveSpeed;
    velocity.y += _gravity;
    if (_jumpPressed) {
      if (_isOnGround) {
        velocity.y = -_jumpSpeed;
        _isOnGround = false;
      }
      _jumpPressed = false;
    }
    velocity.y = velocity.y.clamp(-_jumpSpeed, 150);
    position += (velocity * dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        Vector2 mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
        Vector2 collisionVect = absoluteCenter - mid; // going down
        double penDist = (size.x / 2) - collisionVect.length;
        collisionVect.normalize();
        position += collisionVect.scaled(penDist);

        // wt frick man, vector is mag/len(eg 5mph) AND direction(eg left, south)
        // so velocity is a vector, but why is position? isn't position purely x & y cordinate
        if (up.dot(collisionVect) > 0.9) {
          _isOnGround = true;
        }
      }
    }
    super.onCollision(intersectionPoints, other);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache("Main Characters/$character/$state (32x32).png"),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnime = _spriteAnimation("Idle", 11);
    runningAnime = _spriteAnimation("Run", 12);
    animations = {PlayerState.idle: idleAnime, PlayerState.running: runningAnime};
    current = PlayerState.running;
  }

  void _updateAnimation() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    current = playerState;
  }
}
