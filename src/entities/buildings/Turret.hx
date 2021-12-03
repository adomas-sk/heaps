package entities.buildings;

import hxd.Res;
import helpers.BuildingTypes.BuildFunctionReturn;
import helpers.Helpers;
import h3d.Vector;
import common.Killables;
import Main.LayerIndexes;
import h2d.Anim;
import common.WorldGrid.Position;
import helpers.Animation;
import h2d.Object;

enum abstract TurretAnimations(Int) to Int {
	var IDLE_L;
	var IDLE_R;
	var FIRING_L;
	var FIRING_R;
}

enum Side {
	Left;
	Right;
}

class TurretAnimation extends Animation<TurretAnimations> {
	public static inline var SPRITE_SIZE = 32;

	override public function getAnimations() {
		var image = hxd.Res.turret.turret.toTile();

		animations[TurretAnimations.IDLE_R] =   [for (x in 0...14) spritePreProcess(image, x * SPRITE_SIZE,           0, SPRITE_SIZE)];
		animations[TurretAnimations.IDLE_L] =   [for (x in 0...14) spritePreProcess(image, x * SPRITE_SIZE,           0, SPRITE_SIZE, { flipX: true })];
		animations[TurretAnimations.FIRING_R] = [for (x in 0...5)  spritePreProcess(image, x * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)];
		animations[TurretAnimations.FIRING_L] = [for (x in 0...5)  spritePreProcess(image, x * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE, { flipX: true })];
	}
}

enum TurretActions {
	IDLE;
	FIRING;
}

class Turret extends Object implements IKillable {
	static var REACH = 200;
	static var FIRE_SPEED = 0.1;
	static var DAMAGE = 5;

	var animationLoader:Animation<TurretAnimations>;
	var animation:Anim;
	var action: TurretActions = TurretActions.IDLE;
	var side:Side = Side.Right;

	var shotSound: hxd.res.Sound;

	var trackingTarget: Null<IKillable>;

	public var health = 10;

	public function new(position: Position) {
		super(Main.scene);
		Main.layers.add(this, LayerIndexes.ON_GROUND);
		shotSound = Res.turret.shot;

		animationLoader = new TurretAnimation(TurretAnimation.SPRITE_SIZE);
		animation = new Anim(animationLoader.animations[TurretAnimations.IDLE_R], 8, this);
		animation.onAnimEnd = () -> {
			if (action == TurretActions.FIRING) {
				shotSound.play(false, 0.3);
				trackingTarget.onDamage(DAMAGE);
			}
		};
		animation.pause = true;
		animation.alpha = 0.5;

		x = position.x;
		y = position.y;
		Killables.registerKillable(this, KillablesTag.TURRET);
	}

	public function update(dt) {
		if (!animation.pause) {
			switch(action) {
				case TurretActions.IDLE: {
					var target = getTarget();
					if (target != null) {
						{
							var target: Dynamic = target;
							var direction = Helpers.getDirectionToObject(this, target);
							if (direction.x > 0 && side != Side.Right) {
								side = Side.Right;
							} else if (direction.x < 0 && side != Side.Left) {
								side = Side.Left;
							}
						}
						action = TurretActions.FIRING;
						animation.play(animationLoader.animations[side == Side.Right ? TurretAnimations.FIRING_R : TurretAnimations.FIRING_L]);
						trackingTarget = target;
					}
				}
				case TurretActions.FIRING: {
					var distance = Helpers.getDistanceBetweenObjectAndVector(this, trackingTarget.getPosition());
					if (distance > REACH || trackingTarget.health <= 0) {
						action = TurretActions.IDLE;
						animation.play(animationLoader.animations[side == Side.Right ? TurretAnimations.IDLE_R : TurretAnimations.IDLE_L]);
						trackingTarget = null;
					}
				}
			}
		}
	}

	function getTarget(): Null<IKillable> {
		var target: Dynamic = Killables.getClosestKillable(new Vector(x, y), KillablesTag.ENEMY);
		if (target == null) {
			return null;
		}
		var distance = Helpers.getDistanceBetweenObjects(this, target);
		if (distance > REACH) {
			return null;
		}
		return target;
	}

	
	function onBuild() {
		animation.alpha = 1;
		animation.pause = false;
	}

	public static function build(position:Position):BuildFunctionReturn {
		var object = new Turret(position);
		return {
			object: object,
			onBuild: object.onBuild,
		};
	}

	public function getPosition() {
		return new Vector(x, y);
	}

	// TODO: handle damage and death
	public function onDamage(damage: Int) {
		trace("TURRET GETTING DAMAGED: " + damage);
	}
}
