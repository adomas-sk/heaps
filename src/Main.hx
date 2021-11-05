import h2d.Camera;
import h2d.Object;
import entities.Nest;
import entities.ResourceBundle;
import hxd.Math;
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

  override function init() {
    // Window.getInstance().vsync = false;
    hxd.Window.getInstance().addEventTarget(moveMouse);
    scene = s2d;
    
    //BACKGROUND
    new Bitmap(h2d.Tile.fromColor(0x666666, 1000, 1000, 1), s2d);

    // RESOURCE
    resourceBundles.push(new ResourceBundle(400, 350, 50, 12, s2d));
    resourceBundles.push(new ResourceBundle(500, 500, 50, 8, s2d));

    // CONTROL
    square = new Bitmap(h2d.Tile.fromColor(0x0099FF, BLOCK_SIZE, BLOCK_SIZE, 0.4), s2d);
    var interaction = new h2d.Interactive(BLOCK_SIZE, BLOCK_SIZE, square);
    interaction.onPush = function(event : hxd.Event) {
      square.alpha = 0.7;
    }
    interaction.onRelease = function(event : hxd.Event) {
      square.alpha = 1;
    }
    interaction.onClick = function(event : hxd.Event) {
      if (!movingCamera) {
        var newNestX = square.x + BLOCK_SIZE / 2;
        var newNestY = square.y + BLOCK_SIZE / 2;
        for (nest in nests) {
          if (nest.position.x == newNestX && nest.position.y == newNestY) {
            return;
          }
        }
        nests.push(new Nest(square.x + BLOCK_SIZE / 2, square.y + BLOCK_SIZE / 2));
      }
    }
    mouse = new Bitmap(h2d.Tile.fromColor(0xFF0000, 4, 4, 1), s2d);

    // FPS
    var font : h2d.Font = hxd.res.DefaultFont.get();
    fpsText = new h2d.Text(font, s2d);
    fpsText.text = "";
    fpsText.x = 0;
    fpsText.y = 0;
  }

  function moveMouse(event : hxd.Event) {
    switch(event.kind) {
      case EKeyDown: {
        if (event.keyCode == 32) {
          movingCamera = true;
          square.visible = false;
        }
      }
      case EKeyUp:
        if (event.keyCode == 32) {
          movingCamera = false;
          square.visible = true;
        }
      case EMove: {
        if (
          movingCamera &&
          lastMousePos.x != event.relX &&
          lastMousePos.y != event.relY
        ) {
          s2d.interactiveCamera.x -= event.relX - lastMousePos.x;
          s2d.interactiveCamera.y -= event.relY - lastMousePos.y;

          fpsText.x = s2d.interactiveCamera.x;
          fpsText.y = s2d.interactiveCamera.y;
        }
        mouse.x = s2d.interactiveCamera.x + event.relX - 2;
        mouse.y = s2d.interactiveCamera.y + event.relY - 2;

        square.x = Math.floor(mouse.x / BLOCK_SIZE) * BLOCK_SIZE;
        square.y = Math.floor(mouse.y / BLOCK_SIZE) * BLOCK_SIZE;

        lastMousePos = {x: event.relX, y: event.relY};
      }
      case _:
    }
  }

  override function update(dt:Float) {
    var fps = Std.int(hxd.Timer.fps());
    fpsText.text = '$fps';

    for(nest in nests) {
      nest.update(dt);
    }
  }

  static function main() {
    hxd.Res.initLocal();
    new Main();
  }
}
