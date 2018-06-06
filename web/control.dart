import 'model.dart';
import 'view.dart';
import 'dart:html';
import 'dart:async';

/// The controller of the 2048 game.
///
class Ya2048Control {

  // Reference to the controlled model.
  Ya2048 _model;

  // Reference to the view the represents the model.
  Ya2048View _view;

  // Constructor to create the controller.
  Ya2048Control(this._model, this._view);

  // Control flow to fold the game into a specified direction.
  // [direction] must be one of {#up, #down, #left, #right}.
  // Returns true if the model could be folded, otherwise false.
  //
  bool _fold(Symbol direction) {
    if (![#up, #down, #left, #right].contains(direction)) return false;

    if (direction == #up && !_model.canFoldUp) return false;
    if (direction == #down && !_model.canFoldDown) return false;
    if (direction == #left && !_model.canFoldLeft) return false;
    if (direction == #right && !_model.canFoldRight) return false;

    _view.animateMove(direction);

    if (direction == #up) _model.up();
    if (direction == #down) _model.down();
    if (direction == #left) _model.left();
    if (direction == #right) _model.right();

    new Timer(new Duration(milliseconds: 250), () {
      _view.refreshField();
      _view.animatePop(_model.add());
    });

    return true;
  }

  // Starts the controller. This method registers all necessary event handlers
  // used for user interaction.
  // The following controllers are registered:
  // - key based controller (Key UP, DOWN, LEFT, RIGHT) mainly used for desktop
  // - touch based controller (Swipe UP, DOWN, LEFT, RIGHT) mainly used on mobile
  // - play again controller (Button click) to restart the game in a fresh state.
  //
  void start() {
    final controls = [KeyCode.UP, KeyCode.DOWN, KeyCode.LEFT, KeyCode.RIGHT];
    window.onKeyDown.where((ev) => controls.contains(ev.keyCode)).listen((ev) {
        bool possibleMove = false;
        if (ev.keyCode == KeyCode.UP) possibleMove = _fold(#up);
        if (ev.keyCode == KeyCode.DOWN) possibleMove = _fold(#down);
        if (ev.keyCode == KeyCode.LEFT) possibleMove = _fold(#left);
        if (ev.keyCode == KeyCode.RIGHT) possibleMove = _fold(#right);

        if (!possibleMove) _view.shakeField();
        if (_model.gameOver) _view.showGameOver();
    });

    Point start, end;
    window.onTouchStart.listen((ev) => start = ev.changedTouches.first.page);
    window.onTouchEnd.listen((ev) {
      end = ev.changedTouches.last.page;
      int dx = start.x - end.x;
      int dy = start.y - end.y;
      bool horizontal = dx.abs() > dy.abs();
      bool vertical = dy.abs() > dx.abs();

      bool possibleMove = false;
      if (vertical && dy > 0) possibleMove = _fold(#up);
      if (vertical && dy < 0) possibleMove = _fold(#down);
      if (horizontal && dx > 0) possibleMove = _fold(#left);
      if (horizontal && dx < 0) possibleMove = _fold(#right);

      if (!possibleMove) _view.shakeField();
      if (_model.gameOver) _view.showGameOver();
    });

    window.onResize.listen((ev) => _view.refreshField());

    querySelector("#playagain").onClick.listen((_) {
      _model.newGame(_model.rows, _model.cols);
      _view.hideGameOver();
      _view.refreshField();
    });
  }
}