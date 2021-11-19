package entities;

import Main.LayerIndexes;
import common.Animation;
import common.DroneScheduler;
import common.DroneScheduler.DroneOrder;
import h3d.Vector;
import h2d.Anim;
import h2d.Object;

enum abstract DroneAnimations(Int) to Int {
	var COMING_OUT;
	var COMING_IN;
	var TRAVEL_EMPTY;
	var TRAVEL_CARRY;
}

class DroneAnimation extends Animation<DroneAnimations> {
	public static inline var SPRITE_SIZE = 32;

	override public function getAnimations() {
		var image = hxd.Res.drone.drone.toTile();

		animations[DroneAnimations.COMING_IN] = [for (x in 0...5) spritePreProcess(image, x * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[DroneAnimations.COMING_OUT] = [for (x in 0...5) spritePreProcess(image, (5 - x) * SPRITE_SIZE, 0, SPRITE_SIZE)];
		animations[DroneAnimations.TRAVEL_CARRY] = [
			for (x in 0...4) spritePreProcess(image, x * SPRITE_SIZE, SPRITE_SIZE, SPRITE_SIZE)
		];
		animations[DroneAnimations.TRAVEL_EMPTY] = [
			for (x in 0...4) spritePreProcess(image, x * SPRITE_SIZE, 2 * SPRITE_SIZE, SPRITE_SIZE)
		];
	}
}

enum DroneActions {
	IDLE;
	COMING_OUT;
	DELIVERING;
	COMING_BACK;
	COMING_IN;
}

class Drone extends Object {
	static inline var SPEED = 100;
	static inline var Y_OFFSET_FROM_SOURCE = 32;

	var animationLoader:Animation<DroneAnimations>;
	var animation:Anim;
	var action:DroneActions;

	var currentOrder:Null<DroneOrder>;
	var source:Object;

	public function new(source:Object) {
		super(Main.scene);
		Main.layers.add(this, LayerIndexes.ON_GROUND);
		this.source = source;
		x = 0;
		y = 0;
		action = DroneActions.IDLE;

		animationLoader = new DroneAnimation(DroneAnimation.SPRITE_SIZE);
		animation = new Anim(animationLoader.animations[DroneAnimations.COMING_OUT], 10, this);
		// new h2d.Bitmap(h2d.Tile.fromColor(0xFF0000, 10, 10, 1), this);
		animation.visible = false;
		animation.pause = true;
		animation.onAnimEnd = () -> {
			switch (action) {
				case DroneActions.COMING_OUT: {
						action = DroneActions.DELIVERING;
						animation.play(animationLoader.animations[DroneAnimations.TRAVEL_CARRY]);
					}
				case DroneActions.DELIVERING:
				case DroneActions.COMING_BACK:
					return;
				case DroneActions.COMING_IN: {
						currentOrder = null;
						action = DroneActions.IDLE;
						animation.play(animationLoader.animations[DroneAnimations.COMING_OUT]);
						animation.visible = false;
						animation.pause = true;
					}
				case DroneActions.IDLE:
					throw new haxe.Exception("Drone: animation ended in IDLE");
			}
		};
	}

	public function update(dt:Float) {
		switch (action) {
			case DroneActions.COMING_OUT:
				{
					x = source.x;
					y = source.y - Y_OFFSET_FROM_SOURCE;
				}
			case DroneActions.DELIVERING:
				{
					deliver(dt);
				}
			case DroneActions.COMING_BACK:
				{
					comeBack(dt);
				}
			case DroneActions.COMING_IN:
				{
					x = source.x;
					y = source.y - Y_OFFSET_FROM_SOURCE;
				}
			case DroneActions.IDLE:
				return;
		}
	}

	public function order(order:DroneOrder) {
		currentOrder = order;
		if (action == DroneActions.COMING_IN) {
			animation.play(animationLoader.animations[DroneAnimations.COMING_OUT]);
		}
		action = DroneActions.COMING_OUT;
		animation.visible = true;
		animation.pause = false;
	}

	function deliver(dt:Float) {
		var difference = currentOrder.location.sub(new Vector(x, y));
		if (difference.length() < 5) {
			currentOrder.callBack();
			animation.play(animationLoader.animations[DroneAnimations.TRAVEL_EMPTY]);
			action = DroneActions.COMING_BACK;
			return;
		}
		var velocity = difference.normalized().multiply(SPEED * dt);
		x += velocity.x;
		y += velocity.y;
	}

	function comeBack(dt:Float) {
		var sourceDestination = new Vector(source.x, source.y - Y_OFFSET_FROM_SOURCE);
		var difference = sourceDestination.sub(new Vector(x, y));
		if (difference.length() < 5) {
			var anotherOrderAdded = DroneScheduler.announceAboutOrderCompletion(this);
			if (anotherOrderAdded) {
				action = DroneActions.DELIVERING;
				animation.play(animationLoader.animations[DroneAnimations.TRAVEL_CARRY]);
				return;
			}
			animation.play(animationLoader.animations[DroneAnimations.COMING_IN]);
			action = DroneActions.COMING_IN;
			return;
		}
		var velocity = difference.normalized().multiply(SPEED * dt);
		x += velocity.x;
		y += velocity.y;
	}
}
