package common;

enum InputName {
  w;
  s;
  a;
  d;
  bslash;
  mouseL;
  mouseR;
  mouseMove;
  num0;
  num1;
  num2;
  num3;
  num4;
  num5;
  num6;
  num7;
  num8;
  num9;
}

class InputManager {
  static var keyCodeToLetter: haxe.ds.Map<Int, InputName> = [
    0 => InputName.mouseL,
    1 => InputName.mouseR,
    87 => InputName.w,
    83 => InputName.s,
    65 => InputName.a,
    68 => InputName.d,
    48 => InputName.num0,
    49 => InputName.num1,
    50 => InputName.num2,
    51 => InputName.num3,
    52 => InputName.num4,
    53 => InputName.num5,
    54 => InputName.num6,
    55 => InputName.num7,
    56 => InputName.num8,
    57 => InputName.num9,
    220 => InputName.bslash,
  ];
  static var keysDownEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, (repeat: Bool) -> Void>> = [
    InputName.mouseL => [],
    InputName.mouseR => [],
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
    InputName.num0 => [],
    InputName.num1 => [],
    InputName.num2 => [],
    InputName.num3 => [],
    InputName.num4 => [],
    InputName.num5 => [],
    InputName.num6 => [],
    InputName.num7 => [],
    InputName.num8 => [],
    InputName.num9 => [],
    InputName.bslash => [],
  ];
  static var keysUpEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, () -> Void>> = [
    InputName.mouseL => [],
    InputName.mouseR => [],
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
    InputName.num0 => [],
    InputName.num1 => [],
    InputName.num2 => [],
    InputName.num3 => [],
    InputName.num4 => [],
    InputName.num5 => [],
    InputName.num6 => [],
    InputName.num7 => [],
    InputName.num8 => [],
    InputName.num9 => [],
    InputName.bslash => [],
  ];
  static var changeEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, (event: hxd.Event) -> Void>> = [
    InputName.mouseMove => [],
  ];
  public static var keysPressed = [
    InputName.mouseL => false,
    InputName.mouseR => false,
    InputName.w => false,
    InputName.a => false,
    InputName.s => false,
    InputName.d => false,
    InputName.num0 => false,
    InputName.num1 => false,
    InputName.num2 => false,
    InputName.num3 => false,
    InputName.num4 => false,
    InputName.num5 => false,
    InputName.num6 => false,
    InputName.num7 => false,
    InputName.num8 => false,
    InputName.num9 => false,
    InputName.bslash => false,
  ];
  public static var mousePosition = { x: 0.0, y: 0.0 };

  public static function onEvent(event : hxd.Event) {
    switch(event.kind) {
      case EMove: {
        mousePosition.x = event.relX;
        mousePosition.y = event.relY;
        for (handler in changeEventHandlers[InputName.mouseMove]) {
          handler(event);
        }
      }
      case EPush: {
        var keyLetter = keyCodeToLetter[event.button];
        if (keysDownEventHandlers.exists(keyLetter)) {
          for (handler in keysDownEventHandlers[keyLetter]) {
            handler(keysPressed[keyLetter]);
          }
        }
        keysPressed[keyLetter] = true;
      }
      case ERelease: {
        var keyLetter = keyCodeToLetter[event.button];
        if (keysUpEventHandlers.exists(keyLetter)) {
          for (handler in keysUpEventHandlers[keyLetter]) {
            handler();
          }
        }
        keysPressed[keyLetter] = false;
      }
      case EKeyDown: {
        var keyLetter = keyCodeToLetter[event.keyCode];
        if (keysDownEventHandlers.exists(keyLetter)) {
          for (handler in keysDownEventHandlers[keyLetter]) {
            handler(keysPressed[keyLetter]);
          }
        }
        keysPressed[keyLetter] = true;
      }
      case EKeyUp: {
        var keyLetter = keyCodeToLetter[event.keyCode];
        if (keysUpEventHandlers.exists(keyLetter)) {
          for (handler in keysUpEventHandlers[keyLetter]) {
            handler();
          }
        }
        keysPressed[keyLetter] = false;
      }
      case _:
    }
  }

  public static function registerEventHandler(id: String, key: InputName, eventHandler: (repeat: Bool) -> Void) {
    keysDownEventHandlers[key][id] = eventHandler;
  }

  public static function registerReleaseEventHandler(id: String, key: InputName, eventHandler: () -> Void) {
    keysUpEventHandlers[key][id] = eventHandler;
  }

  public static function registerChangeEventHandler(id: String, key: InputName, eventHandler: (event: hxd.Event) -> Void) {
    changeEventHandlers[key][id] = eventHandler;
  }
}
