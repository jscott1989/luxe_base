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
import Sys;

import mint.render.luxe.LuxeMintRender;

class MenuState extends State {

  var canvas: mint.Canvas;

  public function new(name:String) {
    super({ name:name });
  }

  override function onenter<T> (_:T) {
    Main.debug("Enter menu state");

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

    var image = new mint.Image({
        parent: canvas, name: 'logo',
        x: Luxe.screen.mid.x - (640 / 2), y:50, w:640, h:213,
        path: 'assets/logo.png'
    });

    layout.margin(image, top, fixed, 50);

    var play_button = new mint.Button({
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

    layout.margin(play_button, image, top, fixed, image.h + 40);

    #if (CONTROLLERS > 0)
    // For now the only option we have is controls
    // so if it's mouse/keyboard only we don't show options
    var options_button = new mint.Button({
      parent: canvas,
      name: 'options_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 391, w: 320, h: 64,
      text: 'Options',
      text_size: 28,
      options: { },
      onclick: function(e,c) {
        Main.machine.set("options_state");
      }
    });

    layout.margin(options_button, play_button, left, fixed, 0);
    layout.margin(options_button, play_button, top, fixed, play_button.h + 25);
    #end

    var exit_button = new mint.Button({
      parent: canvas,
      name: 'exit_button',
      x: Luxe.screen.mid.x - (320 / 2), y: 0, w: 320, h: 64,
      text: 'Exit',
      text_size: 28,
      options: { },
      onclick: function(_, _) {
        Sys.exit(0);
      }
    });

    #if (CONTROLLERS > 0)
      layout.margin(exit_button, options_button, left, fixed, 0);
      layout.margin(exit_button, options_button, top, fixed, options_button.h + 25);
    #else
      layout.margin(exit_button, play_button, left, fixed, 0);
      layout.margin(exit_button, play_button, top, fixed, play_button.h + 25);
    #end

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
    Main.debug("Leave menu state");
    canvas.destroy();
  }

  override function update(dt:Float) {

  }
}
