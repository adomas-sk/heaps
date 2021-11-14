package entities.buildings;

import common.WorldGrid.Position;
import h2d.Anim;
import h2d.Object;


enum DrillAnimations {
  WORKING;
}

class DrillAnimation {
  public static inline var SPRITE_SIZE = 64;

  public static var animations: haxe.ds.Map<DrillAnimations, Array<h2d.Tile>> = [
    DrillAnimations.WORKING => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var image = hxd.Res.drill.drill.toTile();

    animations[DrillAnimations.WORKING] = [for(x in 0 ... 17) spritePreProcess(image, x * SPRITE_SIZE, 0, SPRITE_SIZE)];

    animationsLoaded = true;
  }

  static function spritePreProcess(image: h2d.Tile, x: Int, y: Int, size: Int, ?flipX: Bool) {
    var tile = image.sub(x, y, SPRITE_SIZE, SPRITE_SIZE);
    tile.scaleToSize(SPRITE_SIZE * 2, SPRITE_SIZE * 2);
    tile.dy -= SPRITE_SIZE;
    tile.dx -= SPRITE_SIZE;
    return tile;
  }
}


class Drill extends Object {
  var animation: Anim;

  public function new(position: Position) {
    super(Main.scene);

    DrillAnimation.loadAnimation();
    animation = new Anim(DrillAnimation.animations[DrillAnimations.WORKING], 8, this);
    animation.pause = true;
    animation.alpha = 0.5;

    x = position.x;
    y = position.y;
  }

  public function build() {
    animation.alpha = 1;
    animation.pause = false;
  }
}