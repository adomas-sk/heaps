package entities;

import common.Entity;
import common.InputManager;
import common.EntityManager;

class Player {
  var animationRotations = [
    50 => "SD",
    75 => "SW",
    100 => "WD",
    -75 => "NW",
    -50 => "ND",
    -25 => "NE",
    0 => "ED",
    25 => "SE",
  ];
  var animations: haxe.ds.Map<String, haxe.ds.Map<String, Array<h2d.Tile>>> = [
    "SD" => [],
    "SW" => [],
    "WD" => [],
    "NW" => [],
    "ND" => [],
    "NE" => [],
    "ED" => [],
    "SE" => [],
  ];
  var camera: h2d.Camera;
  var direction = { x: 0, y: 0 };
  var rotation = 50;
  var wasMoving = false;
  public var entity: Entity;
  public static inline var SPEED = 8.;

  public function new(scene: h2d.Scene) {
    createAnimationTypes();
    var charWalkTileImage = hxd.Res.player.walk.toTile();
    var charIdleTileImage = hxd.Res.player.idle.toTile();

    animations["SD"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 0, 256, 256)];
    animations["SW"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 1 * 256, 256, 256)];
    animations["WD"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 2 * 256, 256, 256)];
    animations["NW"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 3 * 256, 256, 256)];
    animations["ND"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 4 * 256, 256, 256)];
    animations["NE"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 5 * 256, 256, 256)];
    animations["ED"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 6 * 256, 256, 256)];
    animations["SE"]["walk"] = [for(x in 0 ... 30) charWalkTileImage.sub(x * 256, 7 * 256, 256, 256)];

    animations["SD"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 0, 256, 256)];
    animations["SW"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 1 * 256, 256, 256)];
    animations["WD"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 2 * 256, 256, 256)];
    animations["NW"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 3 * 256, 256, 256)];
    animations["ND"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 4 * 256, 256, 256)];
    animations["NE"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 5 * 256, 256, 256)];
    animations["ED"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 6 * 256, 256, 256)];
    animations["SE"]["idle"] = [for(x in 0 ... 30) charIdleTileImage.sub(x * 256, 7 * 256, 256, 256)];

    var anim = new h2d.Anim(animations["SD"]["walk"], 24, scene);
    entity = new Entity(0, 0, anim);
    EntityManager.registerEntity("player", entity);
    entity.sprite = anim;

    var cameraFollow = new h2d.Object(anim);
    cameraFollow.x = 128;
    cameraFollow.y = 128;

    camera = new h2d.Camera(scene);
    camera.follow = cameraFollow;
    camera.anchorX = 0.5;
    camera.anchorY = 0.5;

    entity.addOnUpdate(onUpdate);

    InputManager.registerEventHandler("player-w", InputName.w, (repeat) -> {
      if (!repeat) {
        direction.y -= 1;
        updateRotation();
      }
    });
    InputManager.registerEventHandler("player-s", InputName.s, (repeat) -> {
      if (!repeat) {
        direction.y += 1;
        updateRotation();
      }
    });
    InputManager.registerEventHandler("player-a", InputName.a, (repeat) -> {
      if (!repeat) {
        direction.x -= 1;
        updateRotation();
      }
    });
    InputManager.registerEventHandler("player-d", InputName.d, (repeat) -> {
      if (!repeat) {
        direction.x += 1;
        updateRotation();
      }
    });

    InputManager.registerReleaseEventHandler("player-w", InputName.w, () -> {
      direction.y += 1;
      updateRotation();
    });
    InputManager.registerReleaseEventHandler("player-s", InputName.s, () -> {
      direction.y -= 1;
      updateRotation();
    });
    InputManager.registerReleaseEventHandler("player-a", InputName.a, () -> {
      direction.x += 1;
      updateRotation();
    });
    InputManager.registerReleaseEventHandler("player-d", InputName.d, () -> {
      direction.x -= 1;
      updateRotation();
    });
  }

  function updateRotation() {
    var currentVelocity = new h3d.Vector(direction.x, direction.y);
    var newRotation : haxe.Int32 = hxd.Math.ceil(
      (hxd.Math.atan2(currentVelocity.y, currentVelocity.x) / hxd.Math.PI) * 100
    );
    var isMoving = currentVelocity.length() > 0.1;
    if (!isMoving) {
      entity.sprite.play(animations[animationRotations[rotation]]["idle"]);
      wasMoving = isMoving;
      return;
    }
    if ((rotation != newRotation || wasMoving != isMoving) && currentVelocity.length() > 0.1) {
      entity.sprite.play(animations[animationRotations[newRotation]]["walk"]);
      rotation = newRotation;
    }
  }

  function onUpdate(dt: Float) {
    var currentVelocity = new h3d.Vector(direction.x, direction.y);
    currentVelocity.normalize();
    currentVelocity.scale(SPEED);
    entity.setVelocity(currentVelocity.x, currentVelocity.y);
  }

  function createAnimationType() {
    var animationEvents = [
      "fire" => [],
      "walk" => [],
      "idle" => [],
      "walk-fire" => [],
    ];
    return animationEvents;
  }

  function createAnimationTypes() {
    for(rotation in animations) {
      rotation = createAnimationType();
    }
  }
}
