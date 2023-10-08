import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/levels/platform.dart';

class Level extends World with HasGameRef {
  String levelName;
  Level({required this.levelName});

  late Player player;
  late TiledComponent level;
  late Rect levelBounds;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    levelBounds = Rect.fromLTWH(
        0, 0, (level.tileMap.map.width * level.tileMap.map.tileWidth).toDouble(), (level.tileMap.map.height * level.tileMap.map.tileHeight).toDouble());
    Player player = Player(levelBounds: levelBounds);
    _spawnActors();
    game.camera.follow(player);
    _createPlatforms();
    add(level);
    return super.onLoad();
  }

  void _spawnActors() {
    ObjectGroup? spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints');
    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        if (spawnPoint.class_ == "Player") {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
        }
      }
    }
  }

  void _createPlatforms() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        if (collision.class_ == "Platform") {
          // need to change class name
          final platform = Platform(position: Vector2(collision.x, collision.y), size: Vector2(collision.width, collision.height), isPassable: true);
          add(platform);
        } else {
          final block = Platform(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          );
          add(block);
        }
      }
    }
  }
}
