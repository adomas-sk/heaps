package entities.resources;

import common.WorldGrid;
import h2d.Bitmap;
import common.WorldGrid.Position;
import h2d.Object;

class Tree extends Object {
  public function new(position: Position) {
    super(Main.scene);

    var image = hxd.Res.tree.tree.toTile();
    image.dx -= image.width / 2;
    image.dy -= image.height - 32;
    new Bitmap(image, this);

    x = position.x;
    y = position.y;
    WorldGrid.addStaticObject(this, { w: 32., h: 32. });
  }
}
