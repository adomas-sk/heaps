package common;

import Main.layerIndexes;
import common.DroneScheduler.DroneOrderTypes;
import h3d.Vector;
import h2d.Interactive;
import common.InputManager;
import h2d.Bitmap;

class OrderHandler {
  static inline var BLOCK_SIZE = 32;
  static var square: Bitmap;
  static var interactable: Interactive;

  static var currentOrderBlocks: Array<{ x: Int, y: Int }> = [];
  static var ordering = false;

  public static function init() {
    square = new Bitmap(h2d.Tile.fromColor(0x0099FF, BLOCK_SIZE, BLOCK_SIZE, 0.4), Main.scene);
    InputManager.registerChangeEventHandler("building-square", InputName.mouseMove, (event: hxd.Event) -> {
      var cell = getCell(event);

      square.x = cell.x * BLOCK_SIZE;
      square.y = cell.y * BLOCK_SIZE;

      if (ordering) {
        for (pastBlock in currentOrderBlocks) {
          if (pastBlock.x == cell.x && pastBlock.y == cell.y) {
            return;
          }
        }

        currentOrderBlocks.push(cell);
        createOrder(event);
      }
    });

    interactable = new Interactive(BLOCK_SIZE, BLOCK_SIZE, square);
    interactable.onPush = function(event : hxd.Event) {
      square.alpha = 0.7;

      ordering = true;
      currentOrderBlocks.push(getCell(event));
      createOrder(event);
    }
    interactable.onRelease = function(event : hxd.Event) {
      square.alpha = 1;

      currentOrderBlocks = [];
      ordering = false;
    }
  }

  static function createOrder(event : hxd.Event) {
    var newBuildingX = square.x + BLOCK_SIZE / 2;
    var newBuildingY = square.y + BLOCK_SIZE / 2;

    var tile = h2d.Tile.fromColor(0x3d3322, BLOCK_SIZE, BLOCK_SIZE, 1);
    tile.dx -= BLOCK_SIZE / 2;
    tile.dy -= BLOCK_SIZE / 2;
    var building = new Bitmap(tile, Main.scene);
    building.x = newBuildingX;
    building.y = newBuildingY;
    building.alpha = 0.5;

    Main.layers.add(building, layerIndexes.GROUND);

    var addTile = () -> {
      building.alpha = 1;
      WorldGrid.addStaticObject(building, { h: BLOCK_SIZE, w: BLOCK_SIZE });
    };
    DroneScheduler.addOrder({location: new Vector(newBuildingX, newBuildingY), type: DroneOrderTypes.DELIVER, callBack: addTile});
  }

  static function getCell(event : hxd.Event) {
    return { x: Math.floor(Main.scene.mouseX / BLOCK_SIZE), y: Math.floor(Main.scene.mouseY / BLOCK_SIZE) };
  }
}