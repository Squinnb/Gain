// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/src/services/raw_keyboard.dart';
import 'package:marvington_game/actors/bullet.dart';
import 'package:marvington_game/components/door.dart';
import 'package:marvington_game/levels/rock.dart';
import '/enemies/bird.dart';
import '/components/checkpoint.dart';
import '/components/fruit.dart';
import '/enemies/radish.dart';
import '../traps/moon.dart';
import '/game.dart';
import '/levels/platform.dart';
import '/traps/fire.dart';

enum PlayerState { appear, idle, running, jumping, falling, disappear, hit, entering, turnedAway }

class Player extends SpriteAnimationGroupComponent with HasGameRef<Gain>, KeyboardHandler, CollisionCallbacks {
  String character;
  Player({
    super.position,
    super.anchor = Anchor.center,
    this.character = "Marv",
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
  double _moveSpeed = 130;
  double _gravity = 10;
  double _jumpForce = 300;
  double _terminalYVelocity = 200;
  double fixedDeltaTime = 1 / 60;
  double accumulatedTime = 0;

  static const Duration _dur = Duration(milliseconds: 350);

  bool _jumpPressed = false;
  bool _isOnGround = true;
  bool upPressed = false;
  bool _dead = false;
  bool hasBeatLevel = false;
  bool fired = false;

  List<Platform> platforms = [];
  Set<Rock> rocks = {};
  Vector2 velocity = Vector2.zero();
  late Vector2 spawnLocation; // playerSpawnLocation

  @override
  FutureOr<void> onLoad() {
    debugMode = true;
    _loadAllAnimations();
    add(RectangleHitbox(position: Vector2(3, 2), size: Vector2(26, 30), collisionType: CollisionType.active));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    accumulatedTime += dt; // this evens out perform on all diff platforms.
    while (accumulatedTime >= fixedDeltaTime) {
      if (!_dead && !hasBeatLevel) {
        _updateAnimation();
        _updatePlayerMovement(dt);
        _handleXPlatformCollision();
        _applyGravity(dt);
        _handleYPlatformCollision();
      }
      accumulatedTime -= fixedDeltaTime;
    }
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    bool leftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    bool rightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight);
    upPressed = keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowUp);

    fired = keysPressed.contains(LogicalKeyboardKey.keyF);
    if (fired) _shoot();
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
    } else if (other is Moon) {
      _die();
    } else if (other is Platform && other.isLethal) {
      _die();
    } else if (other is Checkpoint) {
      _beatLevel();
      FlameAudio.play("synth3.wav", volume: game.volume);
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

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Fire) {
      if (other.isActive()) _die();
    } else if (other is Door) {
      if (upPressed) _enterDoor(other.levelName);
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount) {
    String cacheUrl = "Marvington/Marv $state.png";
    double txtSz = 32;
    if (state == "Disappearing" || state == "Appearing") {
      cacheUrl = "Marvington/$state (96x96).png";
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
    SpriteAnimation idleAnime = _spriteAnimation("Idle", 6);
    SpriteAnimation runningAnime = _spriteAnimation("Run", 7);
    SpriteAnimation jumpAnime = _spriteAnimation("Jump", 1);
    SpriteAnimation fallAnime = _spriteAnimation("Fall", 1);
    SpriteAnimation turnedAwayAnime = _spriteAnimation("Turned Away", 1);
    SpriteAnimation enterAnime = _spriteAnimation("Enter", 4)..loop = false;
    SpriteAnimation disappearAnime = _spriteAnimation("Disappearing", 7)..loop = false;
    SpriteAnimation appearAnime = _spriteAnimation("Appearing", 7)..loop = false;
    SpriteAnimation hitAnime = _spriteAnimation("Hit", 4)..loop = false;
    animations = {
      PlayerState.idle: idleAnime,
      PlayerState.running: runningAnime,
      PlayerState.jumping: jumpAnime,
      PlayerState.falling: fallAnime,
      PlayerState.entering: enterAnime,
      PlayerState.turnedAway: turnedAwayAnime,
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
    game.currLevel.wallPaper.parallax?.baseVelocity = Vector2(0, -75);
    await animationTicker?.completed;
    xDir = 0;
    velocity = Vector2.zero(); // this doesn't do anything/work.
    hasBeatLevel = false;
    removeFromParent();
    Future.delayed(const Duration(seconds: 2), () {
      game.loadNextLevel();
    });
  }

  void _enterDoor(String levelName) async {
    hasBeatLevel = true;
    current = PlayerState.entering;
    await animationTicker?.completed;
    current = PlayerState.turnedAway;
    hasBeatLevel = false;
    Future.delayed(const Duration(milliseconds: 200), () {
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
          if ((other.isPassable && (position.y + (height / 3)) < other.y) || !other.isPassable) {
            velocity.y = 0;
            position.y = other.y - (height / 2);
            _isOnGround = true;
          }
        }
        break; // think this is ok
      }
    }
  }

  void _shoot() {
    Vector2 standingPosition = Vector2(position.x, (position.y - (height / 3)));
    // Vector2 duckingPosition = Vector2(position.x, (position.y - 2.0));
    Bullet b = Bullet(xdir: scale.x, position: standingPosition);
    parent!.add(b);
  }
}
