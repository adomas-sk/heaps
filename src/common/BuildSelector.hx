package common;

class BuildSelector {
  public static function init() {
    var container = new SampleView(h2d.Tile.fromColor(0xFF,32,32), Main.scene);
    var style = new h2d.domkit.Style();
		style.load(hxd.Res.style);
		style.addObject(container);
  }
}

@:uiComp("view")
class SampleView extends h2d.Flow implements h2d.domkit.Object {
  static var SRC = 
      <view class="thing" min-width="200" min-height="200" layout="vertical"> 
        <text text={"Hello World"}/>
      </view>

  public function new(tile:h2d.Tile,?parent) {
      super(parent);
      initComponent();
  }
}
