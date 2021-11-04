package old.entities;

import old.common.Entity;
import old.common.InputManager;

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
  var scene: h2d.Scene;
  var camera: h2d.Camera;
  var direction = { x: 0, y: 0 };
  var rotation = 50;
  var wasMoving = false;
  var shooting = false;
  var animation: h2d.Anim;

  public var entity: Entity;
  public static inline var SPEED = 8.;
  public static inline var SPRITE_SIZE = 128;

  public function new(initScene: h2d.Scene) {
    scene = initScene;
    loadAnimations();

    animation = new h2d.Anim(animations["SD"]["walk"], 12, scene);
    animation.onAnimEnd = () -> {
      if (shooting) {
        new Bullet(entity.cellX, entity.cellY, InputManager.mousePosition.x, InputManager.mousePosition.y, scene);
      }
    };
    entity = new Entity("player", 0, 0, animation);
    entity.spriteOffset = {x: Std.int(-(SPRITE_SIZE / 2)), y: Std.int(-(SPRITE_SIZE * 0.75))};
    entity.sprite = animation;

    var cameraFollow = new h2d.Object(animation);
    cameraFollow.x = SPRITE_SIZE / 2;
    cameraFollow.y = SPRITE_SIZE / 2;
    camera = new h2d.Camera(scene);
    camera.follow = cameraFollow;
    camera.anchorX = 0.5;
    camera.anchorY = 0.5;

    registerInput();

    entity.addOnUpdate(createDebugUpdate());
  }

  function updateRotation() {
    if (shooting) {
      var directionToMouse =
        new h3d.Vector(InputManager.mousePosition.x, InputManager.mousePosition.y).sub(
          new h3d.Vector(scene.width / 2, scene.height / 2)
        );
      var newRotation : haxe.Int32 = hxd.Math.ceil(
        (hxd.Math.atan2(directionToMouse.y, directionToMouse.x) / hxd.Math.PI) * 100
      );
      var closestRotation = [
        50,
        75,
        100,
        -75,
        -50,
        -25,
        0,
        25
      ];
      var closest = 50;
      var currentClosest = 200;
      for (i in closestRotation) {
        if (Math.abs((newRotation + 100) - (i + 100)) < currentClosest) {
          closest = i;
          currentClosest = Std.int(Math.abs((newRotation + 100) - (i + 100)));
        }
      }
      if (rotation != closest) {
        animation.play(animations[animationRotations[closest]]["fire"]);
        rotation = closest;
      }
      return;
    }
    var currentVelocity = new h3d.Vector(direction.x, direction.y);
    var newRotation : haxe.Int32 = hxd.Math.ceil(
      (hxd.Math.atan2(currentVelocity.y, currentVelocity.x) / hxd.Math.PI) * 100
    );
    var isMoving = currentVelocity.length() > 0.1;
    if (!isMoving) {
      animation.play(animations[animationRotations[rotation]]["idle"]);
      wasMoving = isMoving;
      return;
    }
    if ((rotation != newRotation || wasMoving != isMoving) && currentVelocity.length() > 0.1) {
      animation.play(animations[animationRotations[newRotation]]["walk"]);
      rotation = newRotation;
    }
  }

  function onUpdate(dt: Float) {
    if (!shooting) {
      var currentVelocity = new h3d.Vector(direction.x, direction.y);
      currentVelocity.normalize();
      currentVelocity.scale(SPEED);
      if (currentVelocity.length() > 0.5) {
        // trace(currentVelocity.length());
        entity.setVelocity(currentVelocity.x, currentVelocity.y);
      }
    }
  }

  function createDebugUpdate() {
    var font : h2d.Font = hxd.res.DefaultFont.get();

    var cellXText = new h2d.Text(font, entity.sprite);
    cellXText.text = "Player CellX: " + entity.cellX;
    cellXText.x = -scene.width * 0.5 + 64;
    cellXText.y = -scene.height * 0.5 + 90;

    var cellYText = new h2d.Text(font, entity.sprite);
    cellYText.text = "Player CellY: " + entity.cellY;
    cellYText.x = -scene.width * 0.5 + 64;
    cellYText.y = -scene.height * 0.5 + 110;

    var cellRatioXText = new h2d.Text(font, entity.sprite);
    cellRatioXText.text = "Player RatioX: " + entity.cellRatioX;
    cellRatioXText.x = -scene.width * 0.5 + 64;
    cellRatioXText.y = -scene.height * 0.5 + 130;

    var cellRatioYText = new h2d.Text(font, entity.sprite);
    cellRatioYText.text = "Player RatioY: " + entity.cellRatioY;
    cellRatioYText.x = -scene.width * 0.5 + 64;
    cellRatioYText.y = -scene.height * 0.5 + 150;

    var xText = new h2d.Text(font, entity.sprite);
    xText.text = "Player X: " + entity.x;
    xText.x = -scene.width * 0.5 + 64;
    xText.y = -scene.height * 0.5 + 170;

    var yText = new h2d.Text(font, entity.sprite);
    yText.text = "Player Y: " + entity.y;
    yText.x = -scene.width * 0.5 + 64;
    yText.y = -scene.height * 0.5 + 190;

    var velocity = new h2d.Text(font, entity.sprite);
    velocity.text = "Player velocity: x - " + entity.velocityX + " y - " + entity.velocityY;
    velocity.x = -scene.width * 0.5 + 64;
    velocity.y = -scene.height * 0.5 + 210;

    var tile = h2d.Tile.fromColor(0xFF0000, 4, 4, 1);
    var bmp = new h2d.Bitmap(tile, scene);

    return (dt) -> {
      cellXText.text = "Player CellX: " + entity.cellX;
      cellYText.text = "Player CellY: " + entity.cellY;
      cellRatioXText.text = "Player RatioX: " + entity.cellRatioX;
      cellRatioYText.text = "Player RatioY: " + entity.cellRatioY;
      xText.text = "Player X: " + entity.x;
      yText.text = "Player Y: " + entity.y;
      velocity.text = "Player velocity: x = " + entity.velocityX + "; y = " + entity.velocityY;
      bmp.x = entity.x;
      bmp.y = entity.y;
      onUpdate(dt);
    };
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

  function loadAnimations() {
    createAnimationTypes();
    var charWalkTileImage = hxd.Res.player.walk.toTile();
    var charIdleTileImage = hxd.Res.player.idle.toTile();
    var charFireTileImage = hxd.Res.player.fire.toTile();
    
    {
      animations["SD"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 0, SPRITE_SIZE, SPRITE_SIZE)];
      // for(i in animations["SD"]["walk"]) {
      //   i.scaleToSize(SPRITE_SIZE*2, SPRITE_SIZE*2);
      // }
      animations["SW"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["WD"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NW"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ND"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NE"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ED"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["SE"]["walk"] = [for(x in 0 ... 15) charWalkTileImage.sub(x * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
  
      animations["SD"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 0, SPRITE_SIZE, SPRITE_SIZE)];
      animations["SW"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["WD"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NW"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ND"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NE"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ED"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["SE"]["idle"] = [for(x in 0 ... 15) charIdleTileImage.sub(x * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
  
      animations["SD"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 0, SPRITE_SIZE, SPRITE_SIZE)];
      animations["SW"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["WD"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NW"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 3 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ND"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 4 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["NE"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 5 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["ED"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 6 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
      animations["SE"]["fire"] = [for(x in 0 ... 5) charFireTileImage.sub(x * SPRITE_SIZE, 7 * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
    }
  }

  function registerInput() {
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

    InputManager.registerEventHandler("player-mouseL", InputName.mouseL, (repeat) -> {
      shooting = true;
      updateRotation();
    });
    InputManager.registerReleaseEventHandler("player-mouseL", InputName.mouseL, () -> {
      shooting = false;
      updateRotation();
    });
    InputManager.registerChangeEventHandler("player-mouseMove", InputName.mouseMove, () -> {
      if (shooting) {
        updateRotation();
      }
    });
  }
}
