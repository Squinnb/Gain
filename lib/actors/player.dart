import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:gain/gain.dart';
import 'package:gain/levels/collision_block.dart';

enum PlayerState { idle, running }

class Player extends SpriteAnimationGroupComponent with HasGameRef<Gain>, KeyboardHandler {
  String character;
  Player({pos, this.character = "Ninja Frog"}) : super(position: pos);

  final double stepTime = 0.05;
  final double _gravity = 9.8;
  final double _jumpForce = 360;
  final double _terminalVelocity = 300;
  bool isOnGround = true;
  bool hasJumped = false;
  double xDirection = 0.0;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero(); // if y > 0 = falling, y < 0 = jumping?
  List<CollisionBlock> collisionBlocks = [];

  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runningAnime;
  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerState();
    _updatePlayerMovement(dt);
    _checkHorizontalCollisions();
    _applyGravity(dt);
    _checkVerticalCollisions();
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool leftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    bool rightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);

    xDirection = leftKeyPressed ? -1 : 0;
    xDirection = rightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnime = _spriteAnimation("Idle", 11);
    runningAnime = _spriteAnimation("Run", 12);
    animations = {PlayerState.idle: idleAnime, PlayerState.running: runningAnime};
    current = PlayerState.running;
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

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;
    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x > 0 || velocity.x < 0) playerState = PlayerState.running;
    current = playerState;
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) _playerJump(dt);
    velocity.x = xDirection * moveSpeed;
    position.x += (velocity.x * dt);
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      Rect playerRect = toRect();
      Rect blockRect = block.toRect();
      if (playerRect.overlaps(blockRect)) {
        if (xDirection < 0) {
          velocity.x = 0;
          position.x = blockRect.right + playerRect.width;
          break;
        } else if (xDirection > 0) {
          velocity.x = 0;
          position.x = blockRect.left - playerRect.width;
          break;
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpForce;
    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  void _checkVerticalCollisions() {
    Rect playerRect = toRect();
    for (final block in collisionBlocks) {
      Rect blockRect = block.toRect();
      if (block.isPlatform) {
        if (playerRect.overlaps(blockRect) && position.y + playerRect.height < blockRect.height) {
          if (velocity.y > 0) {
            // falling
            velocity.y = 0;
            position.y = block.y - playerRect.height;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (playerRect.overlaps(blockRect)) {
          if (velocity.y > 0) {
            // falling
            velocity.y = 0;
            position.y = block.y - playerRect.height;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            // jumping
            velocity.y = 0;
            position.y = block.y + blockRect.height;
          }
        }
      }
    }
  }
}
