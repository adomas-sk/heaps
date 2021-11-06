package common;

enum InputName {
  w;
  s;
  a;
  d;
  mouseL;
  mouseR;
  mouseMove;
}

class InputManager {
  static var keyCodeToLetter: haxe.ds.Map<Int, InputName> = [
    0 => InputName.mouseL,
    1 => InputName.mouseR,
    87 => InputName.w,
    83 => InputName.s,
    65 => InputName.a,
    68 => InputName.d,
  ];
  static var keysDownEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, (repeat: Bool) -> Void>> = [
    InputName.mouseL => [],
    InputName.mouseR => [],
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
  ];
  static var keysUpEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, () -> Void>> = [
    InputName.mouseL => [],
    InputName.mouseR => [],
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
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
