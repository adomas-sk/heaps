package entities.environment;

import h2d.Tile;
import Main.LayerIndexes;
import h2d.SpriteBatch;
import helpers.Animation;
import h2d.Object;

enum abstract GrassAnimations(Int) to Int {
	var NW;
	var NO;
	var NE;
	var EA;
	var SE;
	var SO;
	var SW;
	var WE;
}

class GrassAnimation extends Animation<GrassAnimations> {
	public static inline var SPRITE_SIZE = 32;

	override public function getAnimations() {
		var image = hxd.Res.grass.grass.toTile();
		animations[GrassAnimations.NW] = [spritePreProcess(image, 0, 0 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.NO] = [spritePreProcess(image, 0, 1 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.NE] = [spritePreProcess(image, 0, 2 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.EA] = [spritePreProcess(image, 0, 3 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.SE] = [spritePreProcess(image, 0, 4 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.SO] = [spritePreProcess(image, 0, 5 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.SW] = [spritePreProcess(image, 0, 6 * SPRITE_SIZE, SPRITE_SIZE)];
		animations[GrassAnimations.WE] = [spritePreProcess(image, 0, 7 * SPRITE_SIZE, SPRITE_SIZE)];
	}
}

// WIP
class Grass extends Object {
	var animationLoader:Animation<GrassAnimations>;
	static var spriteBatch:SpriteBatch;

	var passed = 0.;

	public function new() {
		super(Main.scene);
		// x -= 16 * 100;
		// y -= 16 * 100;
		animationLoader = new GrassAnimation(GrassAnimation.SPRITE_SIZE);
		Main.layers.add(this, LayerIndexes.ON_GROUND);

		spriteBatch = new SpriteBatch(animationLoader.animations[GrassAnimations.WE][0], this);
		var thing = (x: Int, y:Int, xoff:Int, yoff:Int, tile: Tile) -> {
			var batchElement = new BatchElement(tile);
			batchElement.x = x * 32 + xoff;
			batchElement.y = y * 32 + yoff;
			return batchElement;
		};
		for (y in 0...10)
			for (x in 0...10) {
					spriteBatch.add(thing(x,y,-10,-10, animationLoader.animations[GrassAnimations.WE][0]));
					spriteBatch.add(thing(x,y,0,0, animationLoader.animations[GrassAnimations.WE][0]));
					spriteBatch.add(thing(x,y,10,6, animationLoader.animations[GrassAnimations.WE][0]));
					spriteBatch.add(thing(x,y,-11,13, animationLoader.animations[GrassAnimations.WE][0]));
		}
	}

	public function update(dt: Float) {
		passed += dt;
		
		var map = [
			0 => [
				animationLoader.animations[GrassAnimations.WE][0],
				animationLoader.animations[GrassAnimations.NW][0],
				animationLoader.animations[GrassAnimations.NO][0],
				animationLoader.animations[GrassAnimations.NE][0],
			],
			1 => [
				animationLoader.animations[GrassAnimations.NE][0],
				animationLoader.animations[GrassAnimations.WE][0],
				animationLoader.animations[GrassAnimations.NW][0],
				animationLoader.animations[GrassAnimations.NO][0],
			],
			2 => [
				animationLoader.animations[GrassAnimations.NO][0],
				animationLoader.animations[GrassAnimations.NE][0],
				animationLoader.animations[GrassAnimations.WE][0],
				animationLoader.animations[GrassAnimations.NW][0],
			],
			3 => [
				animationLoader.animations[GrassAnimations.NW][0],
				animationLoader.animations[GrassAnimations.NO][0],
				animationLoader.animations[GrassAnimations.NE][0],
				animationLoader.animations[GrassAnimations.WE][0],
			],
		];

		for (el in spriteBatch.getElements()) {
			var rotation = ((Math.sin((el.x / 50) + passed) + 1) / 2);
			var rot = 0;
			if (rotation < 0.25) {
				rot = 0;
			} else if (rotation < 0.5) {
				rot = 1;
			} else if (rotation < 0.75) {
				rot = 2;
			} else {
				rot = 3;
			}
			var position = Math.floor(el.x/32) % 4;
			if (map.exists(rot) && map[rot][position] != null) {
				el.t = map[rot][position];
			}
		}
	}
}
