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

import mint.render.luxe.LuxeMintRender;

class ConfigureControllerState extends State {

  var canvas: mint.Canvas;
  var configuration: Map<String, Int>;

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
          configuration.set("type", Controls.KEYBOARD);
          input_device.label.text = input_device_label_text();
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
            configuration.set("type", Controls.GAMEPAD);
            configuration.set("gamepad_id", i);
            input_device.label.text = input_device_label_text();
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

  override function update(dt:Float) {

  }
}
