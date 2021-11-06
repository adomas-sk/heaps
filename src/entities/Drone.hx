package entities;

import h2d.Bitmap;
import h3d.Vector;
import h2d.Anim;
import h2d.Object;

enum DroneAnimations {
  COMING_OUT;
  COMING_IN;
  WORKING;
}

class DroneAnimation {
  public static inline var SPRITE_SIZE = 16;

  public static var animations: haxe.ds.Map<DroneAnimations, Array<h2d.Tile>> = [
    DroneAnimations.COMING_OUT => [],
    DroneAnimations.COMING_IN => [],
    DroneAnimations.WORKING => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var droneImage = hxd.Res.drone.drone.toTile();
    
    animations[DroneAnimations.COMING_OUT] = [
      spritePreProcess(droneImage, 0, SPRITE_SIZE, SPRITE_SIZE),
      spritePreProcess(droneImage, 2 * SPRITE_SIZE, 0, SPRITE_SIZE),
      spritePreProcess(droneImage, 1 * SPRITE_SIZE, 0, SPRITE_SIZE),
    ];
    animations[DroneAnimations.COMING_IN] = [
      spritePreProcess(droneImage, 1 * SPRITE_SIZE, 0, SPRITE_SIZE),
      spritePreProcess(droneImage, 2 * SPRITE_SIZE, 0, SPRITE_SIZE),
      spritePreProcess(droneImage, 0, SPRITE_SIZE, SPRITE_SIZE),
    ];
    animations[DroneAnimations.WORKING] = [
      spritePreProcess(droneImage, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
      spritePreProcess(droneImage, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE),
    ];

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

enum DroneActions {
  IDLE;
  COMING_OUT;
  DELIVERING;
  COMING_BACK;
  COMING_IN;
}

class Drone extends Object {
  static inline var SPEED = 100;

  var animation: Anim;
  var action: DroneActions;
  // TODO: Make destination a queue
  var destination: Null<Vector>;
  var source: Object;

  var onDelivery = () -> return;

  public function new(source: Object) {
    super(Main.scene);
    this.source = source;
    x = 0;
    y = 0;
    action = DroneActions.IDLE;

    DroneAnimation.loadAnimation();
    animation = new Anim(DroneAnimation.animations[DroneAnimations.COMING_OUT], 5, this);
    // new Bitmap(h2d.Tile.fromColor(0xFF0000, 10, 10, 1), this);
    animation.visible = false;
    animation.pause = true;
    animation.onAnimEnd = () -> {
      switch(action) {
        case DroneActions.COMING_OUT: {
          action = DroneActions.DELIVERING;
          animation.play(DroneAnimation.animations[DroneAnimations.WORKING]);
        }
        case DroneActions.DELIVERING:
        case DroneActions.COMING_BACK:
          return;
        case DroneActions.COMING_IN: {
          action = DroneActions.IDLE;
          animation.play(DroneAnimation.animations[DroneAnimations.COMING_OUT]);
          animation.visible = false;
          animation.pause = true;
        }
        case DroneActions.IDLE:
          throw new haxe.Exception("Drone: animation ended in IDLE");
      }
    };
  }

  public function update(dt: Float) {
    switch(action) {
      case DroneActions.COMING_OUT: {
        x = source.x;
        y = source.y - 32;
      }
      case DroneActions.DELIVERING: {
        var difference = destination.sub(new Vector(x, y));
        if (difference.length() < 5) {
          onDelivery();
          action = DroneActions.COMING_BACK;
          return;
        }
        var velocity = difference.normalized().multiply(SPEED * dt);
        x += velocity.x;
        y += velocity.y;
      }
      case DroneActions.COMING_BACK: {
        var sourceDestination = new Vector(source.x, source.y);
        var difference = sourceDestination.sub(new Vector(x, y));
        if (difference.length() < 5) {
          animation.play(DroneAnimation.animations[DroneAnimations.COMING_IN]);
          action = DroneActions.COMING_IN;
          return;
        }
        var velocity = difference.normalized().multiply(SPEED * dt);
        x += velocity.x;
        y += velocity.y;
      }
      case DroneActions.COMING_IN: {
        x = source.x;
        y = source.y - 32;
      }
      case DroneActions.IDLE:
        return;
    }
  }

  public function orderDelivery(newDestination: Vector, callbackOnDelivery: () -> Void) {
    destination = newDestination;
    onDelivery = callbackOnDelivery;
    if (action == DroneActions.IDLE) {
      action = DroneActions.COMING_OUT;
      x = source.x;
      y = source.y;
      animation.visible = true;
      animation.pause = false;
    }
  }
}