package common;

class Entity {
  static public var CELL_SIZE = 16;

  public var sprite : h2d.Anim;

  public var cellX : Int;
  public var cellY : Int;
  public var cellRatioX : Float = 0.;
  public var cellRatioY : Float = 0.;

  public var x : Float;
  public var y : Float;

  public var velocityX : Float = 0;
  public var velocityY : Float = 0;

  var onUpdate: (dt: Float) -> Void;

  public function new(cellXInit, cellYInit, spriteInit) {
    sprite = spriteInit;

    cellX = cellXInit;
    cellY = cellYInit;

    x = Std.int((cellX + cellRatioX) * CELL_SIZE);
    y = Std.int((cellY + cellRatioY) * CELL_SIZE);
  }

  public function setVelocity(newVelX, newVelY) {
    velocityX = newVelX;
    velocityY = newVelY;
  }

  public function calculationUpdate(dt: Float) {
    cellRatioX += velocityX * dt;
    velocityX *= 0.96;
    if(hasCollision(cellX+1,cellY) && cellRatioX>=0.7 ) {
      cellRatioX = 0.7;
      velocityX = 0;
    }
    if(hasCollision(cellX-1,cellY) && cellRatioX<=0.3 ) {
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
    velocityY *= 0.96;
    if(hasCollision(cellY+1,cellY) && cellRatioY>=0.7 ) {
      cellRatioY = 0.7;
      velocityY = 0;
    }
    if(hasCollision(cellY-1,cellY) && cellRatioY<=0.3 ) {
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

    sprite.x = x;
    sprite.y = y;
  }

  public function hasCollision(xToCheck: Int, yToCheck: Int) {
    return false;
  }

  public function addOnUpdate(handler: (dt: Float) -> Void) {
    onUpdate = handler;
  }
}