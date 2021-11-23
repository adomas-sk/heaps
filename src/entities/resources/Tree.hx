package entities.resources;

import helpers.BuildingTypes.BuildFunctionReturn;
import Main.LayerIndexes;
import common.WorldGrid;
import h2d.Bitmap;
import common.WorldGrid.Position;
import h2d.Object;

class Tree extends Object {
	public function new(position:Position) {
		super(Main.scene);
		Main.layers.add(this, LayerIndexes.ON_GROUND);

		var image = hxd.Res.tree.tree.toTile();
		image.dx -= image.width / 2;
		image.dy -= image.height - 32;
		new Bitmap(image, this);

		x = position.x;
		y = position.y;
		WorldGrid.addStaticObject(this, {w: 32., h: 32.});
	}

	public static function build(position:Position):BuildFunctionReturn {
		var object = new Tree(position);
		object.alpha = 0.5;
		return {
			object: object,
			onBuild: () -> {
				object.alpha = 1;
			},
		};
	}
}
