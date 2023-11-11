import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:marvington_game/components/door.dart';
import 'package:marvington_game/game.dart';
import 'package:marvington_game/levels/rock.dart';
import '/actors/player.dart';
import '/enemies/bird.dart';
import '/enemies/radish.dart';
import '/components/wallpaper.dart';
import '/components/checkpoint.dart';
import '/components/fruit.dart';
import '../traps/moon.dart';
import '/levels/platform.dart';
import 'package:flame/experimental.dart';
import '/traps/fire.dart';

Set<String> enemies = {"Bird", "Radish"};
Set<String> traps = {"Moon", "Fire"};

class Level extends World with HasGameRef<Gain> {
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
        } else if (spawnPoint.class_ == "Door") {
          String levelName = spawnPoint.properties.getValue("leadsTo");
          Door d = Door(position: Vector2(spawnPoint.x, spawnPoint.y), size: Vector2(spawnPoint.width, spawnPoint.height), levelName: levelName);
          add(d);
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
    if (spawnPoint.class_ == "Moon") {
      double minusOffset = spawnPoint.properties.getValue("offNegative");
      double plusOffset = spawnPoint.properties.getValue("offPositive");
      bool isVertical = spawnPoint.properties.getValue("isVertical");
      Moon m = Moon(
          isVertical: isVertical,
          minusOffset: minusOffset,
          plusOffset: plusOffset,
          position: Vector2(spawnPoint.x, spawnPoint.y),
          size: Vector2(spawnPoint.width, spawnPoint.height));
      add(m);
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
        bool isLethal = collision.class_ == "Lethal";
        bool isRock = collision.class_ == "Rock";
        if (isRock) {
          Rock rock = Rock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          );
          add(rock);
        }
        Platform platform = Platform(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
            isPassable: isPassable,
            isLethal: isLethal,
            isRock: isRock);
        add(platform);
        player.platforms.add(platform);
      }
    }
  }

  void _setupCam() {
    double horz = game.camWidth / 2;
    double vert = game.camHeight / 2;
    Layer? background = level.tileMap.getLayer("Background");
    if (background != null) {
      double? levelWidth = background.properties.getValue("width");
      double? levelHeight = background.properties.getValue("height");
      if (levelHeight != null && levelWidth != null) {
        Rectangle bounds = Rectangle.fromLTRB(horz, vert, levelWidth - horz, levelHeight - vert);
        game.cam.setBounds(bounds);
      }
      game.cam.follow(player);
    }
  }

  void _addBackground() {
    Layer? background = level.tileMap.getLayer("Background");
    if (background != null) {
      String? bgColor = background.properties.getValue("BackgroundColor");
      wallPaper = WallPaper(color: bgColor ?? "Pink", position: Vector2(0, 0));
      add(wallPaper);
    }
  }
}
