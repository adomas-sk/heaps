package common;

enum InputName {
  w;
  s;
  a;
  d;
}

class InputManager {
  static var keyCodeToLetter: haxe.ds.Map<Int, InputName> = [
    87 => InputName.w,
    83 => InputName.s,
    65 => InputName.a,
    68 => InputName.d,
  ];
  static var keysDownEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, (repeat: Bool) -> Void>> = [
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
  ];
  static var keysUpEventHandlers: haxe.ds.Map<InputName, haxe.ds.Map<String, () -> Void>> = [
    InputName.w => [],
    InputName.a => [],
    InputName.s => [],
    InputName.d => [],
  ];
  public static var keysPressed = [
    InputName.w => false,
    InputName.a => false,
    InputName.s => false,
    InputName.d => false,
  ];

  public static function onEvent(event : hxd.Event) {
    switch(event.kind) {
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
}
