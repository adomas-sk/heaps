package entities.buildings;

import common.Animation;
import common.WorldGrid.Position;
import h2d.Anim;
import h2d.Object;


enum abstract DrillAnimations(Int) to Int {
  var WORKING;
}

class DrillAnimation extends Animation<DrillAnimations> {
  public static inline var SPRITE_SIZE = 64;

  override public function getAnimations() {
    var image = hxd.Res.drill.drill.toTile();

    animations[DrillAnimations.WORKING] = [for(x in 0 ... 17) spritePreProcess(image, x * SPRITE_SIZE, 0, SPRITE_SIZE)];
  }
}


class Drill extends Object {
  var animationLoader: Animation<DrillAnimations>;
  var animation: Anim;

  public function new(position: Position) {
    super(Main.scene);

    animationLoader = new DrillAnimation(DrillAnimation.SPRITE_SIZE);
    animation = new Anim(animationLoader.animations[DrillAnimations.WORKING], 8, this);
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