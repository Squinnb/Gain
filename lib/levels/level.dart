import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/enemies/bird.dart';
import 'package:gain/enemies/radish.dart';
import 'package:gain/components/wallpaper.dart';
import 'package:gain/components/checkpoint.dart';
import 'package:gain/components/fruit.dart';
import 'package:gain/traps/saw.dart';
import 'package:gain/levels/platform.dart';
import 'package:flame/experimental.dart';
import 'package:gain/traps/fire.dart';

Set<String> enemies = {"Bird", "Radish"};
Set<String> traps = {"Saw", "Fire"};

class Level extends World with HasGameRef {
  String levelName;
  Player player;
  Level({required this.levelName, required this.player});
  late TiledComponent level;

  late double boundsWidth;
  late double boundsHeight;
  late WallPaper wallPaper;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    _spawnAll();
    _createPlatforms();
    _setupCam();
    _addBackground();
    add(level);
    return super.onLoad();
  }

  void _spawnAll() {
    ObjectGroup? spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if (spawnPointLayer != null) {
      for (TiledObject spawnPoint in spawnPointLayer.objects) {
        if (spawnPoint.class_ == "Player") {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.spawnLocation = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
        } else if (spawnPoint.class_ == "Fruit") {
          Fruit f = Fruit(fruitType: spawnPoint.name, position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
          add(f);
        } else if (traps.contains(spawnPoint.class_)) {
          _spawnTraps(spawnPoint);
        } else if (enemies.contains(spawnPoint.class_)) {
          _spawnEnemies(spawnPoint);
        } else if (spawnPoint.class_ == "Checkpoint") {
          Checkpoint checkp = Checkpoint(position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
          add(checkp);
        }
      }
    }
  }

  void _spawnEnemies(TiledObject spawnPoint) {
    if (spawnPoint.class_ == "Radish") {
      double minusOffset = spawnPoint.properties.getValue("offNegative");
      double plusOffset = spawnPoint.properties.getValue("offPositive");
      Radish r = Radish(
          minusOffset: minusOffset, plusOffset: plusOffset, position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
      add(r);
    } else if (spawnPoint.class_ == "Bird") {
      double minusOffset = spawnPoint.properties.getValue("offNegative");
      double plusOffset = spawnPoint.properties.getValue("offPositive");
      Bird b = Bird(
          minusOffset: minusOffset, plusOffset: plusOffset, position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
      add(b);
    }
  }

  void _spawnTraps(TiledObject spawnPoint) {
    if (spawnPoint.class_ == "Saw") {
      double minusOffset = spawnPoint.properties.getValue("offNegative");
      double plusOffset = spawnPoint.properties.getValue("offPositive");
      bool isVertical = spawnPoint.properties.getValue("isVertical");
      Saw s = Saw(
          isVertical: isVertical,
          minusOffset: minusOffset,
          plusOffset: plusOffset,
          position: Vector2(spawnPoint.x, spawnPoint.y),
          size: Vector2(spawnPoint.width, spawnPoint.height));
      add(s);
    } else if (spawnPoint.class_ == "Fire") {
      Fire spike = Fire(position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height));
      add(spike);
    }
  }

  void _createPlatforms() {
    player.platforms.clear();
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        bool isPassable = collision.class_ == "Passable";
        Platform platform = Platform(position: Vector2(collision.x, collision.y), size: Vector2(collision.width, collision.height), isPassable: isPassable);
        add(platform);
        player.platforms.add(platform);
      }
    }
  }

  void _setupCam() {
    boundsWidth = (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble();
    boundsHeight = (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble();
    print("width: $boundsWidth, height: $boundsHeight");
    Rect rect = Rect.fromLTWH(0, 0, boundsWidth, boundsHeight);
    gameRef.camera.setBounds(Rectangle.fromRect(rect));
  }

  void _addBackground() {
    Layer? background = level.tileMap.getLayer("Background");
    if (background != null) {
      String? bgColor = background.properties.getValue("BackgroundColor");
      wallPaper = WallPaper(color: 'Brown', position: Vector2(0, 0));
      add(wallPaper);
    }
  }
}
