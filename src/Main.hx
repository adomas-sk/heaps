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

  override function init() {
    // Window.getInstance().vsync = false;
    hxd.Window.getInstance().addEventTarget(moveMouse);
    scene = s2d;
    
    var background = new Bitmap(h2d.Tile.fromColor(0x666666, 1000, 1000, 1), s2d);

    // RESOURCE
    resourceBundles.push(new ResourceBundle(400, 350, 50, 12, s2d));
    resourceBundles.push(new ResourceBundle(500, 500, 50, 8, s2d));

    // NEST
    // nests.push(new Nest(100, 100));

    // CONTROL
    square = new Bitmap(h2d.Tile.fromColor(0x00FF00, BLOCK_SIZE, BLOCK_SIZE, 0.4), s2d);
    var interaction = new h2d.Interactive(BLOCK_SIZE, BLOCK_SIZE, square);
    interaction.onPush = function(event : hxd.Event) {
      square.alpha = 0.7;
    }
    interaction.onRelease = function(event : hxd.Event) {
      square.alpha = 1;
    }
    interaction.onClick = function(event : hxd.Event) {
      nests.push(new Nest(square.x + BLOCK_SIZE / 2, square.y + BLOCK_SIZE / 2));
      trace("click!");
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
      case EMove: {
        mouse.x = event.relX - 2;
        mouse.y = event.relY - 2;

        square.x = Math.floor(mouse.x / BLOCK_SIZE) * BLOCK_SIZE;
        square.y = Math.floor(mouse.y / BLOCK_SIZE) * BLOCK_SIZE;
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
