package states;
import luxe.States;
import luxe.Sprite;
import luxe.tween.Actuate;
import luxe.Color;
import lib.MacroUtils;
import luxe.tween.actuators.GenericActuator;

import mint.render.luxe.LuxeMintRender;

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
    Main.debug("Enter splash state " + n);


    splash = new Sprite({
        name:'splash',
        texture : Luxe.resources.texture('assets/splash' + n + '.png'),
        pos : Luxe.screen.mid,
        centered : true,
        color: new Color(1, 1, 1, 0)
    });

    tween = Actuate.tween(splash.color, 2,  {a:1} )
      .onComplete(function() {
        tween = Actuate.tween(splash.color, 2,  {a:0} )
          .onComplete(next);
      });
  }

  override function onleave<T> (_:T) {
    Main.debug("Leave splash state");
    splash.destroy();
  }

  private function next() {
      if (n == Luxe.core.app.config.user.game.splash_screens) {
        machine.set('menu_state');
      } else {
        machine.set('splash_state', n + 1);
      }
  }

  override function update(dt:Float) {
    if (!stopping) {
      for (i in 0...Std.parseInt(MacroUtils.getDefinedValue("CONTROLLERS", "0"))) {
        for (k in Controls.actions_map.keys()) {
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
