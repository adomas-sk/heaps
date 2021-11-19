import entities.resources.Tree;
import h2d.Layers;
import hxd.Window;
import common.OrderHandler;
import common.DroneScheduler;
import common.GroundRenderer;
import common.BuildSelector;
import entities.Drone;
import common.InputManager;
import entities.Girl;
import h2d.Bitmap;

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

	var lastLayerSort = 0.;

	var devMode = false;
	var dragging = false;
	var tileName = GroundTiles.GRASS1;
	var draggedMouseThrough = [];

	var fpsText:h2d.Text;

	var square:Bitmap;

	var drones:Array<Drone> = [];

	override function init() {
		// Window.getInstance().vsync = false;
		Window.getInstance().addEventTarget(InputManager.onEvent);
		Window.getInstance().addResizeEvent(resizeHandler);
		scene = s2d;

		// LAYERS
		layers = new Layers(s2d);

		// GROUND
		GroundRenderer.renderGround();

		// GRASS
		var grass = new h2d.Bitmap(h2d.Tile.fromColor(0xa7da48, 10000, 10000, 0.3), Main.scene);
		grass.x -= 10000 / 2;
		grass.y -= 10000 / 2;
		layers.add(grass, LayerIndexes.GROUND);

		// TREE
		var tree = new Tree({x: 128, y: 128});

		// GIRL
		girl = new Girl(0, 0);
		layers.add(girl, LayerIndexes.ON_GROUND);

		// UI
		BuildSelector.init();

		// DRONES
		DroneScheduler.init();
		for (i in 0...10) {
			var newDrone = new Drone(girl);
			DroneScheduler.addDrone(newDrone);
		}

		// CAMERA
		s2d.interactiveCamera.follow = girl;
		s2d.interactiveCamera.anchorX = 0.5;
		s2d.interactiveCamera.anchorY = 0.5;

		// CONTROL
		OrderHandler.init();

		// DEVMODE
		InputManager.registerEventHandler("devmode", InputName.bslash, (repeat:Bool) -> {
			devMode = true;
			InputManager.registerEventHandler("devmode", InputName.num1, (repeat:Bool) -> {
				tileName = GroundTiles.GRASS1;
			});
			InputManager.registerEventHandler("devmode", InputName.num2, (repeat:Bool) -> {
				tileName = GroundTiles.GRASS2;
			});
			InputManager.registerEventHandler("devmode", InputName.num3, (repeat:Bool) -> {
				tileName = GroundTiles.GRASS3;
			});
			InputManager.registerEventHandler("devmode", InputName.num4, (repeat:Bool) -> {
				tileName = GroundTiles.ROADL;
			});
			InputManager.registerEventHandler("devmode", InputName.num5, (repeat:Bool) -> {
				tileName = GroundTiles.ROADLB;
			});
			InputManager.registerEventHandler("devmode", InputName.num6, (repeat:Bool) -> {
				tileName = GroundTiles.ROAD;
			});
			InputManager.registerEventHandler("devmode", InputName.mouseL, (repeat:Bool) -> {
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
			InputManager.registerChangeEventHandler("devmode", InputName.mouseMove, (event:hxd.Event) -> {
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

		DroneScheduler.updateDrones(dt);
		girl.update(dt);
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
