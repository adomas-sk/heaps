package entities;

import common.DroneScheduler;
import common.DroneScheduler.DroneOrder;
import h3d.Vector;
import h2d.Anim;
import h2d.Object;

enum DroneAnimations {
  COMING_OUT;
  COMING_IN;
  TRAVEL_EMPTY;
  TRAVEL_CARRY;
}

class DroneAnimation {
  public static inline var SPRITE_SIZE = 32;

  public static var animations: haxe.ds.Map<DroneAnimations, Array<h2d.Tile>> = [
    DroneAnimations.COMING_OUT => [],
    DroneAnimations.COMING_IN => [],
    DroneAnimations.TRAVEL_EMPTY => [],
    DroneAnimations.TRAVEL_CARRY => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var droneImage = hxd.Res.drone.drone.toTile();
    
    animations[DroneAnimations.COMING_IN] =    [for(x in 0 ... 5) spritePreProcess(droneImage, x * SPRITE_SIZE      , 0               , SPRITE_SIZE)];
    animations[DroneAnimations.COMING_OUT] =   [for(x in 0 ... 5) spritePreProcess(droneImage, (5 - x) * SPRITE_SIZE, 0               , SPRITE_SIZE)];
    animations[DroneAnimations.TRAVEL_CARRY] = [for(x in 0 ... 4) spritePreProcess(droneImage, x * SPRITE_SIZE      , SPRITE_SIZE     , SPRITE_SIZE)];
    animations[DroneAnimations.TRAVEL_EMPTY] = [for(x in 0 ... 4) spritePreProcess(droneImage, x * SPRITE_SIZE      , 2 * SPRITE_SIZE , SPRITE_SIZE)];

    animationsLoaded = true;
  }

  static function spritePreProcess(image: h2d.Tile, x: Int, y: Int, size: Int, ?flipX: Bool) {
    var tile = image.sub(x, y, SPRITE_SIZE, SPRITE_SIZE);
    // tile.scaleToSize(SPRITE_SIZE * 2, SPRITE_SIZE * 2);
    tile.dy -= SPRITE_SIZE / 2;
    tile.dx -= SPRITE_SIZE / 2;
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
  static inline var Y_OFFSET_FROM_SOURCE = 32;

  var animation: Anim;
  var action: DroneActions;
  
  var currentOrder: Null<DroneOrder>;
  var source: Object;

  public function new(source: Object) {
    super(Main.scene);
    this.source = source;
    x = 0;
    y = 0;
    action = DroneActions.IDLE;

    DroneAnimation.loadAnimation();
    animation = new Anim(DroneAnimation.animations[DroneAnimations.COMING_OUT], 10, this);
    // new h2d.Bitmap(h2d.Tile.fromColor(0xFF0000, 10, 10, 1), this);
    animation.visible = false;
    animation.pause = true;
    animation.onAnimEnd = () -> {
      switch(action) {
        case DroneActions.COMING_OUT: {
          action = DroneActions.DELIVERING;
          animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_CARRY]);
        }
        case DroneActions.DELIVERING:
        case DroneActions.COMING_BACK:
          return;
        case DroneActions.COMING_IN: {
          currentOrder = null;
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
        y = source.y - Y_OFFSET_FROM_SOURCE;
      }
      case DroneActions.DELIVERING: {
        deliver(dt);
      }
      case DroneActions.COMING_BACK: {
        comeBack(dt);
      }
      case DroneActions.COMING_IN: {
        x = source.x;
        y = source.y - Y_OFFSET_FROM_SOURCE;
      }
      case DroneActions.IDLE:
        return;
    }
  }
  
  public function order(order: DroneOrder) {
    currentOrder = order;
    if (action == DroneActions.COMING_IN) {
      animation.play(DroneAnimation.animations[DroneAnimations.COMING_OUT]);
    }
    action = DroneActions.COMING_OUT;
    animation.visible = true;
    animation.pause = false;
  }

  function deliver(dt: Float) {
    var difference = currentOrder.location.sub(new Vector(x, y));
    if (difference.length() < 5) {
      currentOrder.callBack();
      animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_EMPTY]);
      action = DroneActions.COMING_BACK;
      return;
    }
    var velocity = difference.normalized().multiply(SPEED * dt);
    x += velocity.x;
    y += velocity.y;
  }

  function comeBack(dt: Float) {
    var sourceDestination = new Vector(source.x, source.y - Y_OFFSET_FROM_SOURCE);
    var difference = sourceDestination.sub(new Vector(x, y));
    if (difference.length() < 5) {
      var anotherOrderAdded = DroneScheduler.announceAboutOrderCompletion(this);
      if (anotherOrderAdded) {
        action = DroneActions.DELIVERING;
        animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_CARRY]);
        return;
      }
      animation.play(DroneAnimation.animations[DroneAnimations.COMING_IN]);
      action = DroneActions.COMING_IN;
      return;
    }
    var velocity = difference.normalized().multiply(SPEED * dt);
    x += velocity.x;
    y += velocity.y;
  }
}