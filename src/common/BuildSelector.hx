package common;

import helpers.BuildingTypes.Buildings;
import helpers.BuildingTypes.BuildingsMap;
import h2d.domkit.Object;
import Main.LayerIndexes;

class BuildSelector {
	static var container:ContainerComp;

	public static function init() {
		container = new ContainerComp(Main.scene);
		Main.layers.add(container, LayerIndexes.UI);

		container.button1.label = "Drill";
		container.button1.icon.tile = h2d.Tile.fromColor(0xc28446, 32, 32, 0.5);
		container.button1.onClick = createButtonHandler(Buildings.DRILL);

		container.button2.label = "Tree";
		container.button2.icon.tile = h2d.Tile.fromColor(0x3be68b, 32, 32, 0.5);
		container.button2.onClick = createButtonHandler(Buildings.TREE);

		container.button3.label = "Turret";
		container.button3.icon.tile = h2d.Tile.fromColor(0xffffff, 32, 32, 0.5);
		container.button3.onClick = createButtonHandler(Buildings.TURRET);

		container.button4.label = "Wall";
		container.button4.icon.tile = h2d.Tile.fromColor(0x747848, 32, 32, 0.5);
		container.button4.onClick = createButtonHandler(Buildings.WALL);

		container.button1.onClick();
		var style = new h2d.domkit.Style();
		style.load(hxd.Res.style);
		style.addObject(container);
	}

	static function createButtonHandler(building:Buildings) {
		var config = BuildingsMap[building];
		return () -> {
			OrderHandler.buildFunction = config.buildFunction;
			OrderHandler.buildName = config.name;
			OrderHandler.setSquare(config.buildIndicator);
		};
	}

	public static function update() {
		container.x = Main.girl.x - 64 * 3 / 2;
		container.y = Main.girl.y + Main.scene.height / 2 - 100;
	}
}

@:uiComp("container")
class ContainerComp extends h2d.Flow implements h2d.domkit.Object {
	static var SRC =<container> < button

	public id = "button1" / > < button
	public id = "button2" / > < button
	public id = "button3" / > < button
	public id = "button4" / > < / container > public function new(?parent) {
		super(parent);
		initComponent();
	}
}

@:uiComp("button")
class ButtonComp extends h2d.Flow implements h2d.domkit.Object {
	static var SRC =<button> < bitmap

	public id = "icon" / > < text
	color = "#000000"
	public id = "labelTxt" / > < / button > public var label(get, set):String;

	function get_label()
		return labelTxt.text;

	function set_label(s) {
		labelTxt.text = s;
		return s;
	}

	public function new(?parent) {
		super(parent);
		initComponent();
		enableInteractive = true;
		interactive.onClick = function(_) onClick();
		interactive.onOver = function(_) {
			OrderHandler.disabled = true;
			dom.hover = true;
		};
		interactive.onPush = function(_) {
			dom.active = true;
		};
		interactive.onRelease = function(_) {
			dom.active = false;
		};
		interactive.onOut = function(_) {
			OrderHandler.disabled = false;
			dom.hover = false;
		};
	}

	public dynamic function onClick() {}
}
