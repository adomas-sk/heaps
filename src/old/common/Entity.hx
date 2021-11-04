package old.common;

class Entity {
  static public var CELL_SIZE = 16;
  static inline var FRICTION = 0.005;

  public var sprite: h2d.Object;

  public var cellX: Int;
  public var cellY: Int;
  public var cellRatioX: Float = 0.;
  public var cellRatioY: Float = 0.;

  public var x: Float;
  public var y: Float;

  public var velocityX: Float = 0;
  public var velocityY: Float = 0;

  public var spriteOffset = {x: 0, y: 0};

  public var staticEntity: Bool = false;

  var onUpdate: (dt: Float) -> Void = (dt) -> return;

  public function new(id: String,cellXInit, cellYInit, spriteInit, ?isStatic: Bool) {
    if (isStatic) {
      staticEntity = isStatic;
    }
    sprite = spriteInit;

    cellX = cellXInit;
    cellY = cellYInit;

    x = Std.int((cellX + cellRatioX) * CELL_SIZE);
    y = Std.int((cellY + cellRatioY) * CELL_SIZE);

    EntityManager.registerEntity(id, this);
  }

  public function setVelocity(newVelX, newVelY) {
    velocityX = newVelX;
    velocityY = newVelY;
  }

  public function calculationUpdate(dt: Float) {
    if (staticEntity) return;
    cellRatioX += velocityX * dt;
    if (Math.abs(velocityX) > 0.000005) {
      velocityX *= Math.pow(FRICTION, dt);
    }
    if(cellRatioX >= 0.7 && hasCollision(cellX+1,cellY)) {
      cellRatioX = 0.7;
      velocityX = 0;
    }
    if(cellRatioX <= 0.3 && hasCollision(cellX-1,cellY)) {
      cellRatioX = 0.3;
      velocityX = 0;
    }
    while(cellRatioX > 0) {
      cellRatioX -= 1;
      cellX += 1;
    }
    while(cellRatioX < 0 ) {
      cellRatioX += 1;
      cellX -= 1;
    }

    cellRatioY += velocityY * dt;
    if (Math.abs(velocityY) > 0.005) {
      velocityY *= Math.pow(FRICTION, dt);
    }
    if(cellRatioY >= 0.7 && hasCollision(cellX, cellY + 1)) {
      cellRatioY = 0.7;
      velocityY = 0;
    }
    if(cellRatioY <= 0.3 && hasCollision(cellX, cellY - 1)) {
      cellRatioY = 0.3;
      velocityY = 0;
    }
    while(cellRatioY > 0) {
      cellRatioY -= 1;
      cellY += 1;
    }
    while(cellRatioY < 0 ) {
      cellRatioY += 1;
      cellY -= 1;
    }

    x = Std.int((cellX + cellRatioX) * CELL_SIZE);
    y = Std.int((cellY + cellRatioY) * CELL_SIZE);
  }

  public function update(dt: Float) {
    onUpdate(dt);

    if (staticEntity) return;

    sprite.x = x + spriteOffset.x;
    sprite.y = y + spriteOffset.y;
  }

  public function hasCollision(xToCheck: Int, yToCheck: Int) {
    if (Grid.isWallAt(xToCheck, yToCheck)) {
      return true;
    }
    for (entity in EntityManager.entities) {
      if (entity.cellX == xToCheck && entity.cellY == yToCheck) {
        return true;
      }
    }
    return false;
  }

  public function addOnUpdate(handler: (dt: Float) -> Void) {
    onUpdate = handler;
  }
}