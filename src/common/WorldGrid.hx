package common;

import haxe.ds.Map;
import h2d.Object;

typedef Cell = {x: Int, y: Int};
typedef Position = {x: Float, y: Float};
typedef Size = { w: Float, h: Float };

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

  public static function addStaticObject(object: Object, size: Size) {
    var startingColumn = Math.floor((object.x - (size.w / 2)) / CELL_SIZE);
    var endingColumn   = Math.floor((object.x + (size.w / 2)) / CELL_SIZE);
    var startingRow    = Math.floor((object.y - (size.h / 2)) / CELL_SIZE);
    var endingRow      = Math.floor((object.y + (size.h / 2)) / CELL_SIZE);

    var columnCount = endingColumn - startingColumn;
    var rowCount    = endingRow - startingRow;

    for (row in 0 ... rowCount) {
      for (column in 0 ... columnCount) {
        var cell = { x: startingColumn + column, y: startingRow + row };
        staticObjects[cell.x + ":" + cell.y] = object;
      }
    }
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
    var nextPosition = { x: currentPosition.x + velocity.x, y: currentPosition.y + velocity.y };
    var nextCell = getObjectCellFromPosition(nextPosition);

    // CHECK IF NEXT POSITION IS TAKEN
    if (checkCollision(nextCell)) {
      // CHECK IF MOVING ONLY IN X AXIS NEXT POSITION IS TAKEN
      var withOnlyXVelocity = { x: currentPosition.x + velocity.x, y: currentPosition.y };
      var cellWithOnlyXVelocity = getObjectCellFromPosition(withOnlyXVelocity);
      if (checkCollision(cellWithOnlyXVelocity)) {
        // CHECK IF MOVING ONLY IN Y AXIS NEXT POSITION IS TAKEN
        var withOnlyYVelocity = { x: currentPosition.x, y: currentPosition.y + velocity.y };
        var cellWithOnlyYVelocity = getObjectCellFromPosition(withOnlyYVelocity);
        if (checkCollision(cellWithOnlyYVelocity)) {
          // IF CAN'T MOVE IN SINGLE DIRECTIONS, STAY STILL
          return currentPosition;
        }
        return withOnlyYVelocity;
      }
      return withOnlyXVelocity;
    }
    return nextPosition;
  }
}