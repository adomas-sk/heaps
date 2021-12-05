package helpers;

import h3d.Vector;
import h2d.Object;

class Helpers {
	public static function getDistanceBetweenObjects(a:Object, b:Object) {
		var aVec = new Vector(a.x, a.y);
		var bVec = new Vector(b.x, b.y);
		return aVec.distance(bVec);
	}

	public static function getDistanceBetweenObjectAndVector(o:Object, v:Vector) {
		var oVec = new Vector(o.x, o.y);
		return oVec.distance(v);
	}

	public static function getDirectionToObject(from:Object, to:Object) {
		var fromVec = new Vector(from.x, from.y);
		var toVec = new Vector(to.x, to.y);
		return toVec.sub(fromVec).normalized();
	}
}
