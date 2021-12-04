package common;

import haxe.ds.Map;
import h3d.Vector;

interface ITarget {
	public function getPosition(): Vector;
}

interface IHealth {
	public var health: Int;
	public function onDamage(damage: Int): Void;
}

interface IKillable extends IHealth extends ITarget {
	public function update(dt: Float): Void;
}

enum abstract KillablesTag(Int) to Int {
	var ENEMY;
	var TURRET;
	var PLAYER;
}

class Killables {
	static var killables:Map<KillablesTag, Array<IKillable>> = [
		KillablesTag.ENEMY => [],
		KillablesTag.TURRET => [],
		KillablesTag.PLAYER => [],
	];

	public static function registerKillable(killable: IKillable, tag: KillablesTag) {
		killables[tag].push(killable);
	}

	public static function announceDead(killable: IKillable) {
		for (tag in killables) {
			tag.remove(killable);
		}
	}

	public static function getClosestKillable(closestTo: Vector, tag: KillablesTag) {
		var closestKillable:Null<IKillable> = null;
		var closestDistance = Math.POSITIVE_INFINITY;
		for (killable in killables[tag]) {
			var distance = killable.getPosition().distance(closestTo);
			if (distance < closestDistance) {
				closestDistance = distance;
				closestKillable = killable;
			}
		}
		return closestKillable;
	}

	public static function update(dt: Float) {
		for (tag in killables) {
			for (i in tag) {
				i.update(dt);
			}
		}
	}
}

