import states.*;
import luxe.GameConfig;
import luxe.Input;
import luxe.States;
import luxe.Vector;
import luxe.Camera;

class Main extends luxe.Game {
  public static var machine : States;

  override function config(config:luxe.GameConfig) {
    if(config.user.window != null) {
      if(config.user.window.width != null) {
        config.window.width = Std.int(config.user.window.width);
      }
      if(config.user.window.height != null) {
        config.window.height = Std.int(config.user.window.height);
      }
    }

    config.window.title = config.user.window.title;

    config.preload.textures.push({ id:'assets/logo.png' });

    return config;
  }

  override function ready() {

    // Set up screen size
    Luxe.camera.size = new Vector(960, 640);
    Luxe.camera.size_mode = SizeMode.fit;

    connect_input();
    machine = new States({ name:'statemachine' });

    // Set up game states
    machine.add(new MenuState('menu_state'));
    machine.add(new GameState('game_state'));

    Luxe.on(init, function(_) {
      machine.set('menu_state');
    });

  }

  function connect_input() {
    // Default keyboard configuration
    Luxe.input.bind_key('up', Key.up);
    Luxe.input.bind_key('up', Key.key_w);
    Luxe.input.bind_key('right', Key.right);
    Luxe.input.bind_key('right', Key.key_d);
    Luxe.input.bind_key('down', Key.down);
    Luxe.input.bind_key('down', Key.key_s);
    Luxe.input.bind_key('left', Key.left);
    Luxe.input.bind_key('left', Key.key_a);
    Luxe.input.bind_key('space', Key.space);
  }

}
