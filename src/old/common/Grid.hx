package old.common;

class Grid {
  public static var walls: haxe.ds.Map<String, h2d.Bitmap> = [];

  public static function addObsticle(x: Int, y: Int, initScene: h2d.Scene) {
    var tile = h2d.Tile.fromColor(0xFFFF00, Entity.CELL_SIZE, Entity.CELL_SIZE, 1);
    var bmp = new h2d.Bitmap(tile, initScene);
    bmp.x = x * Entity.CELL_SIZE;
    bmp.y = y * Entity.CELL_SIZE;
    walls[x + "-" + y] = bmp;
  }

  public static function isWallAt(x: Int, y: Int) {
    return walls.exists(x + "-" + y);
  }
}
