import entities.environment.Grass;
import common.Loader;
import hxd.Window;
import h2d.Layers;
import h2d.Bitmap;
import common.Killables;
import common.OrderHandler;
import common.DroneScheduler;
import common.BuildSelector;
import common.InputManager;
import entities.Drone;
import entities.Girl;

enum abstract LayerIndexes(Int) to Int {
	var GROUND;
	var ON_GROUND;
	var BUILD_INDICATOR;
	var UI;
}

class Main extends hxd.App {
	static inline var BLOCK_SIZE = 32;
	static inline var LAYER_SORT_TIMER = 0.3;

	public static var scene:h2d.Scene;
	public static var girl:Girl;
	public static var layers:Layers;
	var grass: Grass;

	var lastLayerSort = 0.;

	var fpsText:h2d.Text;

	override function init() {
		Window.getInstance().vsync = false;
		Window.getInstance().addEventTarget(InputManager.onEvent);
		Window.getInstance().addResizeEvent(resizeHandler);
		scene = s2d;
		
		this.grass = new Grass();
		// LAYERS
		layers = new Layers(s2d);

		// GRASS
		var grass = new h2d.Bitmap(h2d.Tile.fromColor(0x96C43E, 10000, 10000, 0.3), Main.scene);
		grass.x -= 10000 / 2;
		grass.y -= 10000 / 2;
		layers.add(grass, LayerIndexes.GROUND);

		// TREE
		// var tree = new Tree({x: 128, y: 128});

		// LOAD
		Loader.load();

		// GIRL
		girl = new Girl(0, 0);
		layers.add(girl, LayerIndexes.ON_GROUND);

		// UI
		BuildSelector.init();

		// DRONES
		DroneScheduler.init();
		for (i in 0...20) {
			var newDrone = new Drone(girl);
			DroneScheduler.addDrone(newDrone);
		}

		// CAMERA
		s2d.interactiveCamera.follow = girl;
		s2d.interactiveCamera.anchorX = 0.5;
		s2d.interactiveCamera.anchorY = 0.5;

		// CONTROL
		OrderHandler.init();

		// FPS
		var font:h2d.Font = hxd.res.DefaultFont.get();
		fpsText = new h2d.Text(font, s2d);
		fpsText.text = "";
		fpsText.x = 0;
		fpsText.y = 0;
	}

	override function update(dt:Float) {
		// TODO: Fix this
		lastLayerSort += dt;
		if (lastLayerSort > LAYER_SORT_TIMER) {
			layers.ysort(LayerIndexes.ON_GROUND);
			lastLayerSort = 0;
		}
		grass.update(dt);

		// TODO: Add centralised update manager
		DroneScheduler.updateDrones(dt);
		girl.update(dt);
		Killables.update(dt);
		BuildSelector.update();

		var fps = Std.int(hxd.Timer.fps());
		fpsText.text = '$fps';
		fpsText.x = girl.x - s2d.width / 2;
		fpsText.y = girl.y - s2d.height / 2;
	}

	static function resizeHandler() {
		DroneScheduler.resizeHandler();
	}

	static function main() {
		hxd.Res.initLocal();
		new Main();
	}
}
