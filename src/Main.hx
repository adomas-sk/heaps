import entities.Drone;
import common.InputManager;
import h3d.Vector;
import entities.Girl;
import h2d.Object;
import entities.Nest;
import entities.ResourceBundle;
import h2d.Bitmap;

class Main extends hxd.App {
  static inline var BLOCK_SIZE = 32;

  public static var scene: h2d.Scene;

  var fpsText : h2d.Text;

  var mouse: Bitmap;
  var square: Bitmap;

  var resourceBundles: Array<ResourceBundle> = [];
  var nests: Array<Nest> = [];

  var cameraFollow: Object;
  var movingCamera = false;
  var lastMousePos = {x: 0., y: 0.};

  var drones: Array<Drone> = [];
  var girl: Girl;
  var input = [
    87 => 'w',
    83 => 's',
    65 => 'a',
    68 => 'd',
  ];

  override function init() {
    // Window.getInstance().vsync = false;
    hxd.Window.getInstance().addEventTarget(InputManager.onEvent);
    scene = s2d;
    
    // BACKGROUND
    new Bitmap(h2d.Tile.fromColor(0x666666, 1000, 1000, 1), s2d);

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
    mouse = new Bitmap(h2d.Tile.fromColor(0xFF0000, 4, 4, 1), s2d);
    InputManager.registerChangeEventHandler("building-square", InputName.mouseMove, (event: hxd.Event) -> {
      mouse.x = s2d.interactiveCamera.x - s2d.width / 2 + event.relX - 2;
      mouse.y = s2d.interactiveCamera.y - s2d.height / 2 + event.relY - 2;

      square.x = Math.floor(mouse.x / BLOCK_SIZE) * BLOCK_SIZE;
      square.y = Math.floor(mouse.y / BLOCK_SIZE) * BLOCK_SIZE;

      lastMousePos = {x: event.relX, y: event.relY};
    });

    var interaction = new h2d.Interactive(BLOCK_SIZE, BLOCK_SIZE, square);
    interaction.onPush = function(event : hxd.Event) {
      square.alpha = 0.7;
    }
    interaction.onRelease = function(event : hxd.Event) {
      square.alpha = 1;
    }
    interaction.onClick = function(event : hxd.Event) {
      var newBuildingX = square.x + BLOCK_SIZE / 2;
      var newBuildingY = square.y + BLOCK_SIZE / 2;
      drones[0].orderDelivery(new Vector(newBuildingX, newBuildingY), () -> {
        var tile = h2d.Tile.fromColor(0x3d3322, BLOCK_SIZE, BLOCK_SIZE, 1);
        tile.dx -= BLOCK_SIZE / 2;
        tile.dy -= BLOCK_SIZE / 2;
        var building = new Bitmap(tile, s2d);
        building.x = newBuildingX;
        building.y = newBuildingY;
      });
    }

    // FPS
    var font : h2d.Font = hxd.res.DefaultFont.get();
    fpsText = new h2d.Text(font, s2d);
    fpsText.text = "";
    fpsText.x = 0;
    fpsText.y = 0;
  }

  override function update(dt:Float) {
    var fps = Std.int(hxd.Timer.fps());
    fpsText.text = '$fps';

    for(drone in drones) {
      drone.update(dt);
    }
    girl.update(dt);
  }

  static function main() {
    hxd.Res.initLocal();
    new Main();
  }
}
