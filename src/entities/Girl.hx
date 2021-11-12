package entities;

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
  CONTROL_R;
  CONTROL_L;
}

class GirlAnimation {
  public static inline var SPRITE_SIZE = 64;

  public static var animations: haxe.ds.Map<GirlAnimations, Array<h2d.Tile>> = [
    GirlAnimations.IDLE_L => [],
    GirlAnimations.IDLE_R => [],
    GirlAnimations.WALK_L => [],
    GirlAnimations.WALK_R => [],
    GirlAnimations.CONTROL_R => [],
    GirlAnimations.CONTROL_L => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var girlImage = hxd.Res.girl.character.toTile();

    animations[GirlAnimations.CONTROL_L] = [for(x in 0 ... 3) spritePreProcess(girlImage, x * SPRITE_SIZE, 0              , SPRITE_SIZE)];
    animations[GirlAnimations.CONTROL_R] = [for(x in 0 ... 3) spritePreProcess(girlImage, x * SPRITE_SIZE, SPRITE_SIZE    , SPRITE_SIZE)];
    animations[GirlAnimations.IDLE_L] =    [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.IDLE_R] =    [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.WALK_L] =    [for(x in 0 ... 8) spritePreProcess(girlImage, x * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.WALK_R] =    [for(x in 0 ... 8) spritePreProcess(girlImage, x * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE)];

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
  var controlling = 0;

  public function new(x: Float, y: Float) {
    super(Main.scene);
    this.x = x;
    this.y = y;

    GirlAnimation.loadAnimation();
    animation = new Anim(GirlAnimation.animations[GirlAnimations.IDLE_L], 8, this);
    new h2d.Bitmap(h2d.Tile.fromColor(0xff4589, 4, 4, 1), animation);

    registerInput();
  }

  public function update(dt: Float) {
    if (controlling > 0) {
      velocity = {x: 0., y: 0.};
    }
    if (Math.abs(velocity.x) < 0.1 && Math.abs(velocity.y) < 0.1) {
      return;
    }
    var nextPos = WorldGrid.getNextPosition({x: x, y: y}, {x: velocity.x * dt, y: velocity.y * dt});
    x = nextPos.x;
    y = nextPos.y;
  }

  function updatesAfterInputChanges() {
    var vel = new Vector(direction.x, direction.y).normalized().multiply(SPEED);
    velocity.x = vel.x;
    velocity.y = vel.y;
    if (vel.x < 0 && lookingRight) {
      lookingRight = false;
    } else if (vel.x > 0 && !lookingRight) {
      lookingRight = true;
    }
    if (controlling > 0) {
      animation.play(GirlAnimation.animations[lookingRight ? GirlAnimations.CONTROL_R : GirlAnimations.CONTROL_L]);
      return;
    }
    if (vel.length() < 1) {
      animation.play(GirlAnimation.animations[lookingRight ? GirlAnimations.IDLE_R : GirlAnimations.IDLE_L]);
      return;
    }
    var nextAnimations = GirlAnimation.animations[lookingRight ? GirlAnimations.WALK_R : GirlAnimations.WALK_L];
    if (nextAnimations != animation.frames) {
      animation.play(nextAnimations);
    }
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
    InputManager.registerEventHandler("girl-mouseL", InputName.mouseL, (repeat) -> {
      if (!repeat) {
        controlling += 1;
        updatesAfterInputChanges();
      }
    });
    InputManager.registerEventHandler("girl-mouseR", InputName.mouseR, (repeat) -> {
      if (!repeat) {
        controlling += 1;
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
    InputManager.registerReleaseEventHandler("girl-mouseL", InputName.mouseL, () -> {
      controlling -= 1;
      updatesAfterInputChanges();
    });
    InputManager.registerReleaseEventHandler("girl-mouseR", InputName.mouseR, () -> {
      controlling -= 1;
      updatesAfterInputChanges();
    });
  }
}