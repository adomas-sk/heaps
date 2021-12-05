package entities.resources;

import common.Killables;
import common.Killables.KillablesTag;
import shared.Health;
import h3d.Vector;
import common.Killables.IKillable;
import hxd.Res;
import helpers.BuildingTypes.BuildFunctionReturn;
import Main.LayerIndexes;
import common.WorldGrid;
import h2d.Bitmap;
import common.WorldGrid.Position;
import h2d.Object;

class Tree extends Object implements IKillable {
	static inline var SIZE = 128;
	static inline var MAX_HEALTH = 100;

	var shadow:Bitmap;
	var trunk:Bitmap;
	var leafs:Bitmap;

	public var health = 100;

	var healthBar:Health;

	public function new(position:Position) {
		super(Main.scene);
		Main.layers.add(this, LayerIndexes.ON_GROUND);

		healthBar = new Health(this, {x: 16, y: Std.int(-(SIZE - SIZE / 4) + 8)});

		var image = Res.tree.tree4.toTile();
		var shadowTile = image.sub(0, 0, SIZE, SIZE);
		var trunkTile = image.sub(SIZE, 0, SIZE, SIZE);
		var leafsTile = image.sub(2 * SIZE, 0, SIZE, SIZE);
		var tiles = [shadowTile, trunkTile, leafsTile];
		for (tile in tiles) {
			tile.dx -= SIZE / 2;
			tile.dy -= SIZE - SIZE / 4;
		}
		shadow = new Bitmap(shadowTile, this);
		trunk = new Bitmap(trunkTile, this);
		leafs = new Bitmap(leafsTile, this);

		x = position.x;
		y = position.y;
		WorldGrid.addStaticObject(this, {w: 32., h: 32.});
		Killables.registerKillable(this, KillablesTag.RESOURCE);
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

	public function getPosition():Vector {
		return new Vector(x, y);
	}

	public function onDamage(damage:Int) {
		health -= damage;
		healthBar.setHealth(health - MAX_HEALTH);
		if (health <= 0) {
			Killables.announceDead(this);
			this.remove();
		}
	}

	public function update(dt:Float) {}
}
