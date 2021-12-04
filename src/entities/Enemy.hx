package entities;

import shared.Health;
import hxd.Res;
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
	var IDLE_L;
	var IDLE_R;
	var WALKING_L;
	var WALKING_R;
	var ATTACKING_L;
	var ATTACKING_R;
}

enum EnemyActions {
	IDLE;
	FOLLOWING;
	ATTACKING;
}

class EnemyAnimation extends Animation<EnemyAnimations> {
	public static var SPRITE_SIZE = 32;

	override public function getAnimations() {
		var image = Res.enemy.enemy.toTile();
		animations[EnemyAnimations.IDLE_L] = [
			spritePreProcess(image,           0, 0, SPRITE_SIZE),
			spritePreProcess(image, SPRITE_SIZE, 0, SPRITE_SIZE),
		];
		animations[EnemyAnimations.IDLE_R] = [
			spritePreProcess(image,           0, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
		];
		animations[EnemyAnimations.WALKING_L] = [
			spritePreProcess(image, 5 * SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 6 * SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 7 * SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 8 * SPRITE_SIZE, 0, SPRITE_SIZE),
		];
		animations[EnemyAnimations.WALKING_R] = [
			spritePreProcess(image, 5 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 6 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 7 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 8 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
		];
		animations[EnemyAnimations.ATTACKING_L] = [
			spritePreProcess(image,     SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 2 * SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 3 * SPRITE_SIZE, 0, SPRITE_SIZE),
			spritePreProcess(image, 4 * SPRITE_SIZE, 0, SPRITE_SIZE),
		];
		animations[EnemyAnimations.ATTACKING_R] = [
			spritePreProcess(image,     SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 2 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 3 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
			spritePreProcess(image, 4 * SPRITE_SIZE, 0, SPRITE_SIZE, { flipX: true }),
		];
	}
}

class Enemy extends Object implements IKillable {
	static inline var REACH = 100;
	static inline var SIGHT = 200;
	static inline var SPEED = 50;
	static inline var MAX_HEALTH = 1000;
	static inline var DAMAGE = 10;

	var animationLoader:Animation<EnemyAnimations>;
	var animation:Anim;

	var action:EnemyActions = EnemyActions.IDLE;
	var destination:Null<Position>;
	var following:Null<Object>;

	public var health = 1000;
	public var healthBar: Health;

	var spit: hxd.res.Sound;
	var target: IKillable;

	public function new(position:Position) {
		super(Main.scene);
		this.x = position.x;
		this.y = position.y;

		spit = hxd.Res.enemy.spit;
		animationLoader = new EnemyAnimation(EnemyAnimation.SPRITE_SIZE);
		animation = new Anim(animationLoader.animations[EnemyAnimations.IDLE_L], 8, this);
		new h2d.Bitmap(h2d.Tile.fromColor(0xff4589, 1, 1, 1), animation);

		animation.onAnimEnd = () -> {
			if (action == EnemyActions.ATTACKING) {
				spit.play(false, 0.4);
				target.onDamage(DAMAGE);
			}
		};

		healthBar = new Health(this, {x: 16, y: -24});

		Main.layers.add(this, LayerIndexes.ON_GROUND);
		Killables.registerKillable(this, KillablesTag.ENEMY);
	}

	public function update(dt:Float) {
		switch (action) {
			case EnemyActions.IDLE:
				{
					var target: Dynamic = getTargets();
					if (target != null) {
						this.target = target;
						following = target;
						action = EnemyActions.FOLLOWING;
						animation.play(animationLoader.animations[EnemyAnimations.WALKING_L]);
					}
				}
			case EnemyActions.FOLLOWING:
				{
					var distance = Helpers.getDistanceBetweenObjects(following, this);
					if (distance > SIGHT) {
						action = EnemyActions.IDLE;
						animation.play(animationLoader.animations[EnemyAnimations.IDLE_L]);
						return;
					}
					if (distance < REACH) {
						action = EnemyActions.ATTACKING;
						animation.play(animationLoader.animations[EnemyAnimations.ATTACKING_L]);
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
					if (target.health <= 0) {
						action = EnemyActions.IDLE;
						animation.play(animationLoader.animations[EnemyAnimations.IDLE_L]);
					}
					if (distance > REACH) {
						action = EnemyActions.FOLLOWING;
						animation.play(animationLoader.animations[EnemyAnimations.WALKING_L]);
						return;
					}
				}
		}
	}

	function getTargets() {
		var target: Dynamic = Killables.getClosestKillable(new Vector(x, y), KillablesTag.PLAYER);
		if (target == null) {
			return null;
		}
		var distance = Helpers.getDistanceBetweenObjects(this, target);
		if (distance > SIGHT) {
			return null;
		}
		return target;
	}

	public function onDamage(damage:Int) {
		health -= damage;
		healthBar.setHealth(health / MAX_HEALTH);
		if (health <= 0) {
			onDeath();
		}
	}

	public function onDeath() {
		Killables.announceDead(this);
		this.remove();
	}

	public function getPosition() {
		return new Vector(x, y);
	}
}