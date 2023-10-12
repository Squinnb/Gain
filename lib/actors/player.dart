// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:gain/game.dart';
import 'package:gain/levels/platform.dart';

enum PlayerState { idle, running, jumping, falling }

class Player extends SpriteAnimationGroupComponent with HasGameRef<Gain>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    Vector2? position,
    this.character = "Pink Man",
  }) : super(position: position, anchor: Anchor.center);
  // {
  // late Vector2 _minClamp;
  // late Vector2 _maxClamp;
  //   required Rect levelBounds
  //   _minClamp = levelBounds.topLeft.toVector2() + size;
  //   _maxClamp = levelBounds.bottomRight.toVector2() - size;
  // }

  double stepTime = 0.05;
  double xDir = 0.0;
  double _moveSpeed = 100;
  double _gravity = 10;
  double _jumpForce = 300;
  double _terminalYVelocity = 120;

  bool _jumpPressed = false;
  bool _isOnGround = true;

  Vector2 velocity = Vector2.zero();
  Vector2 up = Vector2(0, -1);
  Vector2 down = Vector2(0, 1);
  Vector2 right = Vector2(1, 0);
  Vector2 left = Vector2(-1, 0);

  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runningAnime;
  late final SpriteAnimation jumpAnime;
  late final SpriteAnimation fallAnime;

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
    xDir = 0;
    xDir += leftKeyPressed ? -1 : 0;
    xDir += rightKeyPressed ? 1 : 0;
    _jumpPressed = keysPressed.contains(LogicalKeyboardKey.space);
    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    velocity.x = xDir * _moveSpeed;
    velocity.y += _gravity;
    if (_jumpPressed) {
      if (_isOnGround) {
        velocity.y = -_jumpForce;
        _isOnGround = false;
      }
      _jumpPressed = false;
    }
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalYVelocity);
    position += (velocity * dt);
    // position.clamp(_minClamp, _maxClamp);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Platform) {
      if (intersectionPoints.length == 2) {
        Vector2 intersectOne = intersectionPoints.elementAt(0);
        Vector2 intersectTwo = intersectionPoints.elementAt(0);
        Vector2 mid = (intersectOne + intersectTwo) / 2;
        Vector2 collisionVect = absoluteCenter - mid;
        collisionVect.normalize();
        if (!other.isPassable) {
          // horiz collision check
          bool rightCollide = mid.x == other.x;
          bool leftCollide = mid.x == other.x + other.width;
          bool topCollide = mid.y == other.y + other.height;
          if (velocity.x > 0 && rightCollide) {
            // position is center of player not top left or right
            velocity.x = 0;
            position.x = other.x - (width / 2);
          } else if (velocity.x < 0 && leftCollide) {
            velocity.x = 0;
            position.x = (other.x + other.width) + (width / 2);
          }
          // ~~~~~~~~~~~~~~~~~~~~~~~~
          // vertical collision check
          if (velocity.y < 0 && topCollide) {
            velocity.y = 0;
            position.y = other.y + other.height + (height / 2);
          }
          // ~~~~~~~~~~~~~~~~~~~~~~~~~~
        }
        bool bottomCollide = mid.y == other.y;
        if (velocity.y > 0 && bottomCollide) {
          velocity.y = 0;
          position.y = other.y - (height / 2);
          _isOnGround = true;
        }

        if (up.dot(collisionVect) < 0.9) {
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
    jumpAnime = _spriteAnimation("Jump", 1);
    fallAnime = _spriteAnimation("Fall", 1);
    animations = {PlayerState.idle: idleAnime, PlayerState.running: runningAnime, PlayerState.jumping: jumpAnime, PlayerState.falling: fallAnime};
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
    if (velocity.y > 0 && !_isOnGround) playerState = PlayerState.falling;
    if (velocity.y < 0 && !_isOnGround) playerState = PlayerState.jumping;
    current = playerState;
  }
}
