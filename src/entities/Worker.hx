package entities;

import entities.ResourceBundle.IResource;
import h2d.Object;
import h2d.Anim;
import h3d.Vector;
import hxd.Math;
import h2d.Bitmap;

enum WorkerActions {
  GOING_TOWARD_RESOURCE_BUNDLE;
  GOING_TOWARD_RESOURCE;
  GOING_TOWARD_HOME;
}

enum AntAnimations {
  WALK;
  WALK_WITH_RESOURCE;
}

class AntAnimation {
  public static inline var SPRITE_SIZE = 128;

  public static var animations: haxe.ds.Map<AntAnimations, Array<h2d.Tile>> = [
    AntAnimations.WALK => [],
    AntAnimations.WALK_WITH_RESOURCE => [],
  ];
  static var animationsLoaded = false;

  public static function loadAnimation() {
    if (animationsLoaded) {
      return;
    }
    var antImage = hxd.Res.ant.toTile();

    animations[AntAnimations.WALK] = [for(x in 0 ... 2) spritePreProcess(antImage, x * SPRITE_SIZE, 0, SPRITE_SIZE)];
    animations[AntAnimations.WALK_WITH_RESOURCE] = [for(x in 0 ... 2) spritePreProcess(antImage, x * SPRITE_SIZE, 1 * SPRITE_SIZE, SPRITE_SIZE)];

    animationsLoaded = true;
  }

  static function spritePreProcess(image: h2d.Tile, x: Int, y: Int, size: Int) {
    var tile = image.sub(x, y, SPRITE_SIZE, SPRITE_SIZE);
    tile.scaleToSize(SPRITE_SIZE / 4, SPRITE_SIZE / 4);
    tile.dx -= SPRITE_SIZE / 8;
    tile.dy -= SPRITE_SIZE / 8;
    return tile;
  }
}

var workerCount = 0;
class Worker {
  static inline var SPEED = 30;
  static inline var TURNING_SPEED = 0.04;
  static inline var JITTER_ROTATION = 0.58;
  static inline var GRAB_DISTANCE = 6.0;

  var id: Int;
  var position: Vector;
  var direction: Vector;

  var workerObject: Object;
  var animation: Anim;

  var destination: Vector;
  var destinationResourceBundle: Null<ResourceBundle>;
  var determinedJitterRotation: Null<Float>;

  var currentAction: WorkerActions = WorkerActions.GOING_TOWARD_RESOURCE_BUNDLE;
  var actions: Map<WorkerActions, (dt: Float) -> Void> = [];

  var house: {x:Float, y:Float};

  public function new(
    x: Float,
    y: Float,
    houseInit: {x:Float, y:Float}
  ) {
    position = new Vector(x, y);
    direction = new Vector(0.5, -0.5);
    house = houseInit;
    id = workerCount;
    workerCount += 1;

    AntAnimation.loadAnimation();

    workerObject = new Object(Main.scene);
    workerObject.x = x;
    workerObject.y = y;

    animation = new h2d.Anim(AntAnimation.animations[AntAnimations.WALK], 2, workerObject);
    new Bitmap(h2d.Tile.fromColor(0xff0000, 2, 2, 1), animation);

    actions[WorkerActions.GOING_TOWARD_RESOURCE_BUNDLE] = goingTowardResourceBundle;
    actions[WorkerActions.GOING_TOWARD_RESOURCE] = goingTowardResource;
    actions[WorkerActions.GOING_TOWARD_HOME] = goingTowardHome;

    getDestinationToClosestResourceBundles();
    if (destination == null) {
      currentAction = WorkerActions.GOING_TOWARD_HOME;
      destination = new Vector(house.x, house.y);
    }
  }

  public function update(dt: Float) {
    actions[currentAction](dt);

    var directionToDestination = destination.sub(position);
    directionToDestination.normalize();
    var rotation = directionToDestination.multiply(TURNING_SPEED);

    var rotationMissing = direction.distance(directionToDestination);

    // GO IN A STRAIGHT LINE TO DESTINATION
    if (rotationMissing < 0.05) {
      direction = directionToDestination;
    // START JITTER IF DESTINATION IS BEHIND YOU
    } else if (rotationMissing > 1.95) {
      if (determinedJitterRotation == null) {
        var randomDirection = Math.random() < 0.5 ? 1 : -1;
        determinedJitterRotation = JITTER_ROTATION * randomDirection;
      }
      var jitterRotation = new Vector(
        direction.x * Math.cos(determinedJitterRotation) - direction.y * Math.sin(determinedJitterRotation),
        direction.x * Math.sin(determinedJitterRotation) + direction.y * Math.cos(determinedJitterRotation)
      )
      .normalized()
      .multiply(TURNING_SPEED);
      direction = direction.add(jitterRotation);
    // SLOWLY TURN TOWARDS DESTINATION
    } else {
      determinedJitterRotation = null;
      direction = direction.add(rotation);
    }
    direction.normalize();

    position.x += direction.x * SPEED * dt;
    position.y += direction.y * SPEED * dt;

    workerObject.rotation = Math.atan2(direction.y, direction.x);

    workerObject.x = position.x;
    workerObject.y = position.y;
  }

  function goingTowardResourceBundle(dt: Float) {
    if (destination.distance(position) < destinationResourceBundle.size + 10) {
      // GETTING CLOSE TO RESOURCE BUNDLE
      var closestDestination = getDestinationToClosestResource();
      if (closestDestination == null) {
        destination = new Vector(house.x, house.y);
        currentAction = WorkerActions.GOING_TOWARD_HOME;
      } else {
        currentAction = WorkerActions.GOING_TOWARD_RESOURCE;
      }
    }
  }

  function goingTowardResource(dt: Float) {
    var targetResource: Null<IResource> = null;
    for (resource in destinationResourceBundle.resources) {
      if (resource.x == destination.x && resource.y == destination.y) {
        targetResource = resource;
        break;
      }
    }
    if (targetResource == null) {
      var newDestination = getDestinationToClosestResource();
      if (newDestination == null) {
        currentAction = WorkerActions.GOING_TOWARD_HOME;
        destination = new Vector(house.x, house.y);
      } else {
        return;
      }
    }
    if (destination.distance(position) < GRAB_DISTANCE) {
      // GRABBING RESOURCE
      destinationResourceBundle.removeResource(targetResource);
      animation.play(AntAnimation.animations[AntAnimations.WALK_WITH_RESOURCE]);

      currentAction = WorkerActions.GOING_TOWARD_HOME;
      destination = new Vector(house.x, house.y);
    }
  }

  function goingTowardHome(dt: Float) {
    if (destination.distance(position) < GRAB_DISTANCE) {
      // GOT BACK HOME
      animation.play(AntAnimation.animations[AntAnimations.WALK]);

      getDestinationToClosestResourceBundles();
      currentAction = WorkerActions.GOING_TOWARD_RESOURCE_BUNDLE;
    }
  }

  function findClosestDestination<T: {x:Float,y:Float}>(listOfPosibleDestinations: Array<T>): Null<T> {
    var shortestPath = Math.POSITIVE_INFINITY;
    var destination = null;

    for(resourceBundle in listOfPosibleDestinations) {
      var resourceCenter = new Vector(resourceBundle.x, resourceBundle.y);
      var distance = position.distance(resourceCenter);
      if (distance < shortestPath) {
        shortestPath = distance;
        destination = resourceBundle;
      }
    }

    return destination;
  }

  function getDestinationToClosestResource() {
    var closestDestination = findClosestDestination(destinationResourceBundle.resources);
    if (closestDestination != null) {
      destination = new Vector(closestDestination.x, closestDestination.y);
    }
    return closestDestination;
  }

  function getDestinationToClosestResourceBundles() {
    var closestDestination = findClosestDestination(Resources.resources);
    if (closestDestination == null) {
      return;
    }
    destinationResourceBundle = closestDestination;
    destination = new Vector(closestDestination.x, closestDestination.y);
  }
}