import 'model.dart';
import 'view.dart';
import 'control.dart';

import 'package:pwa/client.dart' as pwa;

/// Main entry point of the 2048 game. It creates
/// - a model that holds and processes the game state.
/// - A view that presents and updates the game state as a DOM-tree.
/// - A controller that observes user interactions and translates them into model interactions.
///
void main() {
  new pwa.Client();
  var model = new Ya2048.withDimension(4, 4);
  var view = new Ya2048View(model);
  var controller = new Ya2048Control(model, view);
  view.refreshField();
  controller.start();
}