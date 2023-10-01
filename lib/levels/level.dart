import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:gain/actors/player.dart';
import 'package:gain/levels/collision_block.dart';

class Level extends World {
  String levelName;
  Player player;
  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoints'); // rn this is only one item loop unneccessary

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        if (spawnPoint.class_ == "Player") {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          add(player);
        }
      }
    }

    final collisionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        if (collision.class_ == "Platform") {
          final platform = CollisionBlock(position: Vector2(collision.x, collision.y), size: Vector2(collision.width, collision.height), isPlatform: true);
          collisionBlocks.add(platform);
          add(platform);
        } else {
          final block = CollisionBlock(
            position: Vector2(collision.x, collision.y),
            size: Vector2(collision.width, collision.height),
          );
          collisionBlocks.add(block);
          add(block);
        }
      }
      player.collisionBlocks = collisionBlocks;
    }
    return super.onLoad();
  }
}
