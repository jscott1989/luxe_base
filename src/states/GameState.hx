package states;
import luxe.States;
import luxe.Text;
import luxe.Input;
import luxe.Input.GamepadEvent;
import luxe.Ev;
import haxe.Json;

class GameState extends State {
  var text1: Text;
  var text2: Text;
  var text3: Text;
  var text4: Text;

  public function new(name:String) {
    super({name:name});
  }

  override function onenter<T> (_:T) {
    Main.debug("Enter game state");

    text1 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(-100, -100, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text2 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(100, -100, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text3 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(-100, 100, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });

    text4 = new Text({
      text: '',
      pos : Luxe.screen.mid.add_xyz(100, 100, 0),
      point_size : 18,
      align: center,
      align_vertical:center
    });
  }

  override function onleave<T> (_:T) {
    Main.debug("Leave game state");
    text1.destroy();
    text2.destroy();
    text3.destroy();
    text4.destroy();
  }

  override function update( dt:Float ) {
    for (i in 1...5) {
      var _text = "";

      for (k in Controls.actions_map.keys()) {
        if(Luxe.input.inputdown(i + "." + k)) {
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
