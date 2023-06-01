import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'widgets.dart';
import 'globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ocai - AP68',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ocai AP68'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController QAController = TextEditingController();

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blueAccent,
  ];

  bool showAvg = true;
  late Timer _timer;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (i == 0) {
          setState(() {
            //timer.cancel();
            i = 3;
          });
        } else {
          setState(() {
            i--;
            //------ get datetime -----
            DateTime dateToday = new DateTime.now();
          });
        }
      },
    );
  }

  Future<Null> AskAI(String deviceid, String q) async{

    Map<String, String> qParams = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${serverToken}',
      'x-device': '${deviceid}',
      'x-target': '${q}',
    };

    setState(() {
      loading = true;
    });

    String encoded = base64.encode(utf8.encode(q));
    String fetchRequestUrl = "https://dogemazon.net/ocai/gpt.php?cmd=prompt&q=${encoded}";
    try {
      final responseData = await http.get(
          Uri.parse(fetchRequestUrl),
          headers: qParams
      );
      if (responseData.statusCode == 200) {
        //print(responseData.body);
        final data = responseData.body.split('|');
        String decoded = utf8.decode(base64.decode(data[1]));
        setState(() {
          Result = decoded;
          Answer = Result;
          loading = false;
          String smean = decoded.split('Mean: ')[1];
          mean = double.parse(smean.split(',')[0]);
          String sstd = decoded.split('Std: ')[1];
          std = double.parse(sstd.split(',')[0]);
        });
        print('$Answer \n$mean $std');
      }
    } catch (e) {
      print('Answer: Error Http!');
    }

  }

  void callPage(int page, String title) {
    setState(() {
      goToPage = page;
      titlePage = title;
      askHitReady = (page == 66);
    });
    print('Page: ${goToPage} - ${title}');
  }

  void GPTDialogue() {
    if (askHitReady == true) {
      setState(() {
        Question = '${QAController.text}';
        Result = '';
        Answer = '';
        AskAI('${deviceId}', '${Question}');
      });
    } else {
      setState(() {
        QAController.clear();
        Question = '';
        Result = '';
        Answer = '';
      });
    }
    callPage(66, 'GPT Dialogue');
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    print('Start timer...');
    callPage(0, 'Ocai');
    askHitReady = false;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
    print('Exiting timer...');
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double outrange = 30.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          callPage(0, 'Ocai');
        },
        child: Stack(
            children: [
              Positioned(
                top: outrange,
                left: 0,
                child: Container(
                  color: Colors.white,
                  width: width,
                  height: height - outrange,
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Welcome Ocai',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Project 68AP',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                            //child: Flexible(
                            child: Text('Introducing "Project 68AP" - Unleashing the Power of Self-Evaluation for Church and Personal Growth!'),
                            //),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                            //child: Flexible(
                            child: Text('Step into a groundbreaking project that will revolutionize the way churches assess their spiritual progress, bridging the gap between the physical and the divine. Prepare to embark on an exhilarating journey of self-discovery and transformation as you evaluate your position on the path to enlightenment using our cutting-edge indicator.'),
                            //),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                            //child: Flexible(
                            child: Text('Gone are the days of uncertainty and guesswork; our meticulously crafted mathematic formula, based on the standard deviation, will serve as your compass towards a better life. We are proud to present a new and attainable approach that empowers both churches and individuals to unlock their full potential.'),
                            //),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                            //child: Flexible(
                            child: Text('Dare to dream bigger, for we firmly believe that with our revolutionary method, each and every one of you has the potential to achieve a remarkable 68% or more from the coveted target point. Allow us to unveil the extraordinary "Project 68AP" - a catalyst for personal growth and a testament to the incredible heights you can reach.'),
                            //),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                            //child: Flexible(
                            child: Text('For in this endeavor, we honor the Kingdom, embrace the Power, and celebrate the everlasting Glory. Join us on this awe-inspiring expedition, where miracles become reality. Forever Amen!'),
                            //),
                          ),

                          Divider(),
                          Center( child: Text('(C)opyright 2023. Ocai Team & Community')),
                          Center( child: Text('Version ${versi}')),
                          Center( child: Text('https://github.com/jonipwi/ocai.git')),

                          SizedBox(height: 100),
                        ]),
                  ),
                ),
              ),

              (goToPage == 66) ? Positioned(
                bottom: 15,
                left: 20,
                child: Container(
                    width: width - 40 - 66,
                    height: 55,
                    //color: Color.fromRGBO(250, 250, 250, 0.9),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 250, 240, 0.9),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Container(
                      child: TextField(
                        controller: QAController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Describe your story here',
                        ),
                      )
                    )
                ),
              ) : Container(),

              (goToPage == 66) ? Positioned(
                top: outrange + 20,
                left: 20,
                child: Container(
                  width: width - 40,
                  height: height - outrange - 100,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 250, 240, 0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                      physics: ScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              width: width - 40,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(50, 100, 50, 0.8),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  //bottomLeft: Radius.circular(10),
                                  //bottomRight: Radius.circular(10)
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                                child: Center(
                                  child: Text('${titlePage}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              )
                          ),

                          Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 0, left: 5, right: 5),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle_notifications, color: Colors.blueGrey, size: 20),
                                      Container(
                                        child: Text('Hello, how may I help you?'),
                                      ),
                                    ],
                                  ),

                                ],
                              )
                          ),

                          (Question!.length > 0) ? Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 0, left: 5, right: 5),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        child: Flexible(
                                          child: Text('${Question}'),
                                        ),
                                      ),
                                      Icon(Icons.account_circle_rounded, color: Colors.blueGrey, size: 20),
                                    ],
                                  ),

                                ],
                              )
                          ) : Container(),

                          (Answer!.length > 0) ? Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle_notifications, color: Colors.blueGrey, size: 20),
                                      Container(
                                        child: Flexible(
                                          child: Text('${Answer}'),
                                        ),
                                      ),
                                    ],
                                  ),

                                  //-----------Result Graph------------
                                  AspectRatio(
                                    aspectRatio: 1.70,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 18,
                                        left: 12,
                                        top: 24,
                                        bottom: 12,
                                      ),
                                      child: LineChart(
                                        avgData(),
                                      ),
                                    ),
                                  ),

                                ],
                              )
                          ) : (loading == true) ? Padding(
                              padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.circle_notifications, color: Colors.blueGrey, size: 20),
                                      JumpingDotsProgressIndicator(
                                          numberOfDots: 3,
                                      ),
                                    ],
                                  ),

                                ],
                              )
                          ) : Container(),

                        ],
                      )
                  ),
                ),
              ): Container(),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: GPTDialogue,
        tooltip: 'GPT Dialogue',
        child: Container(
          width: 66.0,
          height: 66.0,
          decoration: BoxDecoration(
            color: Colors.transparent,
            //const Color(0xff7c94b6),
            image: DecorationImage(
              image: Svg(
                color: Color.fromRGBO(190, 190, 190, 0.3),
                source: SvgSource.network,
                'https://dogemazon.net/ocai/gptbtn.svg',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        drawVerticalLine: true,
        horizontalInterval: 0.5,
        verticalInterval: (3-0.0),
        //checkToShowHorizontalLine: (value) {
        //  return value.toInt() == 0;
        //},
        getDrawingHorizontalLine: (_) => FlLine(
          color: Colors.blue,
          dashArray: [8, 2],
          strokeWidth: 0.8,
        ),
        getDrawingVerticalLine: (_) => FlLine(
          color: Colors.blue,
          dashArray: [8, 2],
          strokeWidth: 0.8,
        ),
        //checkToShowVerticalLine: (value) {
        //  return value.toInt() == 0;
        //},
      ),

      /* gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ), */
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 1,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, 0.0),
            FlSpot(1, 0.021),
            FlSpot(2, 0.136),
            FlSpot(3, 0.999),
            FlSpot(4, 0.136),
            FlSpot(5, 0.021),
            FlSpot(6, 0.0),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 11,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('${(mean! - (std! * 3)).toStringAsFixed(2)}', style: style);
        break;
      case 1:
        text = Text('${(mean! - (std! * 2)).toStringAsFixed(2)}', style: style);
        break;
      case 2:
        text = Text('${(mean! - (std! * 1)).toStringAsFixed(2)}', style: style);
        break;
      case 3:
        text = Text('${(mean!).toStringAsFixed(2)}', style: style);
        break;
      case 4:
        text = Text('${(mean! + (std! * 1)).toStringAsFixed(2)}', style: style);
        break;
      case 5:
        text = Text('${(mean! + (std! * 2)).toStringAsFixed(2)}', style: style);
        break;
      case 6:
        text = Text('${(mean! + (std! * 3)).toStringAsFixed(2)}', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0.0';
        break;
      case 0.5:
        text = '0.5';
        break;
      case 1:
        text = '1.0';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

}
