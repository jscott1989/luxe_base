import states.*;
import luxe.GameConfig;
import luxe.States;
import luxe.Vector;
import luxe.Camera;
import pgr.dconsole.DC;
import haxe.Json;

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

    config.window.title = config.user.game.name;

    config.preload.textures.push({ id:'assets/logo.png' });

    return config;
  }

  public static function debug(data:Dynamic, color:Int = -1) {
    #if debug
    DC.log(data, color);
    #end
  }

  override function onevent(event:snow.types.Types.SystemEvent) {
    // The gamepad connected/disconnected messages get sent before Luxe is ready
    // so we intercept them here instead
    if(event.type == se_input && event.input != null && event.input.type == ie_gamepad) {
      if(event.input.gamepad.type == ge_device) {
        switch(event.input.gamepad.device_event) {
          case ge_device_added:       Controls.device_added(event.input.gamepad);
          case ge_device_removed:     Controls.device_removed(event.input.gamepad);
          case ge_device_remapped:    debug('remapped ${event.input.gamepad.device_id}');
          case _:
        }
      }
    }
  }

  override function ready() {
    #if debug
    DC.init();
    debug(Luxe.core.app.config.user.game.name + " starting.");
    #end

    // Set up screen size
    Luxe.camera.size = new Vector(Luxe.core.app.config.user.window.width,
                                  Luxe.core.app.config.user.window.height);
    Luxe.camera.size_mode = SizeMode.fit;

    machine = new States({ name:'statemachine' });

    // Set up game states
    machine.add(new MenuState('menu_state'));
    machine.add(new OptionsState('options_state'));
    machine.add(new InitialControlsState('initial_controls_state'));
    machine.add(new ControlsState('controls_state'));
    machine.add(new ConfigureControllerState('configure_controller_state'));
    machine.add(new GameState('game_state'));

    Luxe.on(init, function(_) {
      #if (CONTROLLERS>0)
      // We only care about configuration if we have controls
      var controls_str = Luxe.core.app.io.string_load("controls");

      if (controls_str == null) {
        Main.debug("No controls set.");

        if (Controls.connected_gamepads() > 0) {
          // A decision needs to be made
          Main.debug("Gamepads connected. Configuring controls.");
          machine.set('initial_controls_state');
        } else {
          Main.debug("No gamepads connected. Setting default controls.");
          Controls.set_default_keyboard_controls();
          machine.set('menu_state');
        }
      } else {
        Controls.connect_input(Json.parse(controls_str));
        Main.debug("Controls set. Loading.");
        Main.debug(controls_str);
        machine.set('menu_state');
      }
      #else
        machine.set('menu_state');
      #end
    });
  }
}
