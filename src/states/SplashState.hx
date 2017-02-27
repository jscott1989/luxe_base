package states;
import luxe.States;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Color;
import luxe.tween.actuators.GenericActuator;

import mint.render.luxe.LuxeMintRender;

/**
 * State which shows a splash image and then moves on to the menu.
 */
class SplashState extends State {

  var splash:Sprite;
  var tween:IGenericActuator;
  var n:Int;
  var stopping = false;

  public function new(name:String) {
    super({ name:name });
  }

  override function onenter<T> (i:T) {
    stopping = false;
    n = cast i;
    trace("Enter splash state " + n);


    splash = new Sprite({
        name:'splash',
        texture : Luxe.resources.texture('assets/splash' + n + '.png'),
        pos : Luxe.screen.mid,
        centered : true,
        color: new Color(1, 1, 1, 0)
    });

    // Set up tween to fade in and then fade out
    tween = Actuate.tween(splash.color, 2,  {a:1} )
      .onComplete(function() {
        tween = Actuate.tween(splash.color, 2,  {a:0} )
          .onComplete(next);
      });
  }

  override function onleave<T> (_:T) {
    trace("Leave splash state");
    splash.destroy();
  }

  /**
   * Move on to the next splash or the main menu.
   */
  private function next() {
      if (n == Luxe.core.app.config.user.game.splash_screens) {
        machine.set('menu_state');
      } else {
        machine.set('splash_state', n + 1);
      }
  }

  override function update(dt:Float) {
    // If we're not moving on already, check for a button press to skip.
    if (!stopping) {
      if (Luxe.input.mousedown(0) || Luxe.input.mousedown(1)) {
        stopping = true;
        tween = Actuate.tween(splash.color, 0.2,  {a:0} )
          .onComplete(next);
        return;
      }
      for (i in 0...Luxe.core.app.config.user.game.controllers) {
        for (k in Controls.digital_map.keys()) {
          if(Luxe.input.inputdown((i + 1) + "." + k)) {
            stopping = true;
            tween = Actuate.tween(splash.color, 0.2,  {a:0} )
              .onComplete(next);
            return;
          }
        }
      }
    }
  }
}
