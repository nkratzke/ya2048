import 'dart:math' as math;
import 'dart:html';
import 'dart:convert';
import 'package:quiver/iterables.dart';

/// The Model of the 2048 game.
///
class Ya2048 {

  // Local storage to store the highscore locally.
  Map<String, String> _storage = window.localStorage; // not so nice ...

  // Game field.
  List<List<int>> _field = [];

  // A random generator.
  math.Random _random = new math.Random();

  // Current score.
  int _score = 0;

  // Current score (points).
  int get score => this._score;

  // Current maximum tile having a multiple of 2.
  int get maximum => max(concat(_field));

  // Gets the highest points reached so far (and stored in local storage).
  int get highestPoints => jsonDecode(_storage['highscore'])['points'];

  // Gets the highest score (multiples of 2) reached so far (and stored in local storage).
  int get highestScore => jsonDecode(_storage['highscore'])['score'];

  // Amount of rows.
  int get rows => this._field.length;

  // Amount of cols.
  int get cols => this._field[0].length;

  // Is the game running?
  bool get running  => canFoldUp || canFoldDown || canFoldLeft || canFoldRight;

  // Do we have a game over?
  bool get gameOver => !running;

  // Returns the value of the tile at position ([r], [c]).
  int get(int r, int c) => this._field[r][c];

  // Checks whether the tile at position (r, c) is empty (has a value of 0).
  bool empty(int r, int c) => validPos(r, c) && this.get(r, c) == 0;

  // Checks whether the position (r, c) is a valid position (is on the field).
  bool validPos(int r, int c) => 0 <= r && r < rows && 0 <= c && c < cols;

  // Calculates how many tiles a tile at position (r, c) can be moved into
  // a specified direction. The direction must be one of [#up, #down, #left, #right].
  int moves(int r, int c, Symbol direction) {
    if (!validPos(r, c)) return 0;
    if (empty(r, c)) return 0;

    if (direction == #up) {
      final above = _getCol(c).sublist(0, r + 1);
      final fold = _foldl(above);
      return above.length - fold.length;
    }

    if (direction == #down) {
      final below = _getCol(c).sublist(r, rows);
      final fold = _foldr(below);
      return below.length - fold.length;
    }

    if (direction == #left) {
      final left = _getRow(r).sublist(0, c + 1);
      final fold = _foldl(left);
      return left.length - fold.length;
    }

    if (direction == #right) {
      final right = _getRow(r).sublist(c, cols);
      final fold = _foldr(right);
      return right.length - fold.length;
    }

    return 0;
  }

  // Checks whether a tile at position (r, c) is moveable into a specified
  // direction. The direction must be one of [#up, #down, #left, #right].
  bool moveable(int r, int c, Symbol direction) => moves(r, c, direction) > 0;

  // Checks whether at least one column can be folded upwards.
  bool get canFoldUp => range(0, cols).any((c) {
    List<int> column = _getCol(c).reversed.skipWhile((v) => v == 0).toList().reversed.toList();
    return column.isEmpty ? false : _foldl(column).length < column.length;
  });

  // Checks whether at least one column can be folded downwards.
  bool get canFoldDown => range(0, cols).any((c) {
    List<int> column = _getCol(c).skipWhile((v) => v == 0).toList();
    return column.isEmpty ? false : _foldr(column).length < rows;
  });

  // Checks whether at least one column can be folded to the left.
  bool get canFoldLeft => range(0, rows).any((r) {
    List<int> row = _getRow(r).reversed.skipWhile((v) => v == 0).toList().reversed.toList();
    return row.isEmpty ? false : _foldl(row).length < row.length;
  });

  // Checks whether at least one column can be folded to the right.
  bool get canFoldRight => range(0, rows).any((r) {
    List<int> row = _getRow(r).skipWhile((v) => v == 0).toList();
    return row.isEmpty ? false : _foldr(row).length < row.length;
  });

  // Constructor to create a model for 2048 games
  // composed of [rs] rows and [cs] cols.
  Ya2048.withDimension(rs, cs) { newGame(rs, cs); }

  // Creates a new 2048 game composed of [rs] rows and [cs] cols.
  void newGame(rs, cs) {
    _score = 0;
    _field = new List<List<int>>();
    for (int r = 0; r < rs; r++) {
      _field.add([]);
      for (int c = 0; c < cs; c++) {
        _field[r].add(0);
      }
    }

    _field[_random.nextInt(rows - 1)][_random.nextInt(cols - 1)] = 2;
    _field[_random.nextInt(rows - 1)][_random.nextInt(cols - 1)] = 2;

    this.updateHighscore();
  }

  // Triggers a fold up on the game field.
  void up() {
    for (int col = 0; col < cols; col++) {
      final values = _foldCol(col, #up);
      for (int row = 0; row < rows; row++) {
        _field[row][col] = values[row];
      }
    }
    updateHighscore();
  }

  // Triggers a fold down on the game field.
  void down() {
    for (int col = 0; col < cols; col++) {
      final values = _foldCol(col, #down);
      for (int row = 0; row < rows; row++) {
        _field[row][col] = values[row];
      }
    }
    updateHighscore();
  }

  // Triggers a fold right on the game field.
  void right() {
    for (int row = 0; row < rows; row++) {
      _field[row] = _foldRow(row, #right);
    }
    updateHighscore();
  }

  // Triggers a fold left on the game field.
  void left() {
    for (int row = 0; row < rows; row++) {
      _field[row] = _foldRow(row, #left);
    }
    updateHighscore();
  }

  // Returns the values in row [r] of the game field as a List.
  List<int> _getRow(int r) => new List.generate(cols, (c) => c).map((c) => this.get(r, c)).toList();

  // Returns the values in column [c] of the game field as a List.
  List<int> _getCol(int c) => new List.generate(rows, (r) => r).map((r) => this.get(r, c)).toList();

  // Folds a list of values from left to right according to the 2048 rules.
  List<int> _foldl(List<int> list) {
    List<int> process = list.where((i) => i != 0).toList();
    final merged = <int>[];
    for (int i = 0; i < process.length; i++) {
      if (i < process.length - 1 && process[i] == process[i + 1]) {
        merged.add(2 * process[i++]);
        _score += merged.last;
      } else {
        merged.add(process[i]);
      }
    }
    return merged;
  }

  // Folds a list of values from right to to left according to the 2048 rules.
  List<int> _foldr(List<int> list) {
    List<int> process = list.where((i) => i != 0).toList().reversed.toList();
    final merged = <int>[];
    for (int i = 0; i < process.length; i++) {
      if (i < process.length - 1 && process[i] == process[i + 1]) {
        merged.add(2 * process[i++]);
        _score += merged.last;
      } else {
        merged.add(process[i]);
      }
    }
    return merged.reversed.toList();
  }

  // Folds the row [r] to the left or right.
  // [direction] must be one of {#left, #right}
  List<int> _foldRow(int r, Symbol direction) {
    final fold = direction == #left ? _foldl(_getRow(r)) : _foldr(_getRow(r));
    final pad = new List.filled(cols - fold.length, 0, growable: true);
    if (direction == #left) {
      fold.addAll(pad);
      return fold;
    } else {
      pad.addAll(fold);
      return pad;
    }
  }

  // Folds the col [c] upwards or downwards.
  // [direction] must be one of {#up, #down}.
  List<int> _foldCol(int c, Symbol direction) {
    final fold = direction == #up ? _foldl(_getCol(c)) : _foldr(_getCol(c));
    final pad = new List.filled(rows - fold.length, 0, growable: true);
    if (direction == #up) {
      fold.addAll(pad);
      return fold;
    } else {
      pad.addAll(fold);
      return pad;
    }
  }

  // Adds a new tile with default value 2 to the gamefield.
  // Returns null if the game is over, otherwise the position as
  // Point of (column, row).
  Point add([int n = 2]) {
    if (this.gameOver) return null;

    while(true) {
      int r = _random.nextInt(rows);
      int c = _random.nextInt(cols);
      if (empty(r, c)) {
        _field[r][c] = n;
        return new Point(c, r);
      }
    }
  }

  // Updates the highscore. If no local storage has been created so far,
  // this will be done.
  void updateHighscore() {
    if (!_storage.containsKey('highscore')) {
      _storage['highscore'] = jsonEncode({
        'points': this.score,
        'score': this.maximum
      });
    }
    var highscore = jsonDecode(_storage['highscore']);
    highscore['points'] = math.max(this.score, highscore['points'] as int);
    highscore['score'] = math.max(this.maximum, highscore['score'] as int);
    _storage['highscore'] = jsonEncode(highscore);
  }

  // Textual representation of the state (game field) of this model.
  // Can be used for console based debugging mainly.
  String toString() => _field.map((row) => row.map((v) => "${v}").join(" ")).join("\n");
}