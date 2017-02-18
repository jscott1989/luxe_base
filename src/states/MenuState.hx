package states;
import luxe.States;
import luxe.Sprite;
import luxe.Color;
import luxe.Vector;
import luxe.Input;
import luxe.Text;
import lib.AutoCanvas;
import mint.focus.Focus;
import Sys;

import mint.render.luxe.LuxeMintRender;

class MenuState extends State {

  var canvas: mint.Canvas;

  public function new(name:String) {
    super({ name:name });
  }

  override function onenter<T> (_:T) {
    var a_canvas = new AutoCanvas(Luxe.camera.view, {
      name:'canvas',
      rendering: new LuxeMintRender(),
      options: { color:new Color(1,1,1,0.0) },
      x: 0, y:0, w: Luxe.screen.w, h: Luxe.screen.h
    });
    a_canvas.auto_listen();

    canvas = a_canvas;
    var focus = new Focus(canvas);

    new mint.Image({
        parent: canvas, name: 'logo',
        x: Luxe.screen.mid.x - (640 / 2), y:50, w:640, h:213,
        path: 'assets/logo.png'
    });

    new mint.Button({
      parent: canvas,
      name: 'play_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 295, w: 320, h: 64,
      text: 'Play Game',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Main.machine.set("game_state");
      }
    });

    new mint.Button({
      parent: canvas,
      name: 'options_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 391, w: 320, h: 64,
      text: 'Options',
      text_size: 28,
      options: { },
      onclick: function(e,c) {Main.debug("game_state");}
    });

    new mint.Button({
      parent: canvas,
      name: 'exit_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 487, w: 320, h: 64,
      text: 'Exit',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Sys.exit(0);
      }
    });

    var title = Luxe.core.app.config.user.game.name;

    new mint.Label({
        parent: canvas,
        name: 'information',
        x:0, y:Luxe.screen.h - 64, w:Luxe.screen.w, h:32,
        text: title + ' is a game by Citizen of Mêlée',
        align:center,
        text_size: 14
    });
  }

  override function onleave<T> (_:T) {
    canvas.destroy();
  }

  override function update(dt:Float) {

  }
}
