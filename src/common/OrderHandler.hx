package common;

import helpers.BuildingTypes.BuildingInfo;
import hxd.Res;
import helpers.BuildingTypes.BuildFunctionReturn;
import helpers.BuildingTypes.BuildIndicator;
import helpers.BuildingTypes.BuildIndicatorInfo;
import common.WorldGrid.Position;
import Main.LayerIndexes;
import common.WorldGrid.Cell;
import haxe.ds.Map;
import common.DroneScheduler.DroneOrderTypes;
import h3d.Vector;
import common.InputManager;
import h2d.Bitmap;
import h2d.Object;

class OrderHandler {
	static inline var BLOCK_SIZE = 32;

	public static var disabled = false;
	public static var buildFunction:(position:Position) -> BuildFunctionReturn;
	public static var buildName:String = "default";

	static var buildIndicator:Bitmap;
	static var buildIndicatorInfo:BuildIndicatorInfo = {
		h: 32,
		w: 32,
		hOffset: 0,
		wOffset: 0,
	};

	static var dropSound:hxd.res.Sound;
	static var popSound:hxd.res.Sound;
	static var currentOrderType:Null<DroneOrderTypes> = null;

	static var buildings:Map<String, BuildingInfo> = [];

	public static function init() {
		setSquare({w: 64, h: 64});
		dropSound = Res.sound_fx.drop_building;
		popSound = Res.sound_fx.pop_building;
		InputManager.registerChangeEventHandler("building-square", InputName.mouseMove, (event:hxd.Event) -> {
			var cell = getMouseCell(true);

			buildIndicator.x = cell.x * BLOCK_SIZE;
			buildIndicator.y = cell.y * BLOCK_SIZE;

			if (!disabled && currentOrderType != null) {
				createOrder(currentOrderType);
			}
		});

		InputManager.registerEventHandler("order-handler-mouseL", InputName.mouseL, (repeat:Bool) -> {
			if (!disabled && currentOrderType == null) {
				buildIndicator.alpha = 0.7;

				currentOrderType = DroneOrderTypes.DELIVER;
				createOrder(currentOrderType);
			}
		});
		InputManager.registerReleaseEventHandler("order-handler-mouseL", InputName.mouseL, () -> {
			buildIndicator.alpha = 1;

			currentOrderType = null;
		});
		InputManager.registerEventHandler("order-dump-buildings", InputName.bslash, (repeat:Bool) -> {
			trace("ALL BUILDING ----");

			var dump:Map<String, {x:Float, y:Float}> = [];
			var intemediateDump:Map<String, Array<String>> = [];
			var foundBuildings = [];
			var count = 0;
			for (key in buildings.keys()) {
				if (buildings[key] != null) {
					var building = buildings[key].building;
					if (!foundBuildings.contains(building)) {
						foundBuildings.push(building);
						count += 1;
						var id = buildings[key].name + ":" + count;
						intemediateDump[id] = [];
						for (key in buildings.keys()) {
							if (buildings[key] != null && buildings[key].building == building) {
								intemediateDump[id].push(key);
							}
						}
						var x = Math.POSITIVE_INFINITY;
						var y = Math.POSITIVE_INFINITY;
						for (locations in intemediateDump[id]) {
							var locationX = Std.parseInt(locations.split(":")[0]);
							x = locationX < x ? locationX : x;
							var locationY = Std.parseInt(locations.split(":")[1]);
							y = locationY < y ? locationY : y;
						}
						dump[id] = {x: x, y: y};
					}
				}
			}
			trace(haxe.Json.stringify(dump));
			trace("---- ALL BUILDING END");
		});

		InputManager.registerEventHandler("order-handler-mouseR", InputName.mouseR, (repeat:Bool) -> {
			if (!disabled && currentOrderType == null) {
				buildIndicator.alpha = 0.7;

				currentOrderType = DroneOrderTypes.RETRIEVE;
				createOrder(currentOrderType);
			}
		});
		InputManager.registerReleaseEventHandler("order-handler-mouseR", InputName.mouseR, () -> {
			buildIndicator.alpha = 1;

			currentOrderType = null;
		});
	}

	public static function setSquare(newBuildIndicator:BuildIndicator) {
		buildIndicator.remove();
		buildIndicatorInfo = {
			hOffset: Math.round((newBuildIndicator.h - BLOCK_SIZE) / 2),
			wOffset: Math.round((newBuildIndicator.w - BLOCK_SIZE) / 2),
			w: newBuildIndicator.w,
			h: newBuildIndicator.h
		};
		buildIndicator = new Bitmap(h2d.Tile.fromColor(0x0099FF, newBuildIndicator.w, newBuildIndicator.h, 0.4), Main.scene);
		Main.layers.add(buildIndicator, LayerIndexes.BUILD_INDICATOR);
	}

	// TODO: copy pasted code with minor changes. Refactor
	public static function instantDeliveryOrder(cell:Cell, name:String, buildSize:BuildIndicator, buildFunction:(position:Position) -> BuildFunctionReturn) {
		var buildSpace = {x: cell.x * BLOCK_SIZE, y: cell.y * BLOCK_SIZE};
		var newBuildingX = buildSpace.x + buildSize.w / 2;
		var newBuildingY = buildSpace.y + buildSize.h / 2;
		var build = buildFunction({x: newBuildingX, y: newBuildingY});

		var cols = Math.round(buildSize.w / BLOCK_SIZE);
		var rows = Math.round(buildSize.h / BLOCK_SIZE);

		for (col in 0...cols) {
			for (row in 0...rows) {
				buildings[(cell.x + col) + ":" + (cell.y + row)] = {
					building: build.object,
					name: name,
				};
			}
		}

		build.onBuild();
		WorldGrid.addStaticObject(build.object, {h: buildSize.h, w: buildSize.w});
	}

	static function createOrder(orderType:DroneOrderTypes) {
		switch (orderType) {
			case DroneOrderTypes.DELIVER:
				{
					var cell = getMouseCell(true);
					if (!isBuildingSpaceFree(cell)) {
						return;
					}
					var newBuildingX = buildIndicator.x + buildIndicatorInfo.w / 2;
					var newBuildingY = buildIndicator.y + buildIndicatorInfo.h / 2;

					DroneScheduler.addOrder({
						location: new Vector(newBuildingX, newBuildingY),
						type: orderType,
						callBack: createDeliverCallback(newBuildingX, newBuildingY)
					});
				}
			case DroneOrderTypes.RETRIEVE:
				{
					var cell = getMouseCell();
					var buildingInCell = buildings[cell.x + ":" + cell.y];
					if (buildingInCell != null && buildingInCell.building.alpha > 0.99) {
						DroneScheduler.addOrder({
							location: new Vector(buildingInCell.building.x, buildingInCell.building.y),
							type: orderType,
							callBack: createRetrieveCallback(buildingInCell.building)
						});
					}
				}
		}
	}

	static function createDeliverCallback(buildingX:Float, buildingY:Float) {
		var build = buildFunction({x: buildingX, y: buildingY});

		var cell = getMouseCell(true);
		addBuildings(cell, build.object, buildName);

		return () -> {
			dropSound.play(false, 0.6);
			build.onBuild();
			WorldGrid.addStaticObject(build.object, {h: buildIndicatorInfo.h, w: buildIndicatorInfo.w});
		};
	}

	static function createRetrieveCallback(building:Object) {
		var cell = getMouseCell();

		var tile = h2d.Tile.fromColor(0xfc2c03, buildIndicatorInfo.w, buildIndicatorInfo.h, 1);
		tile.dx -= buildIndicatorInfo.w / 2;
		tile.dy -= buildIndicatorInfo.h / 2;
		var removalIndicator = new Bitmap(tile, Main.scene);
		removalIndicator.x = building.x;
		removalIndicator.y = building.y;
		removalIndicator.alpha = 0.5;

		removeBuildings(cell);
		return () -> {
			popSound.play(false, 0.6);
			removalIndicator.remove();
			building.remove();
			WorldGrid.removeStaticObject(building, {h: buildIndicatorInfo.h, w: buildIndicatorInfo.w});
		};
	}

	static function getCell(x:Float, y:Float, ?withOffset:Bool) {
		return {
			x: Math.floor((x - (withOffset ? buildIndicatorInfo.wOffset : 0)) / BLOCK_SIZE),
			y: Math.floor((y - (withOffset ? buildIndicatorInfo.hOffset : 0)) / BLOCK_SIZE)
		};
	}

	static function getMouseCell(?withOffset:Bool):Cell {
		return getCell(Main.scene.mouseX, Main.scene.mouseY, withOffset);
	}

	static function addBuildings(cell:Cell, building:Object, name:String) {
		var cols = Math.round(buildIndicatorInfo.w / BLOCK_SIZE);
		var rows = Math.round(buildIndicatorInfo.h / BLOCK_SIZE);

		for (col in 0...cols) {
			for (row in 0...rows) {
				buildings[(cell.x + col) + ":" + (cell.y + row)] = {
					building: building,
					name: name,
				};
			}
		}
	}

	static function isBuildingSpaceFree(cell:Cell) {
		var cols = Math.round(buildIndicatorInfo.w / BLOCK_SIZE);
		var rows = Math.round(buildIndicatorInfo.h / BLOCK_SIZE);

		for (col in 0...cols) {
			for (row in 0...rows) {
				if (buildings[(cell.x + col) + ":" + (cell.y + row)] != null) {
					return false;
				}
			}
		}
		return true;
	}

	static function removeBuildings(cell:Cell) {
		var building = buildings[cell.x + ":" + cell.y].building;
		for (key in buildings.keys()) {
			if (buildings[key] != null && buildings[key].building == building) {
				buildings[key] = null;
			}
		}
	}
}
