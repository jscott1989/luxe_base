package states;
import luxe.States;
import Sys;
import lib.AutoCanvas;
import mint.layout.margins.Margins;
import luxe.Color;

import mint.render.luxe.LuxeMintRender;

/**
 * Pause State.
 */
class PauseState extends State {

  var canvas: mint.Canvas;
  var focus: ControllerFocus;
  var resume: Void -> Void;

  public function new(name:String, resume:Void->Void) {
    super({ name:name });
    this.resume = resume;
  }

  override function onenter<T> (_:T) {
    trace("Enter pause state");

    var a_canvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { color:new Color(1,1,1,0.0) },
      x: 0, y:0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    a_canvas.auto_listen();

    canvas = a_canvas;
    focus = new ControllerFocus(canvas);

    var panel = new mint.Panel({
      parent: canvas,
      name: 'panel',
      x: 0, y: 0, w: Luxe.screen.w, h: Luxe.screen.h
    });

    var title = new mint.Label({
        parent: panel,
        name: 'title',
        x:0, y:30, w:Luxe.screen.w, h:64,
        text: 'Pause',
        align:center,
        text_size: 56
    });

    var resume_button = new mint.Button({
      parent: panel,
      name: 'resume_button',
      x: Luxe.screen.mid.x - (320 / 2), y: title.y + title.h + 200, w: 320, h: 64,
      text: 'Resume',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        resume();
      }
    });
  }

  override function onleave<T> (_:T) {
    trace("Leave pause state");
    canvas.destroy();
  }

  override function update(elapsed:Float) {
    focus.update(elapsed);
  }
}
