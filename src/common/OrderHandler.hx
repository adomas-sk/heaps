package common;

import common.WorldGrid.Cell;
import entities.buildings.Drill;
import haxe.ds.Map;
import Main.layerIndexes;
import common.DroneScheduler.DroneOrderTypes;
import h3d.Vector;
import common.InputManager;
import h2d.Bitmap;
import h2d.Object;

typedef BuildIndicator = {
  var h: Int;
  var w: Int;
}
typedef BuildIndicatorInfo = {
  var h: Int;
  var w: Int;
  var hOffset: Int;
  var wOffset: Int;
}

class OrderHandler {
  static inline var BLOCK_SIZE = 32;
  static var buildIndicator: Bitmap;
  static var buildIndicatorInfo: BuildIndicatorInfo = {
    h: 32,
    w: 32,
    hOffset: 0,
    wOffset: 0,
  };

  static var currentOrderType: Null<DroneOrderTypes> = null;

  static var buildings: Map<String, Object> = [];

  public static function init() {
    buildIndicator = new Bitmap(h2d.Tile.fromColor(0x0099FF, BLOCK_SIZE, BLOCK_SIZE, 0.4), Main.scene);
    setSquare({ w: 64, h: 64});
    InputManager.registerChangeEventHandler("building-square", InputName.mouseMove, (event: hxd.Event) -> {
      var cell = getCell(true);

      buildIndicator.x = cell.x * BLOCK_SIZE;
      buildIndicator.y = cell.y * BLOCK_SIZE;

      if (currentOrderType != null) {
        createOrder(currentOrderType);
      }
    });

    InputManager.registerEventHandler("order-handler-mouseL", InputName.mouseL, (repeat: Bool) -> {
      if (currentOrderType == null) {
        buildIndicator.alpha = 0.7;

        currentOrderType = DroneOrderTypes.DELIVER;
        createOrder(currentOrderType);
      }
    });
    InputManager.registerReleaseEventHandler("order-handler-mouseL", InputName.mouseL, () -> {
      buildIndicator.alpha = 1;

      currentOrderType = null;
    });

    InputManager.registerEventHandler("order-handler-mouseR", InputName.mouseR, (repeat: Bool) -> {
      if (currentOrderType == null) {
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

  public static function setSquare(newBuildIndicator: BuildIndicator) {
    buildIndicator.remove();
    buildIndicatorInfo = {
      hOffset: Math.round((newBuildIndicator.h - BLOCK_SIZE) / 2),
      wOffset: Math.round((newBuildIndicator.w - BLOCK_SIZE) / 2),
      w: newBuildIndicator.w,
      h: newBuildIndicator.h
    };
    buildIndicator = new Bitmap(
      h2d.Tile.fromColor(
        0x0099FF,
        newBuildIndicator.w,
        newBuildIndicator.h,
        0.4
      ),
      Main.scene
    );
  }

  static function createOrder(orderType: DroneOrderTypes) {
    switch(orderType) {
      case DroneOrderTypes.DELIVER: {
        var cell = getCell(true);
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
      case DroneOrderTypes.RETRIEVE: {
        var cell = getCell();
        var buildingInCell = buildings[cell.x + ":" + cell.y];
        if (buildingInCell != null && buildingInCell.alpha > 0.99) {
          DroneScheduler.addOrder({
            location: new Vector(buildingInCell.x, buildingInCell.y),
            type: orderType,
            callBack: createRetrieveCallback(buildingInCell)
          });
        }
      }
    }
  }

  static function createDeliverCallback(buildingX: Float, buildingY: Float) {
    var drill = new Drill({x: buildingX, y: buildingY});

    Main.layers.add(drill, layerIndexes.GROUND);
    var cell = getCell(true);
    addBuildings(cell, drill);

    return () -> {
      drill.build();
      WorldGrid.addStaticObject(drill, { h: buildIndicatorInfo.h, w: buildIndicatorInfo.w });
    };
  }

  static function createRetrieveCallback(building: Object) {
    var cell = getCell();

    var tile = h2d.Tile.fromColor(0xfc2c03, buildIndicatorInfo.w, buildIndicatorInfo.h, 1);
    tile.dx -= buildIndicatorInfo.w / 2;
    tile.dy -= buildIndicatorInfo.h / 2;
    var removalIndicator = new Bitmap(tile, Main.scene);
    removalIndicator.x = building.x;
    removalIndicator.y = building.y;
    removalIndicator.alpha = 0.5;

    removeBuildings(cell);
    return () -> {
      removalIndicator.remove();
      building.remove();
      WorldGrid.removeStaticObject(building, { h: buildIndicatorInfo.h, w: buildIndicatorInfo.w });
    };
  }

  static function getCell(?withOffset: Bool): Cell {
    return {
      x: Math.floor((Main.scene.mouseX - (withOffset ? buildIndicatorInfo.wOffset : 0)) / BLOCK_SIZE),
      y: Math.floor((Main.scene.mouseY - (withOffset ? buildIndicatorInfo.hOffset : 0)) / BLOCK_SIZE)
    };
  }

  static function addBuildings(cell: Cell, building: Object) {
    var cols = Math.round(buildIndicatorInfo.w / BLOCK_SIZE);
    var rows = Math.round(buildIndicatorInfo.h / BLOCK_SIZE);

    for (col in 0 ... cols) {
      for (row in 0 ... rows) {
        buildings[(cell.x + col) + ":" + (cell.y + row)] = building;
      }
    }
  }

  static function isBuildingSpaceFree(cell: Cell) {
    var cols = Math.round(buildIndicatorInfo.w / BLOCK_SIZE);
    var rows = Math.round(buildIndicatorInfo.h / BLOCK_SIZE);

    for (col in 0 ... cols) {
      for (row in 0 ... rows) {
        if (buildings[(cell.x + col) + ":" + (cell.y + row)] != null) {
          return false;
        }
      }
    }
    return true;
  }

  static function removeBuildings(cell: Cell) {
    var building = buildings[cell.x + ":" + cell.y];
    for (key in buildings.keys()) {
      if (buildings[key] == building) {
        buildings[key] = null;
      }
    }
  }
}