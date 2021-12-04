package shared;

import h2d.Object;

class Health extends Object {
	public var healthBar: h2d.Bitmap;

	public function new(owner: Object, offset: {x: Int, y: Int}) {
		super(owner);
		healthBar = new h2d.Bitmap(h2d.Tile.fromColor(0xdd4565, 32, 4), owner);
		healthBar.y += offset.y;
		healthBar.x -= offset.x;
		healthBar.height = 4;
		healthBar.width = 32;
	}

	public function setHealth(percent: Float) {
		healthBar.width = 32 * percent;
	}
}
