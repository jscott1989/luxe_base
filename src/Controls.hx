import luxe.Input;
import haxe.Json;
import snow.types.Types;
import haxe.Timer;

/**
 * This represents a single configuration of a single controller.
 */
class ControlConfiguration {
  // can be Controls.KEYBOARD or Controls.GAMEPAD
  var type:Int;
  // 0 if keyboard, otherwise the id of the gamepad
  var gamepad_id:Int;
  // Digital buttons
  var digital = new Map<String, Int>();
  // Analogue controls. This is Dynamic as keyboards need multiple buttons
  // for one control
  var analogue = new Map<String, Dynamic>();

  /**
   * Load all controls from file and return an array.
   */
  public static function load() {
    var controls_str = Luxe.core.app.io.string_load("controls");
    var controls_parsed:Array<Map<String,Dynamic>> = Json.parse(controls_str);
    var c = new Array<ControlConfiguration>();
    for (i in 0...controls_parsed.length) {
      c.push(ControlConfiguration.fromJSON(controls_parsed[i]));
    }
    return c;
  }

  /**
   * Create a new configuration.
   */
  public static function create(type, digital: Map<String, Int>, analogue: Map<String, Dynamic>, gamepad_id:Int = null) {
    var c = new ControlConfiguration(type);
    c.set_gamepad_id(gamepad_id);
    for (l in digital.keys()) {
      c.set_digital(l, digital[l]);
    }
    for (l in analogue.keys()) {
      c.set_analogue(l, analogue[l]);
    }
    return c;
  }

  /**
   * Create a configuration from an object loaded from JSON
   */
  public static function fromJSON(json: Dynamic) {
    var c = new ControlConfiguration(json.type);
    c.set_gamepad_id(json.gamepad_id);
    for (i in Reflect.fields(json.digital)) {
      c.set_digital(i, Reflect.field(json.digital, i));
    }
    for (i in Reflect.fields(json.analogue)) {
      c.set_analogue(i, Reflect.field(json.analogue, i));
    }
    return c;
  }

  public function new(type:Int) {
    this.type = type;
  }

  /**
   * Create a copy of this configuration.
   */
  public function clone() {
    return create(type, digital, analogue);
  }

  public function digital_keys() {
    return digital.keys();
  }

  public function set_digital(key:String, value:Int) {
    digital[key] = value;
  }

  public function get_digital(key:String) {
    return digital[key];
  }

  public function analogue_keys() {
    return analogue.keys();
  }

  public function set_analogue(key:String, value:Dynamic) {
    analogue[key] = value;
  }

  public function get_analogue(key:String) {
    return analogue[key];
  }

  public function set_gamepad_id(gamepad_id:Int) {
    this.gamepad_id = gamepad_id;
  }

  public function get_gamepad_id() {
    return gamepad_id;
  }

  public function set_type(type:Int) {
    this.type = type;
  }

  public function get_type() {
    return type;
  }
}

/**
 * Controls abstracts away all controller configuration.
 *
 * Use this instead of Luxe controller options and you get keyboard +
 * gamepad equivilence, and controller configuration.
 */
class Controls {

  // Controllers are either keyboards or gamepads
  public static inline var KEYBOARD = 0;
  public static inline var GAMEPAD=1;

  // The default configurations for different controller types
  public static var default_controls = [
    'keyboard'=> ControlConfiguration.create(
      KEYBOARD,
      [
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
      [
        'left_analogue_stick_x'=> [Key.key_a, Key.key_d],
        'left_analogue_stick_y'=> [Key.key_w, Key.key_s],
        'right_analogue_stick_x'=> [Key.key_j, Key.key_l],
        'right_analogue_stick_y'=> [Key.key_i, Key.key_k],
        'left_trigger'=> [Key.key_1, Key.key_2],
        'right_trigger'=> [Key.key_3, Key.key_4]
      ]
    ),
    '360'=> ControlConfiguration.create(
      GAMEPAD,
      [
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
        'r_press'=>8,
      ],
      [
        'left_analogue_stick_x'=> 0,
        'left_analogue_stick_y'=> 1,
        'right_analogue_stick_x'=> 2,
        'right_analogue_stick_y'=> 3,
        'left_trigger'=> 4,
        'right_trigger'=> 5,
      ]
    )
  ];

  // The mapping from button ID to name for some controller types
  public static var control_names = [
    '360' => [
      'digital' => [
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
      ],
      'analogue' => [
        0 => 'Left Analogue Stick X-Axis',
        1 => 'Left Analogue Stick Y-Axis',
        2 => 'Right Analogue Stick X-Axis',
        3 => 'Right Analogue Stick Y-Axis',
        4 => 'Left Trigger',
        5 => 'Right Trigger'
      ]
    ]
  ];

  // These are the currently active controls
  public static var controls = new Array<ControlConfiguration>();

  // Map the action names to the button mapping.
  public static var digital_map = new Map<String, String>();
  public static var analogue_map = new Map<String, Array<String>>();

  // Used for simulating analogue stick for keyboard
  static var analogue_simulation_values = new Map<Int, Map<String, Float>>();

  // This counts the number of connected gamepads.
  // it divides by two because of a bug where device added gets
  // called once and device removed gets called twice
  static var _connected_gamepads = 0;
  public static function connected_gamepads() {
    return Std.int(_connected_gamepads / 2);
  }

  // It seems this information in unreliable.
  // The removed ids do not relate to the added ids - and sometimes
  // different connections result in the same added id.
  // For now, just use the count

  // This should all be fixed but for now we work around it...
  public static function device_added(event: GamepadEvent) {
    trace("Device " + event.gamepad + " (" + event.device_id + ") added.");
    _connected_gamepads += 2;
  }

  public static function device_removed(event: GamepadEvent) {
    trace("Device " + event.gamepad + " removed. Device " + event.device_id);
    _connected_gamepads -= 1;
  }

  public static function get_menu_movement_controls() {
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls.menu.movement;
    return ctrls;
  }

  public static function get_menu_buttons() {
    return Luxe.core.app.config.user.controls.menu.buttons;
  }

  /**
   * Get an array of digital controls.
   * Each will be an array, with the first element the name of the control,
   * and the second the default mapping.
   */
  public static function get_ordered_digital_controls() {
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls.digital;
    return ctrls;
  }

  /**
   * Get an array of analogue controls.
   * Each will be an array, with the first element the name of the control,
   * the second the default mapping, and the third the type of simulation to
   * apply to keyboards (1button, 2button, or range).
   */
  public static function get_ordered_analogue_controls() {
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls.analogue;
    return ctrls;
  }

  /**
   * Save an array of controller configurations to file, and ensure that they
   * are active.
   */
  public static function save_configuration(controls: Array<ControlConfiguration>) {
    trace("Saving controls.");
    trace(Json.stringify(controls, null, " "));
    Luxe.core.app.io.string_save("controls", Json.stringify(controls));
    connect_input();
  }

  /**
   * Save a new configuration for a single controller, and make that
   * configuration active.
   */
  public static function save_controller_configuration(controller_id: Int, config: ControlConfiguration) {
    var controls_str = Luxe.core.app.io.string_load("controls");
    var controls = Json.parse(controls_str);
    controls[controller_id] = config;
    save_configuration(controls);
  }

  /**
   * Generate default controls for the brand and model of gamepad
   */
  private static function generate_gamepad_controls(gamepad_id: Int) {
    // TODO: Non-360 gamepads...
    var controls = default_controls.get("360").clone();
    controls.set_gamepad_id(gamepad_id);
    return controls;
  }

  /**
   * Set the first controller to use keyboard and others to use gamepads.
   */
  public static function set_default_keyboard_controls() {
    trace("Setting default keyboard controls.");
    var controls = new Array<ControlConfiguration>();
    controls.push(default_controls.get("keyboard").clone());
    for (i in 0...Std.int(Luxe.core.app.config.user.game.controllers - 1)) {
      controls.push(generate_gamepad_controls(i));
    }
    save_configuration(controls);
    connect_input();
  }

  /**
   * Set all controllers to default gamepad controls.
   */
  public static function set_default_gamepad_controls() {
    trace("Setting default gamepad controls.");
    var controls = new Array<ControlConfiguration>();
    for (i in 0...Luxe.core.app.config.user.game.controllers) {
      controls.push(generate_gamepad_controls(i));
    }
    save_configuration(controls);
    connect_input();
  }

  /**
   * Connect a controller to keyboard.
   */
  static function connect_keyboard_input(i: Int, control: ControlConfiguration) {
    for (k in digital_map.keys()) {
      Luxe.input.bind_key(i + '.' + k, control.get_digital(digital_map.get(k)));
    }

    analogue_simulation_values[i] = new Map<String, Float>();

    for (k in analogue_map.keys()) {
      switch (analogue_map[k][1]) {
        case "1button": Luxe.input.bind_key(i + '._' + k, control.get_analogue(analogue_map[k][0])[0]);
        case "2button": {
            Luxe.input.bind_key(i + '._' + k + '_minus', control.get_analogue(analogue_map[k][0])[0]);
            Luxe.input.bind_key(i + '._' + k + '_plus', control.get_analogue(analogue_map[k][0])[1]);
        }
        case _: {
          Luxe.input.bind_key(i + '._' + k + '_minus', control.get_analogue(analogue_map[k][0])[0]);
          Luxe.input.bind_key(i + '._' + k + '_plus', control.get_analogue(analogue_map[k][0])[1]);
          analogue_simulation_values[i][k] = 0.0;
        }
      }
    }
  }

  /**
   * Connect a controller to a gamepad.
   */
  static function connect_gamepad_input(i: Int, control: ControlConfiguration) {
    var gamepad_id = control.get_gamepad_id();
    for (k in digital_map.keys()) {
      Luxe.input.bind_gamepad(i + '.' + k, control.get_digital(digital_map.get(k)), gamepad_id);
    }
  }

  /**
   * Load and connect up input.
   */
  public static function connect_input() {
    controls = ControlConfiguration.load();

    // Clear existing bindings
    Luxe.input.key_bindings = new Map();
    Luxe.input.gamepad_bindings = new Map();
    analogue_simulation_values = new Map<Int, Map<String, Float>>();

    // Connect up each one
    for (i in 0...controls.length) {
      if (controls[i] != null) {
        if (controls[i].get_type() == KEYBOARD) {
          connect_keyboard_input(i + 1, controls[i]);
        } else if (controls[i].get_type() == GAMEPAD) {
          connect_gamepad_input(i + 1, controls[i]);
        }
      }
    }
  }

  /**
   * Initialise controls.
   */
  public static function init() {

    // Load controls into maps
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls.digital;
    for (c in ctrls) {
      digital_map.set(c[0], c[1]);
    }
    ctrls = cast Luxe.core.app.config.user.controls.analogue;
    for (c in ctrls) {
      analogue_map.set(c[0], [c[1], c[2]]);
    }

    // Set up an update callback
    Luxe.on(update, update_controls);
  }

  static function update_controls(elapsed:Float) {
    // Here we do the analogue simulation
    var SPEED = 3;
    var ctrls:Array<Array<String>> = cast Luxe.core.app.config.user.controls.analogue;
    for (i in 0...Luxe.core.app.config.user.game.controllers) {
      for (c in ctrls) {
        if (analogue_simulation_values.exists(i) && analogue_simulation_values[i].exists(c[0])) {
          if (Luxe.input.inputdown(i + "._" + c[0] + "_plus")) {
            analogue_simulation_values[i][c[0]] = Math.min(analogue_simulation_values[i][c[0]] + elapsed * SPEED, 1);
          } else if (Luxe.input.inputdown(i + "._" + c[0] + "_minus")) {
            analogue_simulation_values[i][c[0]] = Math.max(analogue_simulation_values[i][c[0]] - elapsed * SPEED, -1);
          } else if (analogue_simulation_values[i][c[0]] < -0.01 || analogue_simulation_values[i][c[0]] > 0.01) {
            analogue_simulation_values[i][c[0]] *= 0.9 * elapsed;
          }
        }
      }
    }
  }

  /**
   * Is a digital input pressed?
   */
  public static function inputdown(controller_id: Int, action:String) {
    return Luxe.input.inputdown(controller_id + "." + action);
  }

  public static function throttleinputdown(timeout:Float,
                                           controller_id: Int, action:String) {
    return throttle("inputdown(" + controller_id + ", " + action + ")", timeout,
                    inputdown(controller_id, action));
  }

  /**
   * Get the position of an alagoue input
   * (typically the range is -1 to 1, or 0 to 1)
   */
  public static function analogueposition(controller_id: Int, name:String) {
    if (controls[controller_id - 1].get_type() == KEYBOARD) {
      switch (analogue_map.get(name)[1]) {
        case "1button": {
          if (Luxe.input.inputdown(controller_id + "._" + name)) {
            return 1.0;
          }
          return 0.0;
        }
        case "2button": {
          if (Luxe.input.inputdown(controller_id + "._" + name + "_plus")) {
            return 1.0;
          } else if (Luxe.input.inputdown(controller_id + "._" + name + "_minus")) {
            return -1.0;
          } else {
            return 0.0;
          }
        }
        case _: {
          return analogue_simulation_values[controller_id][name];
        }
      }
      return 0.0;
    }

    var gamepad_id = controls[controller_id - 1].get_gamepad_id();
    var n:Int = controls[controller_id - 1].get_analogue(analogue_map.get(name)[0]);

    return Luxe.core.app.input.gamepadaxis(gamepad_id, n);
  }

  private static var throttle_timeouts = new Map<String, Float>();

  /**
   * For a given key, this will only return true once every timeout seconds.
   */
  public static function throttle(key:String, timeout:Float, value:Bool) {
    if (value && !throttle_timeouts.exists(key)) {
      throttle_timeouts[key] = Timer.stamp() + timeout;
      return true;
    } else if (!value && throttle_timeouts.exists(key)) {
      throttle_timeouts.remove(key);
      return false;
    } else if (value && throttle_timeouts.exists(key) && Timer.stamp() >= throttle_timeouts[key]) {
      throttle_timeouts[key] = Timer.stamp() + timeout;
      return true;
    }
    return false;
  }
}
