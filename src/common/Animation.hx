package common;

typedef PreProcessOptions = {
	?flipX:Bool
}

abstract class Animation<Animations:Int> {
	var ANIMATION_SPRITE_SIZE = 128;

	public var animations:haxe.ds.Map<Animations, Array<h2d.Tile>> = [];

	var animationsLoaded = false;

	public function new(spriteSize:Int) {
		ANIMATION_SPRITE_SIZE = spriteSize;
		if (animationsLoaded) {
			return;
		}
		getAnimations();
		animationsLoaded = true;
	}

	public function getAnimations() {}

	function spritePreProcess(image:h2d.Tile, x:Int, y:Int, size:Int, ?options:PreProcessOptions) {
		var tile = image.sub(x, y, ANIMATION_SPRITE_SIZE, ANIMATION_SPRITE_SIZE);
		if (options != null && options.flipX) {
			tile.flipX();
			tile.dx -= ANIMATION_SPRITE_SIZE / 4;
		} else {
			tile.dx -= ANIMATION_SPRITE_SIZE / 2;
		}
		tile.dy -= ANIMATION_SPRITE_SIZE / 2;
		return tile;
	}
}
