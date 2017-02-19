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

class InitialControlsState extends State {

  var canvas: mint.Canvas;

  public function new(name:String) {
    super({ name:name });
  }

  override function onenter<T> (_:T) {
    Main.debug("Enter initial controls state");
    var layout = new Margins();

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
        text: 'Controls',
        align:center,
        text_size: 56
    });

    var intro = new mint.Label({
        parent: canvas,
        name: 'intro',
        x:0, y:30, w:Luxe.screen.w, h:64,
        text: 'Select your default control method. You can change this under the options menu',
        align:center,
        text_size: 20
    });

    layout.margin(intro, title, top, fixed, title.h + 50);

    var keyboard_button = new mint.Button({
      parent: canvas,
      name: 'keyboard_button',
      x: Luxe.screen.mid.x - (320 + 50), y: 295, w: 320, h: 64,
      text: 'Keyboard',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Controls.set_default_keyboard_controls();
        Main.machine.set('menu_state');
      }
    });


    layout.margin(keyboard_button, intro, top, fixed, intro.h + 200);

    var gamepad_button = new mint.Button({
      parent: canvas,
      name: 'gamepad_button',
      x: Luxe.screen.mid.x + 50, y: 295, w: 320, h: 64,
      text: 'Gamepad',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Controls.set_default_gamepad_controls();
        Main.machine.set('menu_state');
      }
    });

    layout.margin(gamepad_button, keyboard_button, top, fixed, 0);
  }

  override function onleave<T> (_:T) {
    Main.debug("Leave initial controls state");
    canvas.destroy();
  }

  override function update(dt:Float) {

  }
}
