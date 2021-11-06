package entities;

import h2d.Bitmap;
import h3d.Vector;
import common.InputManager;
import common.WorldGrid;
import h2d.Anim;
import h2d.Object;

enum GirlAnimations {
  IDLE_L;
  IDLE_R;
  WALK_L;
  WALK_R;
}

class GirlAnimation {
  public static inline var SPRITE_SIZE = 32;

  public static var animations: haxe.ds.Map<GirlAnimations, Array<h2d.Tile>> = [
    GirlAnimations.IDLE_L => [],
    GirlAnimations.IDLE_R => [],
    GirlAnimations.WALK_L => [],
    GirlAnimations.WALK_R => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var girlImage = hxd.Res.girl.girl.toTile();
    
    var idleL = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 0, SPRITE_SIZE)];
    var walk1L = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE)];
    var walk2L = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE)];
    var walk3L = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE)];
    var idleR = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 0, SPRITE_SIZE, true)];
    var walk1R = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, true)];
    var walk2R = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, true)];
    var walk3R = [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, true)];

    animations[GirlAnimations.IDLE_L] = idleL;
    animations[GirlAnimations.IDLE_R] = idleR;
    animations[GirlAnimations.WALK_L] = walk1L.concat(walk2L).concat(walk3L);
    animations[GirlAnimations.WALK_R] = walk1R.concat(walk2R).concat(walk3R);

    animationsLoaded = true;
  }

  static function spritePreProcess(image: h2d.Tile, x: Int, y: Int, size: Int, ?flipX: Bool) {
    var tile = image.sub(x, y, SPRITE_SIZE, SPRITE_SIZE);
    if (flipX) {
      tile.flipX();
      tile.dx -= SPRITE_SIZE / 2;
    } else {
      tile.dx -= SPRITE_SIZE;
    }
    tile.scaleToSize(SPRITE_SIZE * 2, SPRITE_SIZE * 2);
    tile.dy -= SPRITE_SIZE;
    return tile;
  }
}

class Girl extends Object {
  static inline var SPEED = 150;

  var animation: Anim;
  var direction = {x: 0., y: 0.};
  var velocity = {x: 0., y: 0.};
  var lookingRight = false;

  public function new(x: Float, y: Float) {
    super(Main.scene);
    this.x = x;
    this.y = y;

    GirlAnimation.loadAnimation();
    animation = new Anim(GirlAnimation.animations[GirlAnimations.IDLE_L], 5, this);
    // new Bitmap(h2d.Tile.fromColor(0xff4589, 4, 4, 1), animation);

    registerInput();
  }

  public function update(dt: Float) {
    var nextPos = WorldGrid.getNextPosition({x: x, y: y}, {x: velocity.x * dt, y: velocity.y * dt});
    x = nextPos.x;
    y = nextPos.y;
  }

  function updatesAfterInputChanges() {
    var vel = new Vector(direction.x, direction.y).normalized().multiply(SPEED);
    velocity.x = vel.x;
    velocity.y = vel.y;
    if (vel.length() < 1) {
      animation.play(GirlAnimation.animations[lookingRight ? GirlAnimations.IDLE_R : GirlAnimations.IDLE_L]);
      return;
    }
    if (vel.x < 0 && lookingRight) {
      lookingRight = false;
    } else if (vel.x > 0 && !lookingRight) {
      lookingRight = true;
    }
    animation.play(GirlAnimation.animations[lookingRight ? GirlAnimations.WALK_R : GirlAnimations.WALK_L]);
  }

  function registerInput() {
    InputManager.registerEventHandler("girl-w", InputName.w, (repeat) -> {
      if (!repeat) {
        direction.y -= 1;
        updatesAfterInputChanges();
      }
    });
    InputManager.registerEventHandler("girl-s", InputName.s, (repeat) -> {
      if (!repeat) {
        direction.y += 1;
        updatesAfterInputChanges();
      }
    });
    InputManager.registerEventHandler("girl-a", InputName.a, (repeat) -> {
      if (!repeat) {
        direction.x -= 1;
        updatesAfterInputChanges();
      }
    });
    InputManager.registerEventHandler("girl-d", InputName.d, (repeat) -> {
      if (!repeat) {
        direction.x += 1;
        updatesAfterInputChanges();
      }
    });

    InputManager.registerReleaseEventHandler("girl-w", InputName.w, () -> {
      direction.y += 1;
      updatesAfterInputChanges();
    });
    InputManager.registerReleaseEventHandler("girl-s", InputName.s, () -> {
      direction.y -= 1;
      updatesAfterInputChanges();
    });
    InputManager.registerReleaseEventHandler("girl-a", InputName.a, () -> {
      direction.x += 1;
      updatesAfterInputChanges();
    });
    InputManager.registerReleaseEventHandler("girl-d", InputName.d, () -> {
      direction.x -= 1;
      updatesAfterInputChanges();
    });
  }
}