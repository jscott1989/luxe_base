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

import mint.render.luxe.LuxeMintRender;

class OptionsState extends State {

  var canvas: mint.Canvas;

  public function new(name:String) {
    super({ name:name });
  }

  override function onenter<T> (_:T) {
    Main.debug("Enter options state");
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
        text: 'Options',
        align:center,
        text_size: 56
    });

    var controls_button = new mint.Button({
      parent: canvas,
      name: 'controls_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 0, w: 320, h: 64,
      text: 'Controls',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        #if (CONTROLLERS==1)
          Main.machine.set("configure_controller_state");
        #else
          Main.machine.set("controls_state");
        #end
      }
    });

    layout.margin(controls_button, title, top, fixed, title.h + 200);

    var back_button = new mint.Button({
      parent: canvas,
      name: 'back_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 0, w: 320, h: 64,
      text: 'Back',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Main.machine.set("menu_state");
      }
    });

    layout.margin(back_button, controls_button, top, fixed, controls_button.h + 25);
  }

  override function onleave<T> (_:T) {
    Main.debug("Leave options state");
    canvas.destroy();
  }

  override function update(dt:Float) {

  }
}