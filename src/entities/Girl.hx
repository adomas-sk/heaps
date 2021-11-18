package entities;

import common.Animation;
import h3d.Vector;
import common.InputManager;
import common.WorldGrid;
import h2d.Anim;
import h2d.Object;

enum abstract GirlAnimations(Int) to Int {
  var IDLE_L;
  var IDLE_R;
  var WALK_L;
  var WALK_R;
  var CONTROL_R;
  var CONTROL_L;
}

class GirlAnimation extends Animation<GirlAnimations> {
  public static var SPRITE_SIZE = 64;

  override public function getAnimations() {
    var girlImage = hxd.Res.girl.character.toTile();

    animations[GirlAnimations.IDLE_R] =    [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, 0              , SPRITE_SIZE)];
    animations[GirlAnimations.IDLE_L] =    [for(x in 0 ... 4) spritePreProcess(girlImage, x * SPRITE_SIZE, SPRITE_SIZE    , SPRITE_SIZE)];
    animations[GirlAnimations.CONTROL_R] = [for(x in 0 ... 3) spritePreProcess(girlImage, x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.CONTROL_L] = [for(x in 0 ... 3) spritePreProcess(girlImage, x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.WALK_R] =    [for(x in 0 ... 8) spritePreProcess(girlImage, x * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE)];
    animations[GirlAnimations.WALK_L] =    [for(x in 0 ... 8) spritePreProcess(girlImage, x * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE)];
  }
}

class Girl extends Object {
  static inline var SPEED = 75;

  var animationLoader: Animation<GirlAnimations>;
  var animation: Anim;
  var direction = {x: 0., y: 0.};
  var velocity = {x: 0., y: 0.};
  var lookingRight = false;
  var controlling = 0;

  public function new(x: Float, y: Float) {
    super(Main.scene);
    this.x = x;
    this.y = y;

    animationLoader = new GirlAnimation(GirlAnimation.SPRITE_SIZE);
    animation = new Anim(animationLoader.animations[GirlAnimations.IDLE_L], 8, this);
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
      animation.play(animationLoader.animations[lookingRight ? GirlAnimations.CONTROL_R : GirlAnimations.CONTROL_L]);
      return;
    }
    if (vel.length() < 1) {
      animation.play(animationLoader.animations[lookingRight ? GirlAnimations.IDLE_R : GirlAnimations.IDLE_L]);
      return;
    }
    var nextAnimations = animationLoader.animations[lookingRight ? GirlAnimations.WALK_R : GirlAnimations.WALK_L];
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