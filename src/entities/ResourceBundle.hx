package entities;

import h2d.Object;
import h2d.Bitmap;
import common.UniformPoissonDiskSampler;
import h3d.Vector;

typedef IResource = {
	var x:Float;
	var y:Float;
	var bitmap:Bitmap;
}

class ResourceBundle {
	static inline var RESOURCE_SIZE = 4;

	public var x:Float;
	public var y:Float;
	public var position:Vector;
	public var size:Float;
	public var density:Float;

	public var resources:Array<IResource> = [];

	public function new(initX:Float, initY:Float, initSize:Float, initDensity:Float, parent:Object) {
		x = initX;
		y = initY;
		position = new Vector(x, y);
		size = initSize;
		density = initDensity;

		var resourcePoints = UniformPoissonDiskSampler.sampleCircle(new Vector2(position.x, position.y), size, density);
		for (point in resourcePoints) {
			var resource = new Bitmap(h2d.Tile.fromColor(0x88FF33, RESOURCE_SIZE, RESOURCE_SIZE, 1), parent);
			resource.tile.dx = RESOURCE_SIZE / 2;
			resource.tile.dy = RESOURCE_SIZE / 2;
			resource.x = point.x;
			resource.y = point.y;
			resources.push({x: point.x, y: point.y, bitmap: resource});
		}

		Resources.addResourceBundle(this);
	}

	public function removeResource(resource:IResource) {
		resource.bitmap.remove();
		resources.remove(resource);
		if (resources.length == 0) {
			Resources.removeResourceBundle(this);
		}
	}
}
