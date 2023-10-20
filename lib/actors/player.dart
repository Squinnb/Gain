// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:gain/enemies/bird.dart';
import 'package:gain/components/checkpoint.dart';
import 'package:gain/components/fruit.dart';
import 'package:gain/enemies/radish.dart';
import 'package:gain/traps/saw.dart';
import 'package:gain/game.dart';
import 'package:gain/levels/platform.dart';
import 'package:gain/traps/fire.dart';

enum PlayerState { appear, idle, running, jumping, falling, disappear, hit }

class Player extends SpriteAnimationGroupComponent with HasGameRef<Gain>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    super.position,
    super.anchor = Anchor.center,
    this.character = "Pink Man",
  });
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
  double _gravity = 12;
  double _jumpForce = 350;
  double _terminalYVelocity = 200;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  static const Duration _dur = Duration(milliseconds: 350); //stepTime(50 milisec) * 7 stepFrames = 350

  bool _jumpPressed = false;
  bool _isOnGround = true;
  bool _dead = false;
  bool hasBeatLevel = false;

  List<Platform> platforms = [];

  Vector2 velocity = Vector2.zero();
  late Vector2 spawnLocation; // playerSpawnLocation

  late final SpriteAnimation appearAnime;
  late final SpriteAnimation idleAnime;
  late final SpriteAnimation runningAnime;
  late final SpriteAnimation jumpAnime;
  late final SpriteAnimation fallAnime;
  late final SpriteAnimation disappearAnime;
  late final SpriteAnimation hitAnime;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox(collisionType: CollisionType.active));
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    //accumulatedTime += dt; // this evens out perform on all diff platforms.
    //while (accumulatedTime >= fixedDeltaTime) {
    if (!_dead && !hasBeatLevel) {
      _updateAnimation();
      _updatePlayerMovement(dt);
      _handleXPlatformCollision();
      _applyGravity(dt);
      _handleYPlatformCollision();
    }
    //accumulatedTime -= fixedDeltaTime;
    //}

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

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpForce, _terminalYVelocity);
    position.y += velocity.y * dt;
  }

  void _jump() {
    FlameAudio.play("jump1.wav", volume: game.volume);
    velocity.y = -_jumpForce;
    _isOnGround = false;
    _jumpPressed = false;
  }

  void _updatePlayerMovement(double dt) {
    if (_jumpPressed && _isOnGround) _jump();
    velocity.x = xDir * _moveSpeed;
    position.x += (velocity.x * dt);
    // position.clamp(_minClamp, _maxClamp);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Fruit) {
      other.collect();
    } else if ((other is Saw) || (other is Fire)) {
      _die();
    } else if (other is Checkpoint) {
      _beatLevel();
      FlameAudio.play("synth1.wav", volume: game.volume);
    } else if (other is Radish) {
      bool radishStomp = (velocity.y > 0 && other.wasJumpedOn(position.y + (height / 2)));
      if (radishStomp) {
        other.die();
        velocity.y = -_jumpForce;
      } else {
        _die();
      }
    } else if (other is Bird) {
      bool birdStomp = (velocity.y > 0 && other.wasJumpedOn(position.y + (height / 2)));
      if (birdStomp) {
        other.die();
        velocity.y = -_jumpForce - 10;
      } else {
        _die();
      }
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    String cacheUrl = "Main Characters/$character/$state (32x32).png";
    double txtSz = 32;
    if (state == "Disappearing" || state == "Appearing") {
      cacheUrl = "Main Characters/$state (96x96).png";
      txtSz = 96;
    }
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(cacheUrl),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(txtSz),
      ),
    );
  }

  void _loadAllAnimations() {
    idleAnime = _spriteAnimation("Idle", 11);
    runningAnime = _spriteAnimation("Run", 12);
    jumpAnime = _spriteAnimation("Jump", 1);
    fallAnime = _spriteAnimation("Fall", 1);
    disappearAnime = _spriteAnimation("Disappearing", 7)..loop = false;
    appearAnime = _spriteAnimation("Appearing", 7)..loop = false;
    hitAnime = _spriteAnimation("Hit", 7)..loop = false;
    animations = {
      PlayerState.idle: idleAnime,
      PlayerState.running: runningAnime,
      PlayerState.jumping: jumpAnime,
      PlayerState.falling: fallAnime,
      PlayerState.appear: appearAnime,
      PlayerState.hit: hitAnime,
      PlayerState.disappear: disappearAnime
    };
    current = PlayerState.idle;
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

  void _die() async {
    _dead = true;
    FlameAudio.play("hitHurt.wav", volume: game.volume);
    current = PlayerState.hit;
    await animationTicker?.completed;
    // animationTicker?.reset();

    // respawn
    scale.x = 1; // face to the right
    position = spawnLocation;
    current = PlayerState.appear;
    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    // _updateAnimation();
    Future.delayed(_dur, () => _dead = false);
  }

  void _beatLevel() async {
    hasBeatLevel = true;
    current = PlayerState.disappear;
    game.currLevel.wallPaper.parallax?.baseVelocity = Vector2(0, -50);
    await animationTicker?.completed;
    animationTicker?.reset();
    xDir = 0;
    velocity = Vector2.zero(); // this doesn't do anything/work.
    removeFromParent();
    hasBeatLevel = false;
    Future.delayed(const Duration(seconds: 3), () {
      game.loadNextLevel();
    });
  }

  void _handleXPlatformCollision() {
    for (Platform other in platforms) {
      Rect platformRect = other.toRect();
      Rect playerRect = toRect();
      if (playerRect.overlaps(platformRect)) {
        if (velocity.x > 0 && !other.isPassable) {
          velocity.x = 0;
          position.x = other.x - (width / 2);
        } else if (velocity.x < 0 && !other.isPassable) {
          velocity.x = 0;
          position.x = (other.x + other.width) + (width / 2);
        }
        break; // think this is ok
      }
    }
  }

  void _handleYPlatformCollision() {
    for (Platform other in platforms) {
      Rect platformRect = other.toRect();
      Rect playerRect = toRect();
      if (playerRect.overlaps(platformRect)) {
        if (velocity.y < 0 && !other.isPassable) {
          velocity.y = 0;
          position.y = other.y + other.height + (height / 2);
        }
        if (velocity.y > 0) {
          if ((other.isPassable && (position.y + (height / 3.0)) < other.y) || !other.isPassable) {
            velocity.y = 0;
            position.y = other.y - (height / 2);
            _isOnGround = true;
          }
        }
        break; // think this is ok
      }
    }
  }
}
