package entities;

import common.Killables;
import common.Killables.IKillable;
import common.WorldGrid;
import helpers.Helpers;
import h3d.Vector;
import Main.LayerIndexes;
import h2d.Anim;
import common.WorldGrid.Position;
import helpers.Animation;
import h2d.Object;

enum abstract EnemyAnimations(Int) to Int {
	var IDLE;
	var WALKING;
	var ATTACKING;
}

enum EnemyActions {
	IDLE;
	FOLLOWING;
	ATTACKING;
	DYING;
}

// TODO: add actual sprites and death animation
class EnemyAnimation extends Animation<EnemyAnimations> {
	public static var SPRITE_SIZE = 32;

	override public function getAnimations() {
		animations[EnemyAnimations.IDLE] = [
			spritePreProcess(h2d.Tile.fromColor(0x0055dd, SPRITE_SIZE, SPRITE_SIZE), 0, 0, SPRITE_SIZE)
		];
		animations[EnemyAnimations.WALKING] = [
			spritePreProcess(h2d.Tile.fromColor(0x002299, SPRITE_SIZE, SPRITE_SIZE), 0, 0, SPRITE_SIZE)
		];
		animations[EnemyAnimations.ATTACKING] = [
			spritePreProcess(h2d.Tile.fromColor(0x992222, SPRITE_SIZE, SPRITE_SIZE), 0, 0, SPRITE_SIZE)
		];
	}
}

class Enemy extends Object implements IKillable {
	static inline var REACH = 100;
	static inline var SIGHT = 200;
	static inline var SPEED = 50;
	static inline var MAX_HEALTH = 1000;

	var animationLoader:Animation<EnemyAnimations>;
	var animation:Anim;

	var action:EnemyActions = EnemyActions.IDLE;
	var destination:Null<Position>;
	var following:Null<Object>;

	public var health = 1000;
	public var healthBar: h2d.Bitmap;

	public function new(position:Position) {
		super(Main.scene);
		this.x = position.x;
		this.y = position.y;

		animationLoader = new EnemyAnimation(EnemyAnimation.SPRITE_SIZE);
		animation = new Anim(animationLoader.animations[EnemyAnimations.IDLE], 1, this);
		new h2d.Bitmap(h2d.Tile.fromColor(0xff4589, 1, 1, 1), animation);

		healthBar = new h2d.Bitmap(h2d.Tile.fromColor(0xdd4565, 32, 4), animation);
		healthBar.y -= 16 + 8;
		healthBar.x -= 16;
		healthBar.height = 4;
		healthBar.width = 32;

		Main.layers.add(this, LayerIndexes.ON_GROUND);
		Killables.registerKillable(this, KillablesTag.ENEMY);
	}

	public function update(dt:Float) {
		switch (action) {
			case EnemyActions.IDLE:
				{
					var target = getTargets();
					if (target != null) {
						following = target;
						action = EnemyActions.FOLLOWING;
						animation.play(animationLoader.animations[EnemyAnimations.WALKING]);
					}
				}
			case EnemyActions.FOLLOWING:
				{
					var distance = Helpers.getDistanceBetweenObjects(following, this);
					if (distance > SIGHT) {
						action = EnemyActions.IDLE;
						animation.play(animationLoader.animations[EnemyAnimations.IDLE]);
						return;
					}
					if (distance < REACH) {
						action = EnemyActions.ATTACKING;
						animation.play(animationLoader.animations[EnemyAnimations.ATTACKING]);
						return;
					}
					var velocity = Helpers.getDirectionToObject(this, following).multiply(SPEED);
					var nextPos = WorldGrid.getNextPosition({x: x, y: y}, {x: velocity.x * dt, y: velocity.y * dt});
					x = nextPos.x;
					y = nextPos.y;
				}
			case EnemyActions.ATTACKING:
				{
					var distance = Helpers.getDistanceBetweenObjects(following, this);
					if (distance > REACH) {
						action = EnemyActions.FOLLOWING;
						animation.play(animationLoader.animations[EnemyAnimations.WALKING]);
						return;
					}
				}
			case EnemyActions.DYING:
				{
					return;
				}
		}
	}

	function getTargets() {
		var selfPosition = new Vector(x, y);
		var girl = new Vector(Main.girl.x, Main.girl.y);

		if (selfPosition.distance(girl) < SIGHT) {
			return Main.girl;
		}
		return null;
	}

	public function onDamage(damage:Int) {
		health -= damage;
		healthBar.width = 32 * (health / MAX_HEALTH);
		if (health <= 0) {
			onDeath();
		}
	}

	public function onDeath() {
		Killables.announceDead(this);
	}

	public function getPosition() {
		return new Vector(x, y);
	}
}