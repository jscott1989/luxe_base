package states;
import luxe.States;
import luxe.Sprite;
import luxe.Color;
import luxe.Vector;

class GameState extends State {
  var player: Sprite;

  public function new(name:String) {
    super({name:name});
  }

  override function onenter<T> (_:T) {
    player = new Sprite({
      name: 'player2',
      pos: new Vector(64, 64),
      color: new Color().rgb(0x00ffff),
      size: new Vector(64, 64)
    });
  }

  override function onleave<T> (_:T) {
    player.destroy();
  }

  override function update( dt:Float ) {
    
  }
}
