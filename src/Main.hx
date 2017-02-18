import states.*;
import luxe.GameConfig;
import luxe.Input;
import luxe.States;
import luxe.Vector;
import luxe.Camera;
import pgr.dconsole.DC;

class Main extends luxe.Game {
  public static var machine : States;

  public static var default_controls = [
    'up'=>11,
    'down'=>12,
    'left'=>13,
    'right'=>14,
    'A'=>0,
    'B'=>1,
    'X'=>2,
    'Y'=>3,
    'LB'=>9,
    'RB'=>10,
    'back'=>4,
    'home'=>5,
    'start'=>6,
    'l_press'=>7,
    'r_press'=>8
  ];

  override function config(config:luxe.GameConfig) {
    if(config.user.window != null) {
      if(config.user.window.width != null) {
        config.window.width = Std.int(config.user.window.width);
      }
      if(config.user.window.height != null) {
        config.window.height = Std.int(config.user.window.height);
      }
    }

    config.window.title = config.user.game.name;

    config.preload.textures.push({ id:'assets/logo.png' });

    return config;
  }

  public static function debug(str:String) {
    // #if debug
    DC.log(str);
    // #end
  }

  override function ready() {
    // #if debug
    DC.init();
    // #end

    // Set up screen size
    Luxe.camera.size = new Vector(Luxe.core.app.config.user.window.width,
                                  Luxe.core.app.config.user.window.height);
    Luxe.camera.size_mode = SizeMode.fit;

    connect_input();
    machine = new States({ name:'statemachine' });

    // Set up game states
    machine.add(new MenuState('menu_state'));
    machine.add(new GameState('game_state'));

    Luxe.on(init, function(_) {
      machine.set('game_state');
    });

  }

  function connect_input() {
    // Default keyboard configuration
    Luxe.input.bind_key('1.up', Key.up);
    Luxe.input.bind_key('1.up', Key.key_w);
    Luxe.input.bind_key('1.right', Key.right);
    Luxe.input.bind_key('1.right', Key.key_d);
    Luxe.input.bind_key('1.down', Key.down);
    Luxe.input.bind_key('1.down', Key.key_s);
    Luxe.input.bind_key('1.left', Key.left);
    Luxe.input.bind_key('1.left', Key.key_a);

    // XBox 360 configuration
    for (i in 0...4) {
      var p = i + 1;
      for (k in default_controls.keys()) {
        Luxe.input.bind_gamepad(p + '.' + k, default_controls.get(k), i);
      }
    }
  }

}
