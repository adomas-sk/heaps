package helpers;

import entities.buildings.Wall;
import h2d.Object;
import entities.buildings.Turret;
import entities.resources.Tree;
import entities.buildings.Drill;
import common.WorldGrid.Position;

enum Buildings {
	DRILL;
	TREE;
	TURRET;
	WALL;
}

typedef BuildFunctionReturn = {
	object:h2d.Object,
	onBuild:() -> Void,
}

typedef BuildingConfig = {
	buildFunction:(position:Position) -> BuildFunctionReturn,
	buildIndicator:BuildIndicator,
	name:String,
}

var BuildingsMap:Map<Buildings, BuildingConfig> = [
	Buildings.DRILL => {
		buildFunction: (position:Position) -> Drill.build(position),
		buildIndicator: {w: 64, h: 64},
		name: "DRILL",
	},
	Buildings.TREE => {
		buildFunction: (position:Position) -> Tree.build(position),
		buildIndicator: {w: 32, h: 32},
		name: "TREE",
	},
	Buildings.TURRET => {
		buildFunction: (position:Position) -> Turret.build(position),
		buildIndicator: {w: 32, h: 32},
		name: "TURRET",
	},
	Buildings.WALL => {
		buildFunction: (position:Position) -> Wall.build(position),
		buildIndicator: {w: 32, h: 32},
		name: "WALL",
	}
];

typedef BuildingInfo = {
	var building:Object;
	var name:String;
}

typedef BuildIndicator = {
	var h:Int;
	var w:Int;
}

typedef BuildIndicatorInfo = {
	var h:Int;
	var w:Int;
	var hOffset:Int;
	var wOffset:Int;
}
