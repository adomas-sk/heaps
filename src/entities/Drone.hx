package entities;

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

enum DroneBehaviours {
  IDLE;
  COMING_OUT;
  DELIVERING;
  COMING_BACK;
  COMING_IN;
}

enum DroneActionTypes {
  DELIVER;
}
typedef DroneAction = {
  var location: Vector;
  var type: DroneActionTypes;
  var ?callBack: () -> Void;
}

class Drone extends Object {
  static inline var SPEED = 100;

  var animation: Anim;
  var action: DroneBehaviours;
  // TODO: Make destination a queue
  var workQueue: Array<DroneAction> = [];
  var currentJob: Null<DroneAction>;
  var source: Object;

  public function new(source: Object) {
    super(Main.scene);
    this.source = source;
    x = 0;
    y = 0;
    action = DroneBehaviours.IDLE;

    DroneAnimation.loadAnimation();
    animation = new Anim(DroneAnimation.animations[DroneAnimations.COMING_OUT], 10, this);
    // new h2d.Bitmap(h2d.Tile.fromColor(0xFF0000, 10, 10, 1), this);
    animation.visible = false;
    animation.pause = true;
    animation.onAnimEnd = () -> {
      switch(action) {
        case DroneBehaviours.COMING_OUT: {
          action = DroneBehaviours.DELIVERING;
          animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_CARRY]);
        }
        case DroneBehaviours.DELIVERING:
        case DroneBehaviours.COMING_BACK:
          return;
        case DroneBehaviours.COMING_IN: {
          currentJob = null;
          action = DroneBehaviours.IDLE;
          animation.play(DroneAnimation.animations[DroneAnimations.COMING_OUT]);
          animation.visible = false;
          animation.pause = true;
        }
        case DroneBehaviours.IDLE:
          throw new haxe.Exception("Drone: animation ended in IDLE");
      }
    };
  }

  // TODO: Fix this mess. Create separate functions for getting to different actions
  public function update(dt: Float) {
    switch(action) {
      case DroneBehaviours.COMING_OUT: {
        x = source.x;
        y = source.y - 64;
      }
      case DroneBehaviours.DELIVERING: {
        var difference = currentJob.location.sub(new Vector(x, y));
        if (difference.length() < 5) {
          currentJob.callBack();
          animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_EMPTY]);
          action = DroneBehaviours.COMING_BACK;
          return;
        }
        var velocity = difference.normalized().multiply(SPEED * dt);
        x += velocity.x;
        y += velocity.y;
      }
      case DroneBehaviours.COMING_BACK: {
        var sourceDestination = new Vector(source.x, source.y - 64);
        var difference = sourceDestination.sub(new Vector(x, y));
        if (difference.length() < 5) {
          if (workQueue.length > 0) {
            currentJob = workQueue.pop();
            action = DroneBehaviours.DELIVERING;
            animation.play(DroneAnimation.animations[DroneAnimations.TRAVEL_CARRY]);
            return;
          }
          animation.play(DroneAnimation.animations[DroneAnimations.COMING_IN]);
          action = DroneBehaviours.COMING_IN;
          return;
        }
        var velocity = difference.normalized().multiply(SPEED * dt);
        x += velocity.x;
        y += velocity.y;
      }
      case DroneBehaviours.COMING_IN: {
        x = source.x;
        y = source.y - 64;
        if (workQueue.length > 0) {
          action = DroneBehaviours.COMING_OUT;
          animation.play(DroneAnimation.animations[DroneAnimations.COMING_OUT]);
          currentJob = workQueue.pop();
        }
      }
      case DroneBehaviours.IDLE:
        return;
    }
  }

  public function orderDelivery(newDestination: Vector, callbackOnDelivery: () -> Void) {
    var newAction: DroneAction = {
      location: newDestination,
      type: DroneActionTypes.DELIVER,
      callBack: callbackOnDelivery,
    };
    workQueue.unshift(newAction);

    if (currentJob == null) {
      currentJob = workQueue.pop();
      action = DroneBehaviours.COMING_OUT;
      animation.visible = true;
      animation.pause = false;
    }
  }
}