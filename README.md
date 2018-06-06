# Yet another 2048 game

- Author: Nane Kratzke, Lübeck University of Applied Sciences
- Purpose: A demonstration game for my Webtech course (Computer Science study programme)

This game is an implementation of the famous 
[2048](https://en.wikipedia.org/wiki/2048_(video_game)) game first published by
Gabriele Cirulli.  The main purpose of this game implementation is 
to demonstrate several aspects of client side programming 
using [Dart](https://www.dartlang.org/) including:

- Key-based control for desktop usage
- Swipe-based control for mobile usage
- CSS animations to indicate impossible folds (shaking)
- CSS animations to indicate successful folds (sliding up, down, left, right)
- Web storage (localstorage) to realize a persistent client-side highscore
- Offline usage via service workers and the [PWA](https://pub.dartlang.org/packages/pwa) package
- Viewport related scaling

You can [play](https://www.nkode.io/assets/webtech/demos/ya2048/) this game here:

![](qr.png)

You find the implementation of the game on [github](https://github.com/nkratzke/ya2048).
