package common;

import haxe.ds.Map;
import h2d.Object;

typedef Cell = {x: Int, y: Int};
typedef Position = {x: Float, y: Float};
// interface Cell {
//   public var x: Float;
//   public var y: Float;
// }

class WorldGrid {
  public static inline var CELL_SIZE = 16;

  static var staticObjects: Map<String, Object> = [];
  static var dynamicObjects = [];

  public static function checkCollision(cell: Cell) {
    if (staticObjects.exists(cell.x + ":" + cell.y)) {
      return true;
    }
    // TODO: check collisions for dynamic objects
    return false;
  }

  public static function addStaticObject(object: Object) {
    var cell = getObjectCell(object);
    staticObjects[cell.x + ":" + cell.y] = object;
  }

  public static function removeStaticObject(object: Object) {
    var cell = getObjectCell(object);
    return staticObjects.remove(cell.x + ":" + cell.y);
  }

  public static function addDynamicObject() {
    
  }

  public static function getObjectCell(object: Object) {
    return getObjectCellFromPosition({x: object.x, y: object.y});
  }

  public static function getObjectCellFromPosition(position: Position) {
    return {x: Math.floor(position.x / CELL_SIZE), y: Math.floor(position.y / CELL_SIZE)};
  }

  public static function getNextPosition(currentPosition: Position, velocity: Position) {
    var cell = getObjectCellFromPosition(currentPosition);
    var ratio = {
      x: cell.x + (currentPosition.x - cell.x * CELL_SIZE),
      y: cell.y + (currentPosition.y - cell.y * CELL_SIZE)
    };
    var nextX = currentPosition.x;
    var nextY = currentPosition.y;
    if (ratio.x > 0.8 && checkCollision({x: cell.x + 1, y: cell.y})) {
      nextX += cell.x * CELL_SIZE + CELL_SIZE * 0.8;
    } else if (ratio.x < 0.2 && checkCollision({x: cell.x - 1, y: cell.y})) {
      nextX += cell.x * CELL_SIZE + CELL_SIZE * 0.2;
    } else {
      nextX += velocity.x;
    }

    if (ratio.y > 0.8 && checkCollision({x: cell.x, y: cell.y + 1})) {
      nextY += cell.y * CELL_SIZE + CELL_SIZE * 0.8;
    } else if (ratio.y < 0.2 && checkCollision({x: cell.x, y: cell.y - 1})) {
      nextY += cell.y * CELL_SIZE + CELL_SIZE * 0.2;
    } else {
      nextY += velocity.y;
    }
    return {x: nextX, y: nextY};
  }
}