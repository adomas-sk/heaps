package common;

import haxe.ds.Map;
import h2d.TileGroup;

enum GroundTiles {
	GRASS1;
	GRASS2;
	GRASS3;
	ROADL;
	ROADLB;
	ROAD;
}

var groundTiles = [GRASS1, GRASS2, GRASS3, ROADL, ROADLB, ROAD,];

class GroundRenderer {
	static var SPRITE_SIZE = 16;
	static var texturesLoaded = false;

	static var tilePositions:Map<GroundTiles, Array<{x:Float, y:Float}>> = [for (i in groundTiles) i => []];
	static var tiles:Map<GroundTiles, h2d.Tile> = [];
	static var tileGroups:Map<GroundTiles, TileGroup> = [];

	public static function renderGround() {
		loadTextures();

		for (i in groundTiles) {
			tileGroups[i] = new TileGroup(tiles[i], Main.scene);
		}
	}

	static function loadTextures() {
		if (texturesLoaded) {
			return;
		}

		var groundImage = hxd.Res.ground.ground.toTile();
		tiles[GroundTiles.GRASS1] = spritePreProcess(groundImage, 0, 0, SPRITE_SIZE);
		tiles[GroundTiles.GRASS2] = spritePreProcess(groundImage, SPRITE_SIZE, 0, SPRITE_SIZE);
		tiles[GroundTiles.GRASS3] = spritePreProcess(groundImage, 2 * SPRITE_SIZE, 0, SPRITE_SIZE);
		tiles[GroundTiles.ROADL] = spritePreProcess(groundImage, 3 * SPRITE_SIZE, 0, SPRITE_SIZE);
		tiles[GroundTiles.ROADLB] = spritePreProcess(groundImage, 4 * SPRITE_SIZE, 0, SPRITE_SIZE);
		tiles[GroundTiles.ROAD] = spritePreProcess(groundImage, 5 * SPRITE_SIZE, 0, SPRITE_SIZE);

		texturesLoaded = true;
	}

	public static function addTile(x:Float, y:Float, tile:GroundTiles) {
		tilePositions[tile].push({x: x, y: y});
		tileGroups[tile].clear();

		for (i in tilePositions[tile])
			tileGroups[tile].add(i.x, i.y, tiles[tile]);

		for (groundTile in groundTiles) {
			if (groundTile != tile) {
				for (position in tilePositions[groundTile]) {
					if (position.x == x && position.y == y) {
						tilePositions[groundTile].remove(position);
					}
				}
			}
		}
	}

	static function spritePreProcess(image:h2d.Tile, x:Int, y:Int, size:Int) {
		var tile = image.sub(x, y, SPRITE_SIZE, SPRITE_SIZE);
		tile.scaleToSize(SPRITE_SIZE * 2, SPRITE_SIZE * 2);
		return tile;
	}
}
