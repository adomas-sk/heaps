import hxd.Window;
import entities.Player;
import common.EntityManager;
import common.InputManager;

class Main extends hxd.App {
  var fpsText : h2d.Text;
  var player : Player;
  var block : h2d.Bitmap;

  override function init() {
    Window.getInstance().vsync = false;
    block = new h2d.Bitmap(h2d.Tile.fromColor(0x222222, 100000, 100000, 1), s2d);
    block.x = -500;
    block.y = -500;

    var bloc2 = new h2d.Bitmap(h2d.Tile.fromColor(0x449999, 50, 50, 1), s2d);
    bloc2.x = s2d.width * 0.5;
    bloc2.y = s2d.height * 0.5;

    player = new Player(s2d);

    hxd.Window.getInstance().addEventTarget(InputManager.onEvent);

    var font : h2d.Font = hxd.res.DefaultFont.get();
    fpsText = new h2d.Text(font, player.entity.sprite);
    fpsText.text = "Hello World\nHeaps is great!";
    fpsText.textAlign = Center;
    fpsText.x = -s2d.width * 0.5 + 150;
    fpsText.y = -s2d.height * 0.5 + 128;
  }

  override function update(dt:Float) {
    var fps = Std.int(hxd.Timer.fps());
    fpsText.text = '$fps';
    EntityManager.calculationUpdate(dt);
    EntityManager.update(dt);
  }

  static function main() {
    hxd.Res.initLocal();
    new Main();
  }
}
