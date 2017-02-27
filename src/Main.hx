import states.*;
import luxe.GameConfig;
import luxe.States;
import luxe.Vector;
import luxe.Camera;
import luxe.Input;
import haxe.Json;

class Main extends luxe.Game {
  // This controls the overal state of th game
  public static var machine : States;

  /**
   * Set up game states
   */
  private static function init_state_machine() {
    machine = new States({ name:'statemachine' });
    machine.add(new MenuState('menu_state'));
    machine.add(new SplashState('splash_state'));
    machine.add(new OptionsState('options_state'));
    machine.add(new InitialControlsState('initial_controls_state'));
    machine.add(new ControlsState('controls_state'));
    machine.add(new ConfigureControllerState('configure_controller_state'));
    machine.add(new GameState('game_state'));
  }

  /**
   * Initialise config
   */
  override function config(config:luxe.GameConfig) {
    // Set up width and height
    if(config.user.window != null) {
      if(config.user.window.width != null) {
        config.window.width = Std.int(config.user.window.width);
      }
      if(config.user.window.height != null) {
        config.window.height = Std.int(config.user.window.height);
      }
    }

    // Preload splash screens
    for (i in 0...Luxe.core.app.config.user.game.splash_screens) {
      config.preload.textures.push({ id:'assets/splash' + (i + 1) + '.png' });
    }

    // Set up defaults
    config.window.title = config.user.game.name;

    // Load basic images
    config.preload.textures.push({ id:'assets/logo.png' });

    return config;
  }

  /**
   * The gamepad connected/disconnected messages get sent before Luxe is ready
   * so we intercept them here instead
   */
  override function onevent(event:snow.types.Types.SystemEvent) {
    if(event.type == se_input && event.input != null &&
        event.input.type == ie_gamepad) {
      if(event.input.gamepad.type == ge_device) {
        switch(event.input.gamepad.device_event) {
          case ge_device_added:
            Controls.device_added(event.input.gamepad);
          case ge_device_removed:
            Controls.device_removed(event.input.gamepad);
          case ge_device_remapped:
            // TODO
            // I don't know what to do with this one
            // I guess it will involve changing the mapping?
            trace('remapped ${event.input.gamepad.device_id}');
          case _:
        }
      }
    }
  }

  override function ready() {
    trace(Luxe.core.app.config.user.game.name + " starting.");

    // Initialise systems
    Controls.init();

    // Set up screen size
    Luxe.camera.size = new Vector(Luxe.core.app.config.user.window.width,
                                  Luxe.core.app.config.user.window.height);
    Luxe.camera.size_mode = SizeMode.fit;

    // Set up game states
    init_state_machine();

    init_controls();
  }

  /**
   * Load the controls and move to the main menu.
   * If a decision is required about controls the appropriate menu
   * will be shown.
   */
  function init_controls() {
    if (Luxe.core.app.config.user.game.controllers > 0) {
      // We only care about configuration if we have controls
      var controls_str = Luxe.core.app.io.string_load("controls");
      if (controls_str == null) {
        trace("No controls set.");
        if (Luxe.core.app.config.user.game.allow_keyboard &&
            Luxe.core.app.config.user.game.allow_gamepad > 0) {
          if (Controls.connected_gamepads() > 0) {
            // A decision needs to be made
            trace("Gamepads connected. Configuring controls.");
            machine.set('initial_controls_state');
          } else {
            trace("No gamepads connected. Setting default controls.");
            Controls.set_default_keyboard_controls();
            first_state();
          }
        } else if (Luxe.core.app.config.user.game.allow_gamepad) {
          trace("Keyboard not allowed. Setting default gamepad controls.");
          Controls.set_default_gamepad_controls();
          first_state();
        } else {
          trace("Gamepad not allowed. Setting default keyboard controls.");
          Controls.set_default_keyboard_controls();
          first_state();
        }
      } else {
        trace("Controls set. Loading.");
        trace(controls_str);
        Controls.connect_input();
        first_state();
      }
    } else {
      first_state();
    }
  }

  /**
   * Move to the splash state if needed, otherwise to the menu.
   */
  public static function first_state() {
    if (Luxe.core.app.config.user.game.splash_screens > 0) {
      machine.set('splash_state', 1);
    } else {
      machine.set('menu_state');
    }
  }
}
