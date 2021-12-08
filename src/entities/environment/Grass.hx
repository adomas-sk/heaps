package entities.environment;

import h3d.Vector;
import h2d.Bitmap;
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
	// var SE;
	// var SO;
	// var SW;
	var WE;
}

class GrassAnimation extends Animation<GrassAnimations> {
	public static inline var SPRITE_SIZE = 48;

	override public function getAnimations() {
		var image = hxd.Res.grass.grass.toTile();
		animations[GrassAnimations.NW] = [spritePreProcess(image, 0 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[GrassAnimations.NO] = [spritePreProcess(image, 2 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[GrassAnimations.NE] = [spritePreProcess(image, 3 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[GrassAnimations.EA] = [spritePreProcess(image, 4 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		// animations[GrassAnimations.SE] = [spritePreProcess(image, 4 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		// animations[GrassAnimations.SO] = [spritePreProcess(image, 5 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		// animations[GrassAnimations.SW] = [spritePreProcess(image, 6 * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[GrassAnimations.WE] = [spritePreProcess(image, 1 * SPRITE_SIZE, 0, SPRITE_SIZE)];
	}
}

class Grass extends Object {
	static var spriteBatch:SpriteBatch;

	var passed = 0.;
	var frame = 0;
	var frames: Array<Float> = [];

	public function new() {
		super(Main.scene);
		// Main.layers.add(this, LayerIndexes.ON_GROUND);

		var tileA = hxd.Res.grass.grass_bladeA.toTile();
		tileA.dx -= tileA.width / 2;
		tileA.dy -= tileA.height;
		var tileB = hxd.Res.grass.grass_bladeB.toTile();
		tileB.dx -= tileB.width / 2;
		tileB.dy -= tileB.height;
		var tileC = hxd.Res.grass.grass_bladeC.toTile();
		tileC.dx -= tileC.width / 2;
		tileC.dy -= tileC.height;

		var tiles = [tileA, tileB, tileC];

		spriteBatch = new SpriteBatch(tileA, this);
		spriteBatch.hasRotationScale = true;
		for (y in 0...100)
			for (x in 0...100) {
					// Math.floor(Math.random() * 3);
					var batchElement = new BatchElement(tiles[Math.floor(Math.random() * 3)]);
					batchElement.x = x * 10 - 50 * 10 + (Math.round(Math.random() * 20) - 10);
					batchElement.y = y * 10 - 50 * 10 + (Math.round(Math.random() * 20) - 10);
					spriteBatch.add(batchElement);
		}

		var frameCount = 50;
		for(i in 0 ... frameCount + 1) {
			frames.push(i / frameCount);
		}
		var bbb = frames.length - 1;
		for(i in 1 ... bbb) {
			frames.push(frames[bbb - i]);
		}
		for(i in 0 ... frames.length) {
			frames[i] = frames[i] * (Math.PI - (Math.PI / 3)) + Math.PI / 6;
		}
	}

	public function update(dt: Float) {
		passed += dt;

		if (passed > 0.1) {
			frame += 1;
			passed = 0;
		}
		var girlPosition = Main.girl.getPosition();
		var rotation = frame % frames.length;
		for(i in spriteBatch.getElements()) {
			var position = new Vector(i.x, i.y);
			var distance = position.distance(girlPosition);
			var stepDistance = 32;
			if (distance < stepDistance) {
				var right = girlPosition.x < i.x;
				if (right) {
					var rotation = ((Math.PI / 2) * (1 - distance / stepDistance));
					i.rotation = rotation;
				} else {
					var rotation = (Math.PI / 2) * (distance / stepDistance) - Math.PI / 2;
					i.rotation = rotation;
				}
			} else {
				var a = Math.abs(rotation + Math.floor(i.x / 10));
				var b = Math.floor(a % frames.length);
				i.rotation = frames[b] - Math.PI / 2;
			}
		}
	}
}
