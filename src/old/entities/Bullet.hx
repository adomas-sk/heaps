package old.entities;

import old.common.Entity;

class Bullet {
  static var bulletCount = 0;
  var scene: h2d.Scene;
  var entity: Entity;

  public static inline var SPEED = 32.;

  public function new(startX: Int, startY: Int, directionX: Float, directionY: Float, initScene: h2d.Scene) {
    bulletCount += 1;
    scene = initScene;

    var bulletImage = hxd.Res.projectiles.bullet.toTile();
    var bitmap = new h2d.Bitmap(bulletImage, initScene);
    
    var direction = new h3d.Vector(directionX - startX - initScene.width/2, directionY - startY - initScene.height/2).normalized();
    bitmap.rotation = Math.atan2(direction.y, direction.x);
    entity = new Entity("bullet" + bulletCount, startX, startY, bitmap);
    entity.addOnUpdate(onUpdate(direction));
  }

  public function onUpdate(direction: h3d.Vector) {
    direction.scale(SPEED);
    return (dt) -> {
      entity.setVelocity(direction.x, direction.y);
    }
  }
}
