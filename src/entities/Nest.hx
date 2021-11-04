package entities;

import h3d.Vector;
import h2d.Bitmap;

class Nest {
  static inline var DEPLOYMENT_TIMER = 1;
  static inline var HOUSE_SIZE = 32;

  public var position: Vector;

  var availableWorkers = 20;
  var workerDeploymentTimer = 0.;
  var workers: Array<Worker> = [];

  public function new(x: Float, y: Float) {
    var nest = new Bitmap(h2d.Tile.fromColor(0x88FF33, HOUSE_SIZE, HOUSE_SIZE, 1), Main.scene);
    position = new Vector(x, y);
    nest.tile.dx -= HOUSE_SIZE / 2;
    nest.tile.dy -= HOUSE_SIZE / 2;
    nest.x = x;
    nest.y = y;
  }

  public function update(dt: Float) {
    if (availableWorkers > 0 && workerDeploymentTimer < 0) {
      workers.push(
        new Worker(
          position.x,
          position.y,
          position
        )
      );
      availableWorkers -= 1;
      workerDeploymentTimer = DEPLOYMENT_TIMER;
    } else {
      workerDeploymentTimer -= dt;
    }
    for(worker in workers) {
      worker.update(dt);
    }
  }
}
