package states;
import luxe.States;
import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import lib.AutoCanvas;
import mint.focus.Focus;
import mint.layout.margins.Margins;
import lib.MacroUtils;
import snow.systems.input.Keycodes;

import mint.render.luxe.LuxeMintRender;

class ConfigureControllerState extends State {

  var canvas: mint.Canvas;
  var configuration: Map<String, Int>;

  private var highlightedButtons = new Array<String>();
  private var bindingButton:String = null;
  private var actionButtons = new Map<String, mint.Button>();

  public function new(name:String) {
    super({ name:name });
  }

  private function input_device_label_text() {
    var t = configuration.get('type');
    var p = configuration.get('gamepad_id');
    switch (t) {
      case Controls.KEYBOARD: return "Keyboard";
      case Controls.GAMEPAD: return "Gamepad " + (p + 1);
      default: return "Input Device";
    }
  }

  private function action_mapped_text(action:String) {
    if (configuration.get("type") == Controls.KEYBOARD) {
      var p = configuration.get(action);
      return Keycodes.name(p).toUpperCase();
    }
    return "Unknown";
  }

  override function onenter<T> (c:T) {
    var controller_id:Int = cast c;
    Main.debug("Enter configure controller state");
    var layout = new Margins();


    // Load the
    configuration = Controls.load_configuration(controller_id);

    var a_canvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { color:new Color(1,1,1,0.0) },
      x: 0, y:0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    a_canvas.auto_listen();

    canvas = a_canvas;
    var focus = new Focus(canvas);

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
      x: Luxe.screen.mid.x - 200, y: 0, w: 120, h: 32,
      text: "Input Device",
      align:left,
      text_size: 20
    });

    layout.margin(input_device_label, title, top, fixed, title.h + 50);

    var input_device = new mint.Dropdown({
      parent: canvas,
      name: 'input_device', text: input_device_label_text(),
      x:input_device_label.x + input_device_label.w, y:input_device_label.y + 2, w:260, h:32,
    });

    input_device.add_item(
      new mint.Label({
        parent: input_device, text: 'Keyboard', align: left,
        name: 'input_device_keyboard', w:200, h:32, text_size: 14,
        onclick: function(_, _) {
          if (bindingButton == null) {
            configuration.set("type", Controls.KEYBOARD);
            input_device.label.text = input_device_label_text();
          }
        }
      }),
      10, 0
    );

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
            if (bindingButton == null) {
              configuration.set("type", Controls.GAMEPAD);
              configuration.set("gamepad_id", i);
              input_device.label.text = input_device_label_text();
            }
          }
        }),
        10, 0
      );
    }

    var panel = new mint.Panel({
      parent: canvas,
      name: 'panel',
      x:Luxe.screen.mid.x - (320 + 50), y:input_device_label.y +
        input_device_label.h + 20, w:(320 + 50) * 2, h:320,
    });

    var scroll = new mint.Scroll({
      parent: panel,
      name: 'scroll',
      x:0, y:0, w:panel.w, h:panel.h,
    });

    var yoffset:Float = 0;
    for (k in Controls.get_ordered_controls()) {
      // k[0] is the action name, k[1] is the default binding
      var lbl = new mint.Label({
        parent:scroll, text: k[0], align: left,
        name: 'lbl_' + k[0], w: 200, h:32, text_size: 14, x: 0, y: yoffset
      });

      var btn = new mint.Button({
        parent:scroll, text: action_mapped_text(k[1]), align: left,
        name: 'btn_' + k[0], w: 200, h:32, text_size: 14, x: 300, y: yoffset,
        onclick: function(_, ctrl) {
          if (bindingButton == null) {
            var b: mint.render.luxe.Button = cast actionButtons[k[1]].renderer;
            b.color =  new Color().rgb(0xff0000);
            b.color_hover =  new Color().rgb(0xff0000);
            b.color_down =  new Color().rgb(0xff0000);
            b.visual.color =  new Color().rgb(0xff0000);

            actionButtons.get(k[1]).label.text = "Waiting...";
            bindingButton = k[1];
          }
        }
      });
      actionButtons.set(k[1], btn);
      yoffset += lbl.h + 10;
    }

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
        Main.machine.set("controls_state");
      }
    });
  }

  override function onleave<T> (_:T) {
    Main.debug("Leave configure controller state");
    canvas.destroy();
  }

  override function onkeydown( e:KeyEvent ) {
    if (configuration.get("type") == Controls.KEYBOARD) {
      if (bindingButton != null) {
        configuration.set(bindingButton, e.keycode);
        actionButtons[bindingButton].label.text = action_mapped_text(bindingButton);
        var b: mint.render.luxe.Button = cast actionButtons[bindingButton].renderer;
        b.color = new Color().rgb(0x373737);
        b.color_hover = new Color().rgb(0x445158);
        b.color_down = new Color().rgb(0x444444);
        b.visual.color = new Color().rgb(0x373737);
        bindingButton = null;
      } else {
        // If the keypress matches a configured input, highlight it
        for (k in configuration.keys()) {
          if (configuration.get(k) == e.keycode) {
            if (!(highlightedButtons.indexOf(k) > -1)) {
              highlightedButtons.push(k);
              var b: mint.render.luxe.Button = cast actionButtons[k].renderer;
              b.color =  new Color().rgb(0x0000ff);
              b.color_hover =  new Color().rgb(0x0000ff);
              b.color_down =  new Color().rgb(0x0000ff);
              b.visual.color =  new Color().rgb(0x0000ff);
            }
            return;
          }
        }
      }
    }
  }

  override function onkeyup( e:KeyEvent ) {
    for (k in configuration.keys()) {
      if (configuration.get(k) == e.keycode) {
        if (highlightedButtons.indexOf(k) > -1) {
          var b: mint.render.luxe.Button = cast actionButtons[k].renderer;
          b.color = new Color().rgb(0x373737);
          b.color_hover = new Color().rgb(0x445158);
          b.color_down = new Color().rgb(0x444444);
          b.visual.color = new Color().rgb(0x373737);
          highlightedButtons.remove(k);
        }
        return;
      }
    }
  }

  override function update(dt:Float) {
  }
}
