package common;

import h2d.Text;
import entities.Drone;
import h3d.Vector;

enum DroneOrderTypes {
  DELIVER;
}

typedef DroneOrder= {
  var location: Vector;
  var type: DroneOrderTypes;
  var ?callBack: () -> Void;
}

class DroneScheduler {
  static var orderQueue: Array<DroneOrder> = [];
  static var freeDrones: Array<Drone> = [];
  static var workingDrones: Array<Drone> = [];
  static var droneCount: Text;

  public static function init() {
    var font : h2d.Font = hxd.res.DefaultFont.get();
    droneCount = new Text(font, Main.girl);
    droneCount.text = "AAAAA";
    droneCount.x = -Main.scene.width / 2;
    droneCount.y = -Main.scene.height / 2 + 30;
  }

  public static function addDrone(drone: Drone) {
    freeDrones.push(drone);
    updateText();
  }

  public static function addOrder(order: DroneOrder) {
    orderQueue.unshift(order);
    startExecutingOrder();
    updateText();
  }

  public static function announceAboutOrderCompletion(drone: Drone) {
    if (orderQueue.length == 0) {
      workingDrones.remove(drone);
      freeDrones.push(drone);
      updateText();
      return false;
    }
    var nextOrder = orderQueue.pop();
    drone.order(nextOrder);
    updateText();
    return true;
  }

  static function startExecutingOrder() {
    if (freeDrones.length == 0) {
      return;
    }
    var nextOrder = orderQueue.pop();
    var nextDrone = freeDrones.pop();

    workingDrones.push(nextDrone);
    nextDrone.order(nextOrder);
    updateText(); 
  }

  public static function updateDrones(dt: Float) {
    for (drone in workingDrones) {
      drone.update(dt);
    }
    for (drone in freeDrones) {
      drone.update(dt);
    }
  }

  static function updateText() {
    droneCount.text =
      "Free: " + freeDrones.length +
      "\nWorking: " + workingDrones.length +
      "\nOrders: " + orderQueue.length;
  }
}
