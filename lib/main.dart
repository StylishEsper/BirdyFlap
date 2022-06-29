import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return MaterialApp(
      title: 'Birdy Flap',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class Bird extends StatelessWidget
{
  final y;
  final double width;
  final double height;

  Bird({this.y, required this.width, required this.height});

  @override
  Widget build(BuildContext context)
  {
    return Container(
      alignment: Alignment(-0.6, y),
      child: Image.asset(
        "assets/images/penginbird.png",
        width: width * 450,
        height: height * 350,
        fit: BoxFit.fill,
      )
    );
  }
}

class Obstacle extends StatelessWidget
{
  final width;
  final height;
  final x;
  final bool isBottom;

  Obstacle({this.width, this.height, this.x, required this.isBottom});

  @override
  Widget build(BuildContext context)
  {
    return Align(
      alignment: Alignment((2 * x + width) / (2 - width), isBottom ? 1 : -1),
      child: Container(
        color: Colors.brown,
        width: MediaQuery.of(context).size.width * width / 2,
        height: MediaQuery.of(context).size.height * 3 / 4 * height / 1.25,
      )
    );
  }
}

class HomePage extends StatefulWidget
{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  String highScore = "0";

  Future<String> loadData() async
  {
    String text = "";

    try
    {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/player_data.txt');
      text = await file.readAsString();
    }
    catch (e)
    {
      print(e.toString());
    }

    setState(()
    {
      highScore = text;
    });

    return text;
  }

  @override
  void initState()
  {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  color: Colors.blue,
                  child: Stack(
                    children: [
                      const Align(
                        alignment: Alignment(0, -0.25),
                        child: Text('B I R D Y   F L A P',
                            style: TextStyle(color: Colors.purple, fontSize: 30, fontWeight: FontWeight.bold)
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, 0),
                        child: Text('High Score: $highScore',
                            style: const TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold)
                        ),
                      ),
                      Align(
                          alignment: const Alignment(0, 0.7),
                          child: ElevatedButton(
                            onPressed: ()
                            {
                              Navigator.pushAndRemoveUntil<void>(
                                  context,
                                  MaterialPageRoute<void>(builder: (BuildContext context) => const GamePage()),
                                  ModalRoute.withName('/')
                              );
                            },
                            style: ElevatedButton.styleFrom(primary: Colors.yellow),
                            child: const Text(' P L A Y ',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.green,
                      ),
                    ],
                  )
              ),
            ],
          )
    );
  }
}

class GameOverPage extends StatelessWidget
{
  final int score;

  const GameOverPage({Key? key, required this.score}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return WillPopScope(
        onWillPop: () async => false,
         child: Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
           body: Column(
             children: [
               Expanded(
                   child: Container(
                     child: Center(
                       child: Stack(
                         children: [
                            Align(
                             alignment: const Alignment(0, -0.4),
                             child: Text('Score: $score',
                                 style: const TextStyle(color: Colors.white, fontSize: 25)
                             ),
                           ),
                           Align(
                             child: ElevatedButton(
                               onPressed: ()
                               {
                                 Navigator.pushAndRemoveUntil<void>(
                                   context,
                                   MaterialPageRoute<void>(builder: (BuildContext context) => const GamePage()),
                                   ModalRoute.withName('/GamePage')
                                 );
                               },
                               child: const Text('R E T R Y'
                               ),
                             ),
                           ),
                           Align(
                             alignment: const Alignment(0, 0.2),
                             child: ElevatedButton(
                               onPressed: ()
                               {
                                 Navigator.pushAndRemoveUntil<void>(
                                     context,
                                     MaterialPageRoute<void>(builder: (BuildContext context) => const HomePage()),
                                     ModalRoute.withName('/GameOverPage')
                                 );
                               },
                               child: const Text('H O M E'
                               ),
                             ),
                           )
                         ],
                       ),
                     ),
                   )
               )
             ],
           ),
        )
    );
  }
}

class GamePage extends StatefulWidget
{
  const GamePage({Key? key}) : super(key: key);

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
{
  String statusText = "T A P   T O   S T A R T";

  int counter = 0;
  int highScore = 0;

  static double y = 0.1;
  double startY = y;
  double height = 0;
  double time = 0;
  double gravity = -4.9;
  double jumpStrength = 2.5;
  double minY = 1;
  double birdWidth = 0.1;
  double birdHeight = 0.1;
  double pointTime = 0;

  bool gameStarted = false;

  static List<double> obstacleX = [2, 2 + 1.5];
  static double obstacleWidth = 0.3;
  List<List<double>> obstacleHeight = [[0.6, 0.4],[0.4 , 0.6]];

  void incrementCounter()
  {
    setState(()
    {
      counter++;
    });
  }

  void reset()
  {
    counter = 0;

    y = 0.1;
    startY = y;
    height = 0;
    time = 0;
    pointTime = 0;

    obstacleX = [2, 2 + 1.5];
    obstacleHeight = [[0.6, 0.4],[0.4 , 0.6]];
  }

  saveData(String s) async
  {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/player_data.txt');
      await file.writeAsString(s);
  }

  Future<String> loadData() async
  {
    String text = "";

    try
    {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/player_data.txt');
      text = await file.readAsString();
    }
    catch (e)
    {
      print(e.toString());
    }

    setState(()
    {
      highScore = int.parse(text);
    });

    return text;
  }

  void startGame()
  {
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 50), (timer)
    {
      height = gravity * time * time + jumpStrength * time;
      setState(()
      {
        y = startY - height;
      });

      if (gameOver())
      {
        if (counter > highScore)
        {
          saveData(counter.toString());
        }
        timer.cancel();
        gameStarted = false;
      }

      addPoint();
      if (gameStarted) statusText = counter.toString();

      moveMap();
      time += 0.025;
    });
  }

  void moveMap()
  {
    for (int i = 0; i < obstacleX.length; i++)
    {
      setState(()
      {
        obstacleX[i] -= 0.05;
      });

      if (obstacleX[i] < -1.5)
      {
        obstacleX[i] += 3;
        Random r = Random();
        double randomValue = 0.1 + (0.9 - 0.1) * r.nextDouble();
        obstacleHeight[i][0] = randomValue;
        obstacleHeight[i][1] = 1 - randomValue;
      }
    }
  }

  void jump()
  {
    setState(()
    {
      time = 0;
      startY = y;
    });
  }

  void addPoint()
  {
    if (pointTime > 0)
    {
      pointTime -= 0.05;
      return;
    }

    double offsetX = 0.5;
    for (int i = 0; i < obstacleX.length; i++)
    {
      if (obstacleX[i] + offsetX <= birdWidth && obstacleX[i] + offsetX + obstacleWidth >= -birdWidth &&
          y > -1 + obstacleHeight[i][0] + (obstacleHeight[i][0] / 2) &&
              y < 1 - obstacleHeight[i][1] - (obstacleHeight[i][1] / 2))
      {
        setState(()
        {
          counter++;
          pointTime = 1;
        });
      }
    }
  }

  void loadGameOverPage()
  {
    Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) =>
            GameOverPage(score: counter,)));
  }

  bool gameOver()
  {
    if (y > minY)
    {
      y = minY;
      statusText = "";
      loadGameOverPage();
      return true;
    }

    double offsetX = 0.5;

    for (int i = 0; i < obstacleX.length; i++)
    {
      if (obstacleX[i] + offsetX <= birdWidth && obstacleX[i] + offsetX + obstacleWidth >= -birdWidth &&
          (y <= -1 + obstacleHeight[i][0] + (obstacleHeight[i][0] / 2) ||
              y >= 1 - obstacleHeight[i][1] - (obstacleHeight[i][1] / 2)))
      {
        statusText = "";
        loadGameOverPage();
        return true;
      }
    }

    return false;
  }

  String gameStatusText()
  {
    return statusText;
  }

  @override
  void initState()
  {
    super.initState();
    reset();
    loadData();
  }

  @override
  Widget build(BuildContext context)
  {
    return GestureDetector(
      onTap: () => gameStarted ? jump() : startGame(),
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Stack(
                    children: [
                      Bird(
                        y: y,
                        height: birdHeight,
                        width: birdWidth,
                      ),
                      Obstacle(
                        x: obstacleX[0],
                        width: obstacleWidth,
                        height: obstacleHeight[0][0],
                        isBottom: false,
                      ),
                      Obstacle(
                        x: obstacleX[0],
                        width: obstacleWidth,
                        height: obstacleHeight[0][1],
                        isBottom: true,
                      ),
                      Obstacle(
                        x: obstacleX[1],
                        width: obstacleWidth,
                        height: obstacleHeight[1][0],
                        isBottom: false,
                      ),
                      Obstacle(
                        x: obstacleX[1],
                        width: obstacleWidth,
                        height: obstacleHeight[1][1],
                        isBottom: true,
                      ),
                    ],
                  )
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: Colors.green,
                  ),
                  Container(
                    alignment: Alignment(0, -15),
                    child: Text(gameStatusText(),
                        style: const TextStyle(color: Colors.white, fontSize: 20)
                    ),
                  )
                ],
              )
            ),
          ],
        )
      ),
    );
  }
}
