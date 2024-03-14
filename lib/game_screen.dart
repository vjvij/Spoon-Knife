import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

const balloonWidth = 60.0;

class Balloon extends StatefulWidget {
  final double x;
  final bool popped;
  final Function(bool) onTap;

  Balloon({
    required this.x,
    required this.popped,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  _BalloonState createState() => _BalloonState();
}

class _BalloonState extends State<Balloon> {
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 800),
      left: widget.x,
      bottom: widget.popped ? -100 : MediaQuery.of(context).size.height,
      child: GestureDetector(
        onTap: () => widget.onTap(!widget.popped),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Image.asset(
            "assets/balloon.svg",
            height: 100,
            width: balloonWidth,
            color: widget.popped ? Colors.transparent : null,
          ),
        ),
      ),
    );
  }
}

class GameProvider extends ChangeNotifier {
  int score = 0;
  int balloonsPopped = 0;
  int balloonsMissed = 0;
  Duration remainingTime = Duration(minutes: 2);

  void resetGame() {
    score = 0;
    balloonsPopped = 0;
    balloonsMissed = 0;
    remainingTime = Duration(minutes: 2);
    notifyListeners();
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late GameProvider gameProvider;
  Timer? timer;
  int screenWidth = 0;
  List<Balloon> balloons = [];
  bool isPlaying = false;

  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    getScreenWidth();
    gameProvider = GameProvider();
    gameProvider.addListener(updateUI);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    gameProvider.removeListener(updateUI);
    _animationController.dispose();
    super.dispose();
  }

  void getScreenWidth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        screenWidth = MediaQuery.of(context).size.width.toInt();
      });
    });
  }

  void updateUI() {
    setState(() {
      // Update UI based on game state changes (optional)
    });
  }

  void startGame() {
    setState(() {
      isPlaying = true;
      resetGame();
      startTimer();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (gameProvider.remainingTime.inSeconds == 0) {
          t.cancel();
          endGame();
        } else {
          gameProvider.remainingTime -= Duration(seconds: 1);
          generateBalloon();
        }
      });
    });
  }

  void generateBalloon() {
    Random random = Random();
    double randomX = random.nextDouble() * (screenWidth - balloonWidth);
    bool popped = random.nextBool();
    balloons.add(
      Balloon(
        x: randomX,
        popped: popped,
        onTap: (isPopped) => handleBalloonPop(isPopped),
      ),
    );
    _animationController.forward();
  }

  void handleBalloonPop(bool isPopped) {
    setState(() {
      if (isPopped) {
        gameProvider.balloonsPopped++;
        gameProvider.score += 2;
      } else {
        gameProvider.balloonsMissed++;
        gameProvider.score -= 1;
      }
    });
  }

  void endGame() {
    setState(() {
      isPlaying = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text(
            "Your final score: ${gameProvider.score}\n"
            "Balloons Popped: ${gameProvider.balloonsPopped}\n"
            "Balloons Missed: ${gameProvider.balloonsMissed}",
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
            TextButton(
              onPressed: startGame,
              child: Text("Play Again"),
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    gameProvider.resetGame();
    balloons.clear();
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Balloon Pop Game"),
      ),
      body: isPlaying
          ? Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Time: ${gameProvider.remainingTime.inMinutes.toString().padLeft(2, '0')}:${gameProvider.remainingTime.inSeconds.remainder(60).toString().padLeft(2, '0')}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Score: ${gameProvider.score}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                for (var balloon in balloons) balloon,
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Balloon Pop Game",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: startGame,
                    child: Text("Start Game"),
                  ),
                ],
              ),
            ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Pop Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}
