package entities.buildings;

import h2d.Bitmap;
import helpers.BuildingTypes.BuildFunctionReturn;
import common.WorldGrid;
import Main.LayerIndexes;
import h2d.Object;

class Wall extends Object {
	static inline var SIZE = 32;

	var sprite:Bitmap;

	public function new(position:Position) {
		super(Main.scene);
		Main.layers.add(this, LayerIndexes.ON_GROUND);

		var tile = h2d.Tile.fromColor(0x847574, SIZE, SIZE, 1);
		tile.dx -= SIZE / 2;
		tile.dy -= SIZE / 2;
		sprite = new h2d.Bitmap(tile, this);
		sprite.alpha = 0.5;
		x = position.x;
		y = position.y;

		WorldGrid.addStaticObject(this, {w: SIZE, h: SIZE});
	}

	public static function build(position:Position):BuildFunctionReturn {
		var object = new Wall(position);
		return {
			object: object,
			onBuild: object.onBuild,
		};
	}

	function onBuild() {
		sprite.alpha = 1;
	}
}
