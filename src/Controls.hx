import luxe.Input;
import lib.MacroUtils;
import haxe.Json;
import snow.types.Types;

class Controls {
  public static inline var KEYBOARD = 0;
  public static inline var GAMEPAD=1;

  public static var default_controls = [
    'keyboard'=>[
      'type'=>KEYBOARD,
      'up'=>Key.key_w,
      'down'=>Key.key_s,
      'left'=>Key.key_a,
      'right'=>Key.key_d,
      'a'=>Key.key_z,
      'b'=>Key.key_x,
      'x'=>Key.key_c,
      'y'=>Key.key_v,
      'lb'=>Key.key_q,
      'rb'=>Key.key_e,
      'back'=>Key.backspace,
      'home'=>Key.escape,
      'start'=>Key.enter,
      'l_press'=>Key.key_1,
      'r_press'=>Key.key_2
    ],

    '360'=>[
      'type'=>GAMEPAD,
      'up'=>11,
      'down'=>12,
      'left'=>13,
      'right'=>14,
      'a'=>0,
      'b'=>1,
      'x'=>2,
      'y'=>3,
      'lb'=>9,
      'rb'=>10,
      'back'=>4,
      'home'=>5,
      'start'=>6,
      'l_press'=>7,
      'r_press'=>8
    ]
  ];

  public static var control_names = [
    '360' => [
      11 => 'UP',
      12 => 'DOWN',
      13 => 'LEFT',
      14 => 'RIGHT',
      0 => 'A',
      1 => 'B',
      2 => 'X',
      3 => 'Y',
      9 => 'LB',
      10 => 'RB',
      4 => 'back',
      5 => 'home',
      6 => 'start',
      7 => 'l_press',
      8 => 'r_press'
    ]
  ];

  static var _connected_gamepads = 0;

  public static function connected_gamepads() {
    return Std.int(_connected_gamepads / 2);
  }

  // It seems this information in unreliable.
  // The removed ids do not relate to the added ids - and sometimes
  // different connections result in the same added id.
  // For now, just use the count

  // There's also a bug where device added gets called once and device removed
  // gets called twice

  // This should all be fixed but for now we work around it...
  public static function device_added(event: GamepadEvent) {
    Main.debug("Device " + event.gamepad + " (" + event.device_id + ") added.");
    _connected_gamepads += 2;
  }

  public static function device_removed(event: GamepadEvent) {
    Main.debug("Device " + event.gamepad + " removed. Device " + event.device_id);
    _connected_gamepads -= 1;
  }

  public static function get_ordered_controls() {
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls;
    return ctrls;
  }

  public static function load_configuration(controller_id: Int) {
    var controls_str = Luxe.core.app.io.string_load("controls");
    if (controls_str == null) {
      return null;
    }
    return Json.parse(controls_str)[controller_id];
  }

  public static function save_configuration(controls: Array<Map<String, Int>>) {
    Main.debug("Saving controls.");
    Main.debug(Json.stringify(controls, null, " "));
    Luxe.core.app.io.string_save("controls", Json.stringify(controls));
    connect_input();
  }

  public static function save_controller_configuration(controller_id: Int, config: Map<String, Int>) {
    var controls_str = Luxe.core.app.io.string_load("controls");
    var controls = Json.parse(controls_str);
    controls[controller_id] = config;
    save_configuration(controls);
  }

  private static function generate_gamepad_controls(gamepad_id: Int) {
    var controls = new Map<String, Int>();
    // TODO, support other controller types
    for (k in default_controls.get("360").keys()) {
      controls.set(k, default_controls.get("360").get(k));
    }
    controls.set("gamepad_id", gamepad_id);
    return controls;
  }

  public static function set_default_keyboard_controls() {
    Main.debug("Setting default keypad controls.");
    var controls = new Array<Map<String, Int>>();
    controls.push(default_controls.get("keyboard"));
    for (i in 0...(Std.parseInt(MacroUtils.getDefinedValue("CONTROLLERS", "0")) - 1)) {
      controls.push(generate_gamepad_controls(i));
    }
    save_configuration(controls);
    connect_input();
  }

  public static function set_default_gamepad_controls() {
    Main.debug("Setting default gamepad controls.");
    var controls = new Array<Map<String, Int>>();
    for (i in 0...Std.parseInt(MacroUtils.getDefinedValue("CONTROLLERS", "0"))) {
      controls.push(generate_gamepad_controls(i));
    }
    save_configuration(controls);
    connect_input();
  }

  static function connect_keyboard_input(i: Int, control: Map<String, Int>) {
    for (k in actions_map.keys()) {
      Luxe.input.bind_key(i + '.' + k, control.get(actions_map.get(k)));
    }
  }

  static function connect_gamepad_input(i: Int, control: Map<String, Int>) {
    var gamepad_id = control.get("gamepad_id");
    for (k in actions_map.keys()) {
      Luxe.input.bind_gamepad(i + '.' + k, control.get(actions_map.get(k)), gamepad_id);
    }
  }

  public static function connect_input() {
    var controls_str = Luxe.core.app.io.string_load("controls");
    var controls: Array<Map<String, Int>> = Json.parse(controls_str);

    Luxe.input.key_bindings = new Map();
    Luxe.input.gamepad_bindings = new Map();

    for (i in 0...controls.length) {
      if (controls[i] != null) {
        if (controls[i].get("type") == KEYBOARD) {
          connect_keyboard_input(i + 1, controls[i]);
        } else if (controls[i].get("type") == GAMEPAD) {
          connect_gamepad_input(i + 1, controls[i]);
        }
      }
    }
  }

  public static var actions_map = new Map<String, String>();

  public static function get_button_for_action(action:String) {
    return actions_map.get(action);
  }

  public static function init() {
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls;
    for (c in ctrls) {
      actions_map.set(c[0], c[1]);
    }
  }
}
