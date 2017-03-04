package states;
import luxe.States;
import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import lib.AutoCanvas;
import mint.focus.Focus;
import snow.systems.input.Keycodes;
import Controls;

import mint.render.luxe.LuxeMintRender;

/**
 * Allow configuration of a single controller.
 */
class ConfigureControllerState extends State {
  // The id of the controller to be configured
  var controller_id:Int;
  var configuration: ControlConfiguration;

  // Variables used during binding
  private var highlightedButtons = new Array<String>();
  private var bindingDigital:String = null;
  private var bindingAnalogue:String = null;
  private var bindingAnalogueIndex = 0;

  // Interface elements
  var canvas: mint.Canvas;
  var focus: ControllerFocus;
  var input_device:mint.Dropdown;
  var scroll:mint.Scroll;
  private var actionButtons = new Map<String, mint.Button>();

  public function new(name:String) {
    super({ name:name });
  }

  /**
   * Create a label for the configuration list.
   */
  function create_label(text:String, yoffset:Float) {
    var lbl = new mint.Label({
      parent:scroll, text: text, align: left,
      name: 'lbl_' + text, w: 200, h:32, text_size: 14, x: 0, y: yoffset
    });
    return yoffset + lbl.h + 10;
  }

  /**
   * Create a button to initialise binding on the configuration list.
   */
  function create_action_button(button:String, text:String, yoffset:Float,
                                analogue = false, index:Int = 0,
                                width:Int = 200, x:Int = 300) {
    var btn = new mint.Button({
      parent:scroll, text: text, align: left,
      name: 'btn_' + text, w: width, h:32, text_size: 14, x: x,
      y: yoffset,
      onclick: function(_, ctrl) {
        if (bindingDigital == null && bindingAnalogue == null) {
          set_highlight_button_colours(actionButtons[button + "_" + index],
            new Color().rgb(0xff0000));

          if (analogue) {
            actionButtons.get(button + "_" + index).label.text = "Waiting...";
            analogue_values = null;
            bindingAnalogue = button;
            bindingAnalogueIndex = index;
          } else {
            bindingDigital = button;
          }
        }
      }
    });
    btn.label.clip_with = scroll;
    actionButtons.set(button + "_" + index, btn);
  }

  /**
   * Update interface elements so they line up with the configuration.
   */
  public function refresh_interface() {
    // Input label
    input_device.label.text = input_device_label_text();

    // Remove all old action buttons
    for (b in actionButtons) {
      b.destroy();
    }

    // Add new buttons
    var yoffset:Float = 0;

    if (Controls.get_ordered_digital_controls().length > 0 &&
        Controls.get_ordered_analogue_controls().length > 0) {
          // We need labels because there are both analogue and digital
          yoffset = create_label("Analogue", yoffset);
    }

    for (k in Controls.get_ordered_analogue_controls()) {
      if (configuration.get_type() == Controls.KEYBOARD) {
        switch (k[2]) {
          case "1button": {
            create_action_button(k[1], analogue_mapped_text(k[1]), yoffset,
                                 true);
          }
          case _: {
            create_action_button(k[1], analogue_mapped_text(k[1], 0), yoffset,
                                 true, 0, 98);
            create_action_button(k[1], analogue_mapped_text(k[1], 1), yoffset,
                                 true, 1, 98, 402);
          }
        }
      } else {
        create_action_button(k[1], analogue_mapped_text(k[1]), yoffset, true);
      }
      yoffset = create_label(k[0], yoffset);
    }

    if (Controls.get_ordered_digital_controls().length > 0 &&
        Controls.get_ordered_analogue_controls().length > 0) {
          // We need labels because there are both analogue and digital
          yoffset = create_label("Digital", yoffset);
    }

    for (k in Controls.get_ordered_digital_controls()) {
      create_action_button(k[1], digital_mapped_text(k[1]), yoffset, false);
      yoffset = create_label(k[0], yoffset);
    }
  }

  /**
   * Reset button colours to default.
   */
  function set_default_button_colours(btn:mint.Button) {
    var b: mint.render.luxe.Button = cast btn.renderer;
    b.color = new Color().rgb(0x373737);
    b.color_hover = new Color().rgb(0x445158);
    b.color_down = new Color().rgb(0x444444);
    b.visual.color = new Color().rgb(0x373737);
  }

  /**
   * Highlight a button with a color.
   */
  function set_highlight_button_colours(btn:mint.Button, color:Color) {
    var b: mint.render.luxe.Button = cast btn.renderer;
    b.color = color;
    b.color_hover = color;
    b.color_down = color;
    b.visual.color = color;
  }

  /**
   * Give the name of the input device for the label.
   */
  private function input_device_label_text() {
    switch (configuration.get_type()) {
      case Controls.KEYBOARD: return "Keyboard";
      case Controls.GAMEPAD: return "Gamepad " + (
        configuration.get_gamepad_id() + 1);
      default: return "Input Device";
    }
  }

  /**
   * Give the text name for the given analogue input.
   */
  private function analogue_mapped_text(action:String, index:Int = 0) {
    if (configuration.get_type() == Controls.KEYBOARD) {
      var p = configuration.get_analogue(action)[index];
      return Keycodes.name(p).toUpperCase();
    }

    // For now we just assume it's a 360 controller. TODO MORE CONTROLLERS
    var c = Controls.control_names.get("360").get("analogue").get(
      configuration.get_analogue(action));
    if (c == null) {
      return "UNKNOWN BUTTON";
    }
    return c.toUpperCase();
  }

  /**
   * Give the text name for the given button.
   */
  private function digital_mapped_text(action:String) {
    if (configuration.get_type() == Controls.KEYBOARD) {
      var p = configuration.get_digital(action);
      return Keycodes.name(p).toUpperCase();
    }
    // For now we just assume it's a 360 controller. TODO MORE CONTROLLERS
    var c = Controls.control_names.get("360").get("digital").get(
      configuration.get_digital(action));
    if (c == null) {
      return "UNKNOWN BUTTON";
    }
    return c.toUpperCase();
  }

  /**
   * Initialise the state.
   */
  override function onenter<T> (c:T) {
    // TODO: Check if gamepads are enabled and give advice if not

    controller_id = cast c;
    actionButtons = new Map<String, mint.Button>();
    trace("Enter configure controller state");

    configuration = Controls.controls[controller_id];

    var a_canvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { color:new Color(1,1,1,0.0) },
      x: 0, y:0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    a_canvas.auto_listen();

    canvas = a_canvas;
    focus = new ControllerFocus(canvas);

    var title = new mint.Label({
        parent: canvas,
        name: 'title',
        x:0, y:30, w:Luxe.screen.w, h:64,
        text: 'Configure Player ' + (controller_id + 1) + " Controls",
        align:center,
        text_size: 56
    });

    var input_device_label = new mint.Label({
      parent: canvas,
      name: "input_device_label",
      x: Luxe.screen.mid.x - 200, y: title.y + title.h + 50, w: 120, h: 32,
      text: "Input Device",
      align:left,
      text_size: 20
    });

    input_device = new mint.Dropdown({
      parent: canvas,
      name: 'input_device', text: input_device_label_text(),
      x:input_device_label.x + input_device_label.w, y:input_device_label.y + 2, w:260, h:32,
    });

    if (Luxe.core.app.config.user.game.allow_keyboard) {
      input_device.add_item(
        new mint.Label({
          parent: input_device, text: 'Keyboard', align: left,
          name: 'input_device_keyboard', w:200, h:32, text_size: 14,
          onclick: function(_, _) {
            if (bindingDigital == null && bindingAnalogue == null) {
              configuration.set_type(Controls.KEYBOARD);
              refresh_interface();
            }
          }
        }),
        10, 0
      );
    }

    if (Luxe.core.app.config.user.game.allow_gamepad) {
      // TODO: I'd like to use Controls.connected_gamepads() but I need to know
      // accurate IDs of which gamepads are connected. For now we'll just link
      // to madeup IDs up to 10
      for (i in 0...10) {
        var p = i + 1;
        input_device.add_item(
          new mint.Label({
            parent: input_device, text: 'Gamepad ' + p, align: left,
            name: 'input_device_gamepad_' + i, w:200, h:32, text_size: 14,
            onclick: function(_, _) {
              if (bindingDigital == null && bindingAnalogue == null) {
                configuration.set_type(Controls.GAMEPAD);
                configuration.set_gamepad_id(i);
                refresh_interface();
              }
            }
          }),
          10, 0
        );
      }
    }

    scroll = new mint.Scroll({
      parent: canvas,
      name: 'scroll',
      x:Luxe.screen.mid.x - (320 + 50), y:input_device_label.y +
        input_device_label.h + 20, w:(320 + 50) * 2, h:320,
    });

    var cancel_button = new mint.Button({
      parent: canvas,
      name: 'cancel_button',
      x: Luxe.screen.mid.x - (320 + 50), y: Luxe.screen.h - 100, w: 320, h: 64,
      text: 'Cancel',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Main.machine.set("controls_state");
      }
    });

    var save_button = new mint.Button({
      parent: canvas,
      name: 'save_button',
      x: Luxe.screen.mid.x + 50, y: cancel_button.y, w: 320, h: 64,
      text: 'Save',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Controls.save_controller_configuration(controller_id, configuration);
        Main.machine.set("controls_state");
      }
    });

    refresh_interface();
  }

  override function onleave<T> (_:T) {
    trace("Leave configure controller state");
    canvas.destroy();
  }

  /**
   * A digital button has been pressed.
   */
  function button_press(buttonCode:Int) {
    if (bindingDigital != null) {
      // Doing digital binding
      configuration.set_digital(bindingDigital, buttonCode);
      set_default_button_colours(actionButtons[bindingDigital + "_0"]);
      refresh_interface();
      bindingDigital = null;
    } else if (bindingAnalogue != null
        && configuration.get_type() == Controls.KEYBOARD) {
      // Doing analogue binding on the keyboard
      var a = configuration.get_analogue(bindingAnalogue);
      a[bindingAnalogueIndex] = buttonCode;
      configuration.set_analogue(bindingAnalogue, a);
      set_default_button_colours(actionButtons[bindingAnalogue + "_" +
        bindingAnalogueIndex]);
      refresh_interface();
      bindingAnalogue = null;
      bindingAnalogueIndex = 0;
    } else {
      // If the code matches a configured input, highlight it
      for (k in configuration.digital_keys()) {
        if (configuration.get_digital(k) == buttonCode) {
          if (!(highlightedButtons.indexOf(k) > -1)) {
            if (actionButtons.exists(k + "_0")) {
              highlightedButtons.push(k);
              set_highlight_button_colours(actionButtons[k + "_0"],
                new Color().rgb(0x0000ff));
            }
          }
          return;
        }
      }
    }
  }

  /**
   * A digital button has been released.
   */
  function button_release(buttonCode:Int) {
    for (k in configuration.digital_keys()) {
      if (configuration.get_digital(k) == buttonCode) {
        if (highlightedButtons.indexOf(k) > -1) {
          set_default_button_colours(actionButtons[k + "_0"]);
          highlightedButtons.remove(k);
        }
        return;
      }
    }
  }

  override function onkeydown(e:KeyEvent) {
    if (configuration.get_type() == Controls.KEYBOARD) {
      button_press(e.keycode);
    }
  }

  override function onkeyup(e:KeyEvent) {
    button_release(e.keycode);
  }

  override function ongamepaddown(e:GamepadEvent) {
      if (configuration.get_type() == Controls.GAMEPAD &&
          configuration.get_gamepad_id() == e.gamepad) {
        button_press(e.button);
      }
  }

  override function ongamepadup(e:GamepadEvent) {
    if (configuration.get_type() == Controls.GAMEPAD &&
        configuration.get_gamepad_id() == e.gamepad) {
      button_release(e.button);
    }
  }

  // Used for tracking analogue values for watching for changes
  var analogue_values = null;
  override function update(delta:Float) {

    // TODO: there must be a way to actually query for this...
    var MAX_ANALOGUE_INPUTS = 10;

    if (bindingAnalogue != null) {
      var max_difference_i = 0;
      var max_difference = 0.0;
      if (configuration.get_type() == Controls.GAMEPAD) {

        if (analogue_values == null) {
          analogue_values = new Map<Int, Float>();

          for (i in 0...MAX_ANALOGUE_INPUTS) {
            analogue_values[i] = Luxe.core.input.gamepadaxis(
              configuration.get_gamepad_id(), i);
          }
        }
        // Now we need to loop through the analogue settings and see if any
        // have changed significantly
        for (i in 0...MAX_ANALOGUE_INPUTS) {
          var t = Luxe.core.input.gamepadaxis(
            configuration.get_gamepad_id(), i);
          if (Math.abs(t - analogue_values[i]) > max_difference) {
            max_difference = Math.abs(t - analogue_values[i]);
            max_difference_i = i;
          }
        }

        if (max_difference > 0.1) {
          // We bind it
          configuration.set_analogue(bindingAnalogue, max_difference_i);
          set_default_button_colours(actionButtons[bindingAnalogue + "_0"]);
          refresh_interface();
          bindingAnalogue = null;
        }
      }
    }
  }
}
