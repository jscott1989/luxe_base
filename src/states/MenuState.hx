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
        x: 160, y:50, w:640, h:213,
        path: 'assets/logo.png'
    });

    new mint.Button({
      parent: canvas,
      name: 'play_button',
      x: 320, y: 295, w: 320, h: 64,
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
      x: 320, y: 391, w: 320, h: 64,
      text: 'Options',
      text_size: 28,
      options: { },
      // onclick: function(e,c) {Main.machine.set("game_state");}
    });

    new mint.Button({
      parent: canvas,
      name: 'exit_button',
      x: 320, y: 487, w: 320, h: 64,
      text: 'Exit',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Sys.exit(0);
      }
    });

    new mint.Label({
        parent: canvas,
        name: 'information',
        x:0, y:608, w:960, h:32,
        text: 'TEMPLATE is a game by Citizen of Mêlée',
        align:center,
        text_size: 14,
        onclick: function(_,_) { trace('hello mint!'); }
    });
  }

  override function onleave<T> (_:T) {
    canvas.destroy();
  }

  override function update(dt:Float) {

  }
}
