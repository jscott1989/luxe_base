package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;
import luxe.Ev;
import haxe.Json;

/**
 * Example game state. Shows controller input.
 */
class GameState extends State {
  var state_machine : States;

  var text1: Text;
  var text2: Text;
  var text3: Text;
  var text4: Text;

  public function new(name:String) {
    super({name:name});

    state_machine = new States({ name:'statemachine' });
    state_machine.add(new PauseState('pause', resume));
  }

  override function onenter<T> (_:T) {
    trace("Enter game state");

    text1 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(-200, -200, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text2 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(200, -200, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text3 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(-200, 200, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text4 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(200, 200, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });
  }

  override function onleave<T> (_:T) {
    trace("Leave game state");
    text1.destroy();
    text2.destroy();
    text3.destroy();
    text4.destroy();
  }

  function pause() {
    state_machine.set('pause');
  }

  function resume() {
    state_machine.unset();
  }

  override function update( dt:Float ) {
    if (state_machine.current_state != null &&
        state_machine.current_state.name == "pause") {
          // We don't do anything while paused
          return;
    }

    for (i in 1...Luxe.core.app.config.user.game.controllers) {
      if (Controls.throttleinputdown(1, i, Controls.get_gameplay_controls().pause)) {
        pause();
      }
    }

    for (i in 1...5) {
      var _text = "";

      for (k in Controls.analogue_map.keys()) {
        _text += k + ": " + Controls.analogueposition(i, k) + "\n";
      }

      for (k in Controls.digital_map.keys()) {
        if (Controls.inputdown(i, k)) {
          _text += k + " ";
        }
      }

      if (i == 1) {
        text1.text = _text;
      } else if (i == 2) {
        text2.text = _text;
      } else if (i == 3) {
        text3.text = _text;
      } else if (i == 4) {
        text4.text = _text;
      }
    }
  }
}
