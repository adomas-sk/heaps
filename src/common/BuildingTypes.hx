package common;

import entities.resources.Tree;
import entities.buildings.Drill;
import common.WorldGrid.Position;

enum Buildings {
	DRILL;
	TREE;
}

typedef BuildFunctionReturn = {
	object:h2d.Object,
	onBuild:() -> Void,
}

typedef BuildingConfig = {
	buildFunction:(position:Position) -> BuildFunctionReturn,
	buildIndicator:BuildIndicator,
}

var BuildingsMap:Map<Buildings, BuildingConfig> = [
	Buildings.DRILL => {
		buildFunction: (position:Position) -> Drill.build(position),
		buildIndicator: {w: 64, h: 64},
	},
	Buildings.TREE => {
		buildFunction: (position:Position) -> Tree.build(position),
		buildIndicator: {w: 32, h: 32},
	}
];

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
