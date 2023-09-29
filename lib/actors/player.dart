import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:gain/gain.dart';

enum PlayerState { idle, running }

enum PlayerDirection { left, right, center }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<Gain>, KeyboardHandler {
  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runningAnime;
  String character;
  Player({pos, this.character = "Ninja Frog"}) : super(position: pos);

  final double stepTime = 0.05;
  PlayerDirection direction = PlayerDirection.center;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool leftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    bool rightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (leftKeyPressed && rightKeyPressed)
      direction = PlayerDirection.center;
    else if (leftKeyPressed)
      direction = PlayerDirection.left;
    else if (rightKeyPressed)
      direction = PlayerDirection.right;
    else
      direction = PlayerDirection.center;

    return super.onKeyEvent(event, keysPressed);
  }

  void _loadAllAnimations() {
    idleAnime = _spriteAnimation("Idle", 11);
    runningAnime = _spriteAnimation("Run", 12);
    animations = {
      PlayerState.idle: idleAnime,
      PlayerState.running: runningAnime
    };
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

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    if (direction == PlayerDirection.left) {
      if (isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = false;
      }
      current = PlayerState.running;
      dirX -= moveSpeed;
    } else if (direction == PlayerDirection.right) {
      if (!isFacingRight) {
        flipHorizontallyAroundCenter();
        isFacingRight = true;
      }
      current = PlayerState.running;
      dirX += moveSpeed;
    } else if (direction == PlayerDirection.center) {
      current = PlayerState.idle;
    }
    velocity = Vector2(dirX, 0.0);
    position += velocity * dt;
  }
}
