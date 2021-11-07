import common.GroundRenderer;
import entities.Drone;
import common.InputManager;
import h3d.Vector;
import entities.Girl;
import h2d.Bitmap;

class Main extends hxd.App {
  static inline var BLOCK_SIZE = 32;

  public static var scene: h2d.Scene;

  var devMode = false;
  var dragging = false;
  var tileName = GroundTiles.GRASS1;
  var draggedMouseThrough = [];

  var fpsText : h2d.Text;

  var square: Bitmap;

  var drones: Array<Drone> = [];
  var girl: Girl;

  override function init() {
    // Window.getInstance().vsync = false;
    hxd.Window.getInstance().addEventTarget(InputManager.onEvent);
    scene = s2d;

    // GROUND
    GroundRenderer.renderGround();

    // GIRL
    girl = new Girl(0, 0);

    // DRONE
    drones.push(new Drone(girl));

    // CAMERA
    s2d.interactiveCamera.follow = girl;
    s2d.interactiveCamera.anchorX = 0.5;
    s2d.interactiveCamera.anchorY = 0.5;

    // CONTROL
    square = new Bitmap(h2d.Tile.fromColor(0x0099FF, BLOCK_SIZE, BLOCK_SIZE, 0.4), s2d);
    InputManager.registerChangeEventHandler("building-square", InputName.mouseMove, (event: hxd.Event) -> {
      var mouseX = s2d.interactiveCamera.x - s2d.width / 2 + event.relX - 2;
      var mouseY = s2d.interactiveCamera.y - s2d.height / 2 + event.relY - 2;

      square.x = Math.floor(mouseX / BLOCK_SIZE) * BLOCK_SIZE;
      square.y = Math.floor(mouseY / BLOCK_SIZE) * BLOCK_SIZE;
    });

    // DEVMODE
    InputManager.registerEventHandler("devmode", InputName.bslash, (repeat: Bool) -> {
      devMode = true;
      InputManager.registerEventHandler("devmode", InputName.num1, (repeat: Bool) -> {
        tileName = GroundTiles.GRASS1;
      });
      InputManager.registerEventHandler("devmode", InputName.num2, (repeat: Bool) -> {
        tileName = GroundTiles.GRASS2;
      });
      InputManager.registerEventHandler("devmode", InputName.num3, (repeat: Bool) -> {
        tileName = GroundTiles.GRASS3;
      });
      InputManager.registerEventHandler("devmode", InputName.num4, (repeat: Bool) -> {
        tileName = GroundTiles.ROADL;
      });
      InputManager.registerEventHandler("devmode", InputName.num5, (repeat: Bool) -> {
        tileName = GroundTiles.ROADLB;
      });
      InputManager.registerEventHandler("devmode", InputName.num6, (repeat: Bool) -> {
        tileName = GroundTiles.ROAD;
      });
      InputManager.registerEventHandler("devmode", InputName.mouseL, (repeat: Bool) -> {
        if (!repeat) {
          var newCell = square.x + ":" + square.y;
          draggedMouseThrough.push(newCell);
          GroundRenderer.addTile(square.x, square.y, tileName);
          dragging = true;
        }
      });
      InputManager.registerReleaseEventHandler("devmode", InputName.mouseL, () -> {
        dragging = false;
      });
      InputManager.registerChangeEventHandler("devmode", InputName.mouseMove, (event: hxd.Event) -> {
        if (dragging) {
          var newCell = square.x + ":" + square.y;
          if (draggedMouseThrough.contains(newCell)) {
            return;
          }
          draggedMouseThrough.push(newCell);
          GroundRenderer.addTile(square.x, square.y, tileName);
        }
      });
    });

    var interaction = new h2d.Interactive(BLOCK_SIZE, BLOCK_SIZE, square);
    interaction.onPush = function(event : hxd.Event) {
      square.alpha = 0.7;
    }
    interaction.onRelease = function(event : hxd.Event) {
      draggedMouseThrough = [];
      square.alpha = 1;
    }
    interaction.onClick = function(event : hxd.Event) {
      if (devMode) {
        return;
      }
      var newBuildingX = square.x + BLOCK_SIZE / 2;
      var newBuildingY = square.y + BLOCK_SIZE / 2;
      var addTile = () -> {
        var tile = h2d.Tile.fromColor(0x3d3322, BLOCK_SIZE, BLOCK_SIZE, 1);
        tile.dx -= BLOCK_SIZE / 2;
        tile.dy -= BLOCK_SIZE / 2;
        var building = new Bitmap(tile, s2d);
        building.x = newBuildingX;
        building.y = newBuildingY;
      };
      drones[0].orderDelivery(new Vector(newBuildingX, newBuildingY), addTile);
    }

    // FPS
    var font : h2d.Font = hxd.res.DefaultFont.get();
    fpsText = new h2d.Text(font, s2d);
    fpsText.text = "";
    fpsText.x = 0;
    fpsText.y = 0;
  }

  override function update(dt:Float) {
    for(drone in drones) {
      drone.update(dt);
    }
    girl.update(dt);
    
    var fps = Std.int(hxd.Timer.fps());
    fpsText.text = '$fps';
    fpsText.x = girl.x - s2d.width / 2;
    fpsText.y = girl.y - s2d.height / 2;
  }

  static function main() {
    hxd.Res.initLocal();
    new Main();
  }
}
