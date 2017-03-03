import mint.focus.Focus;

class ControllerFocus extends Focus {

  static inline var MENU_GAMEPAD_SPEED = 0.3;

  var on_cancel:Void -> Void;

  public function new(_canvas:mint.Canvas, on_cancel:Void -> Void = null) {
      super(_canvas);
      this.on_cancel = on_cancel;
  } //new

  function markClosestToPoint(x:Float, y:Float, min_x:Float = null,
                                min_y:Float = null, max_x:Float = null,
                                max_y:Float = null) {
        trace("Marking closest to " + x + ", " + y);

        if (min_x == null) {
          min_x = 0;
        }

        if (min_y == null) {
          min_y = 0;
        }

        if (max_x == null) {
          max_x = canvas.w;
        }

        if (max_y == null) {
          max_y = canvas.h;
        }

        var min_distance = Math.POSITIVE_INFINITY;
        var min_element:mint.Control = null;
        for (c in canvas.children) {
          if (Type.getClass(c) == mint.Button &&
              c.x >= min_x && c.y >= min_y && c.x <= max_x && c.y <= max_y) {
                var distance = (c.x - x) * (c.x - x) + (c.y - y) * (c.y - y);
                if (distance < min_distance) {
                  min_distance = distance;
                  min_element = c;
                }
          }
        }

        if (min_element != null) {
          if (canvas.marked != null) {
            trace("Unmarking " + canvas.marked);
            canvas.marked.mouseleave(null);
            canvas.marked.unmark();
          }

          trace("Marking " + min_element);
          min_element.mark();
          min_element.mouseenter(null);
        }
  }

  function up() {
    if (canvas.marked == null) {
      // We select the bottom one
      markClosestToPoint(canvas.w / 2, canvas.h);
    } else {
      markClosestToPoint(canvas.marked.x, canvas.marked.y, null, null,
                         null, canvas.marked.y - 1);
    }
  }

  function down() {
    if (canvas.marked == null) {
      // We select the top one
      markClosestToPoint(canvas.w / 2, 0);
    } else {
      markClosestToPoint(canvas.marked.x, canvas.marked.y, null,
                         canvas.marked.y + 1, null, null);
    }
  }

  function left() {
    if (canvas.marked == null) {
      // We select the right most one
      markClosestToPoint(canvas.w, canvas.h / 2);
    } else {
      markClosestToPoint(canvas.marked.x, canvas.marked.y, null,
                         null, canvas.marked.x - 1, null);
    }
  }

  function right() {
    if (canvas.marked == null) {
      // We select the left most one
      markClosestToPoint(0, canvas.h / 2);
    } else {
      markClosestToPoint(canvas.marked.x, canvas.marked.y, canvas.marked.x + 1,
                         null, null, null);
    }
  }

  function click() {
    if (canvas.marked != null) {
      canvas.marked.mousedown(null);
      canvas.marked.mouseup(null);
    }
  }

  function cancel() {
    if (on_cancel != null) {
      on_cancel();
    }
  }

  public function update(elapsed:Float) {
    // Now we need to loop through each controller and see if they have pressed
    // a menu button
    for (i in 1...Luxe.core.app.config.user.game.controllers) {

      var menu_buttons = Controls.get_menu_buttons();

      if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, menu_buttons.click)) {
        click();
        return;
      } else if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, menu_buttons.cancel)) {
        cancel();
        return;
      }

      for (k in Controls.get_menu_movement_controls()) {
        if (k[0] == "analogue") {
          var horizontal_key = k[1];
          var vertical_key = k[2];

          var h = Controls.analogueposition(i, horizontal_key);
          var v = Controls.analogueposition(i, vertical_key);

          if (Controls.throttle("h < -0.5", MENU_GAMEPAD_SPEED, h < -0.5)) {
            // Move left
            left();
          } else if (Controls.throttle("h > 0.5", MENU_GAMEPAD_SPEED, h > 0.5)) {
            // Move right
            right();
          } else if (Controls.throttle("v < -0.5", MENU_GAMEPAD_SPEED, v < -0.5)) {
            // Move up
            up();
          } else if (Controls.throttle("v > 0.5", MENU_GAMEPAD_SPEED, v > 0.5)) {
            // Move down
            down();
          }
        } else {
          // digital
          if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, k[1])) {
            // Move left
            left();
          } else if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, k[2])) {
            // Move right
            right();
          } else if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, k[3])) {
            // Move up
            up();
          } else if (Controls.throttleinputdown(MENU_GAMEPAD_SPEED, i, k[4])) {
            // Move down
            down();
          }
        }
      }
    }
  }
}
