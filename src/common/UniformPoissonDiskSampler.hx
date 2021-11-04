package common;

import h3d.Vector;

class Vector2 implements IVector2 {
  public var x:Float;
  public var y:Float;

  public function new(xInit: Float, yInit: Float): Void {
    x = xInit;
    y = yInit;
  };

  public static function distance(p:IVector2, q:IVector2):Float {
    return new Vector(p.x, p.y).distance(new Vector(q.x, q.y));
  };
  public static function distanceSquared(p:IVector2, q:IVector2):Float {
    var dx = p.x - q.x;
    var dy = p.y - q.y;

    return dx*dx + dy*dy;
  };
}

/* 
 * Quick port to haxe of http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)
 * 
 * Which in turn is:
 * 
 * Adapted from java source by Herman Tulleken
 * http://www.luma.co.za/labs/2008/02/27/poisson-disk-sampling/
 * 
 * The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
 * http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
 * 
 */

 // typedef'd Vector2 must be _structurally compatible_ with this pseudo-interface
 interface IVector2 {
   var x:Float;
   var y:Float;
 }

 typedef	Settings = {
   var topLeft:Vector2;
   var bottomRight:Vector2;
   var center:Vector2;
   var dimensions:Vector2;
   var rejectionSqDistance:Null<Float>;
   var minimumDistance:Float;
   var cellSize:Float;
   var gridWidth:Int; 
   var gridHeight:Int;
 }
 
 typedef State = {
   var grid:Array<Array<Vector2>>; // NB: Grid[y][x]
   var activePoints:Array<Vector2>;
   var points:Array<Vector2>;
 }
 
 
 /**
  * ...
  * @author azrafe7
  */
class UniformPoissonDiskSampler {

  inline public static var DEFAULT_POINTS_PER_ITERATION:Int = 30;

  static var SQUARE_ROOT_TWO(default, never):Float = Math.sqrt(2);

  
  public static function sampleCircle(center:Vector2, radius:Float, minimumDistance:Float, ?pointsPerIteration:Int):Array<Vector2>
  {
    if (pointsPerIteration == null) pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;

    var topLeft = new Vector2(center.x - radius, center.y - radius);
    var bottomRight = new Vector2(center.x + radius, center.y + radius);
    return sample(topLeft, bottomRight, radius, minimumDistance, pointsPerIteration);
  }

  public static function sampleRectangle(topLeft:Vector2, bottomRight:Vector2, minimumDistance:Float, ?pointsPerIteration:Int):Array<Vector2>
  {
    if (pointsPerIteration == null) pointsPerIteration = DEFAULT_POINTS_PER_ITERATION;

    return sample(topLeft, bottomRight, null, minimumDistance, pointsPerIteration);
  }

  
  static function sample(topLeft:Vector2, bottomRight:Vector2, ?rejectionDistance:Float, minimumDistance:Float, pointsPerIteration:Int):Array<Vector2>
  {
    var dimensions = new Vector2(bottomRight.x - topLeft.x, bottomRight.y - topLeft.y);
    var cellSize = minimumDistance / SQUARE_ROOT_TWO;
    
    var settings:Settings = 
    {
      topLeft : topLeft, bottomRight : bottomRight,
      dimensions : dimensions,
      center : new Vector2((topLeft.x + bottomRight.x) / 2, (topLeft.y + bottomRight.y) / 2),
      cellSize : cellSize,
      minimumDistance : minimumDistance,
      rejectionSqDistance : rejectionDistance == null ? null : rejectionDistance * rejectionDistance,
      gridWidth : Std.int(dimensions.x / cellSize) + 1,
      gridHeight : Std.int(dimensions.y / cellSize) + 1,
    };

    var grid = new Array<Array<Vector2>>();
    for (y in 0...settings.gridHeight) {
      grid.push( [for (x in 0...settings.gridWidth) null] );
    }
    
    var state:State = 
    {
      activePoints : new Array<Vector2>(),
      points : new Array<Vector2>(),
      grid : grid,
    };

    addFirstPoint(settings, state);

    while (state.activePoints.length != 0)
    {
      var listIndex = RandomHelper.nextInt(state.activePoints.length);

      var point = state.activePoints[listIndex];
      var found = false;

      for (k in 0...pointsPerIteration)
        found = found || addNextPoint(point, settings, state);

      if (!found)
        state.activePoints.splice(listIndex, 1);
    }

    return state.points;
  }

  static function addFirstPoint(settings:Settings, state:State):Void
  {
    var added = false;
    while (!added)
    {
      var d = RandomHelper.nextFloat();
      var xr = settings.topLeft.x + settings.dimensions.x * d;

      d = RandomHelper.nextFloat();
      var yr = settings.topLeft.y + settings.dimensions.y * d;

      var p = new Vector2(xr, yr);
      if (settings.rejectionSqDistance != null && Vector2.distanceSquared(settings.center, p) > settings.rejectionSqDistance)
        continue;
      
      added = true;

      var index = denormalize(p, settings.topLeft, settings.cellSize);

      state.grid[Std.int(index.y)][Std.int(index.x)] = p;

      state.activePoints.push(p);
      state.points.push(p);
    } 
  }

  static function addNextPoint(point:Vector2, settings:Settings, state:State):Bool
  {
    var found = false;
    var q = generateRandomAround(point, settings.minimumDistance);

    if (q.x >= settings.topLeft.x && q.x < settings.bottomRight.x && 
      q.y > settings.topLeft.y && q.y < settings.bottomRight.y &&
      (settings.rejectionSqDistance == null || Vector2.distanceSquared(settings.center, q) <= settings.rejectionSqDistance))
    {
      var qIndex = denormalize(q, settings.topLeft, settings.cellSize);
      var tooClose = false;

      //for (var i = (int) Math.Max(0, qIndex.x - 2); i < Math.Min(settings.GridWidth, qIndex.x + 3) && !tooClose; i++)
      var i = Std.int(Math.max(0, qIndex.x - 2));
      while (i < Math.min(settings.gridWidth, qIndex.x + 3) && !tooClose)
      {
        //for (var j = (int) Math.Max(0, qIndex.y - 2); j < Math.Min(settings.GridHeight, qIndex.y + 3) && !tooClose; j++)
        var j = Std.int(Math.max(0, qIndex.y - 2));
        while (j < Math.min(settings.gridHeight, qIndex.y + 3) && !tooClose)
        {
          if (state.grid[j][i] != null && Vector2.distance(state.grid[j][i], q) < settings.minimumDistance) {
            tooClose = true;
          }
          j++;
        }
        i++;
      }

      if (!tooClose)
      {
        found = true;
        state.activePoints.push(q);
        state.points.push(q);
        state.grid[Std.int(qIndex.y)][Std.int(qIndex.x)] = q;
      }
    }
    return found;
  }

  static function generateRandomAround(center:Vector2, minimumDistance:Float):Vector2
  {
    var d = RandomHelper.nextFloat();
    var radius = minimumDistance + minimumDistance * d;

    d = RandomHelper.nextFloat();
    var angle = MathHelper.TWO_PI * d;

    var newX = radius * Math.sin(angle);
    var newY = radius * Math.cos(angle);

    return new Vector2((center.x + newX), (center.y + newY));
  }

  static function denormalize(point:Vector2, origin:Vector2, cellSize:Float):Vector2
  {
    return new Vector2(Std.int((point.x - origin.x) / cellSize), Std.int((point.y - origin.y) / cellSize));
  }
}

class RandomHelper
{
  public static function nextInt(upperBound:Int):Int {
    return Std.random(upperBound);
  }
  
  public static function nextFloat(upperBound:Float = 1.0):Float {
    return Math.random() * upperBound;
  }
}
  
class MathHelper
{
  public static var PI(default, never):Float = Math.PI;
  public static var HALF_PI(default, never):Float = (Math.PI / 2);
  public static var TWO_PI(default, never):Float = (Math.PI * 2);
}	