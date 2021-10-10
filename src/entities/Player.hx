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
  var animations = [
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
  public var entity: Entity;
  public static inline var SPEED = 8.;

  public function new(scene: h2d.Scene) {
    var charWalkTileImage = hxd.Res.char_walk.char_walk.toTile();

    animations["SD"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 0, 200, 200)];
    animations["SW"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 1 * 200, 200, 200)];
    animations["WD"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 2 * 200, 200, 200)];
    animations["NW"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 3 * 200, 200, 200)];
    animations["ND"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 4 * 200, 200, 200)];
    animations["NE"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 5 * 200, 200, 200)];
    animations["ED"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 6 * 200, 200, 200)];
    animations["SE"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * 200, 7 * 200, 200, 200)];

    var anim = new h2d.Anim(animations["SD"], 24, scene);
    entity = new Entity(0, 0, anim);
    EntityManager.registerEntity("player", entity);
    entity.sprite = anim;

    var cameraFollow = new h2d.Object(anim);
    cameraFollow.x = 100;
    cameraFollow.y = 100;

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
    var newRotation : haxe.Int32 = hxd.Math.ceil((hxd.Math.atan2(currentVelocity.y, currentVelocity.x) / hxd.Math.PI) * 100);
    if (rotation != newRotation && currentVelocity.length() > 0.1) {
      entity.sprite.play(animations[animationRotations[newRotation]]);
      rotation = newRotation;
    }
  }

  function onUpdate(dt: Float) {
    var currentVelocity = new h3d.Vector(direction.x, direction.y);
    currentVelocity.normalize();
    currentVelocity.scale(SPEED);
    entity.setVelocity(currentVelocity.x, currentVelocity.y);
  }
}
