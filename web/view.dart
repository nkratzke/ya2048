import 'dart:html';
import 'dart:async';
import 'dart:math' as math;
import 'model.dart';
import 'package:quiver/iterables.dart';

/// The view of the 2048 game.
///
class Ya2048View {

  // Reference to the to be presented model.
  Ya2048 _model;

  // Main output element.
  Element _output = querySelector('#output');

  // Game over div which is shown in case of game over state.
  Element _gameOver = querySelector('#gameover');

  // Element that shows the current maximum tile value (multiples of 2).
  Element _currentScore = querySelector("#scoring .score");

  // Element that shows the current points.
  Element _currentPoints = querySelector("#scoring .points");

  // Element that shows the best maximum tile value ever reached.
  Element _highestScore = querySelector("#scoring .highscore");

  // Element that shows the best points ever reached.
  Element _highestPoints = querySelector("#scoring .highpoints");

  // Constructor to create the view.
  Ya2048View(this._model);

  // Helper method to translate folding directions (#up, #down, #left, #right)
  // into HTML class names.
  // - #up => 'up'
  // - #down => 'down'
  // - #left => 'left'
  // - #right => 'right'
  //
  String _nameFor(Symbol direction) {
    if (direction == #up) return 'up';
    if (direction == #down) return 'down';
    if (direction == #left) return 'left';
    if (direction == #right) return 'right';
    return '';
  }

  // Animates a fold into a specified [direction].
  // All elements that would be moved into a specified direction
  // will be assigned a corresponding class (up, down, left, right).
  // These class informations are associated with corresponding
  // CSS animation keyframe rules to create the animation.
  //
  void animateMove(Symbol direction) {
    List<Element> elements = querySelectorAll('#output td');
    List<List<Element>> field = partition(elements, _model.cols).toList();
    for (int row = 0; row < _model.rows; row++) {
      for (int col = 0; col < _model.cols; col++) {
        if (_model.moveable(row, col, direction)) {
          field[row][col].classes.add(_nameFor(direction));
        }
      }
    }
  }

  // Animates a "pop" of a newly added element. This is done by adding
  // the 'pop' class to the corresponding tile.
  // This pop class is associated with corresponding
  // a CSS animation keyframe rule to create the animation.
  //
  void animatePop(Point pos) {
    List<Element> elements = querySelectorAll('#output td');
    List<List<Element>> field = partition(elements, _model.cols).toList();
    Element td = new Element.td();
    int n = _model.get(pos.y, pos.x);
    td.classes.add('pop');
    td.classes.add('tile${n}');
    td.text = "$n";
    field[pos.y][pos.x].replaceWith(td);
  }

  // Refreshes the highscore.
  void _refreshHighscore() {
    _highestPoints.text = "${_model.highestPoints}";
    String highestScore = "${_model.highestScore}";
    if (_highestScore.text != highestScore) {
      _highestScore.text = highestScore;
      _highestScore.classes.add("change");
    } else _highestScore.classes.remove("change");
  }

  // Realizes the scaling of the game. The scaling takes
  // the screen size and the amount of rows and columns into account.
  // - The tile width/height is calculated accordingly.
  // - The basic font size is calculated accordingly.
  // - All spacing and length values are defined in CSS relatively to this basic font size.
  //
  void _scale() {
    int space = math.min(800, math.min(window.innerWidth, window.innerHeight));
    int dim = (space / math.max(_model.cols, _model.rows) * 0.7).floor();
    for (Element td in querySelectorAll('#output td')) {
      td.style.width = "${dim}px";
      td.style.height = "${dim}px";
    }
    document.body.style.fontSize = "${dim ~/ 4}px";
  }

  // Shakes the field for 500 milliseconds by assiging the class 'warning'
  // to the [_output] element. After 500 milliseconds this warning class is removed.
  //
  void shakeField() {
    _output.classes.add('warning');
    new Timer(new Duration(milliseconds: 500), () => _output.classes.remove('warning'));
  }

  // Shows the game over screen.
  void showGameOver() => _gameOver.style.display = 'block';

  // Hides the game over screen.
  void hideGameOver() => _gameOver.style.display = 'none';

  // The main update routine of the view.
  // It refreshes the latest state of the model into the DOM-tree.
  //
  void refreshField() {
    _currentPoints.text = "${_model.score}";
    String score = "${_model.maximum}";
    if (_currentScore.text != score) {
      _currentScore.text = "${_model.maximum}";
      _currentScore.classes.add('change');
    } else _currentScore.classes.remove('change');
    _output.children.clear();
    Element table = new Element.table();
    for (int row = 0; row < _model.rows; row++) {
      Element tr = new Element.tr();
      table.append(tr);
      for (int col = 0; col < _model.cols; col++) {
        Element td = new Element.td();
        if (_model.get(row, col) > 0) td.text = "${_model.get(row, col)}";
        td.classes.add("tile${_model.get(row, col)}");
        tr.append(td);
      }
    }
    _output.append(table);
    _refreshHighscore();
    _scale();
  }
}