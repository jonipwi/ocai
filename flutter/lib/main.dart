import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';


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

  void GPTDialogue() {
    print('GPT Dialogue');
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final double outrange = 30.0;

    return Scaffold(
      body: Stack(
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
                        Center( child: Text('https://github.com/jonipwi/ocai.git')),

                        SizedBox(height: 100),
                      ]),
                  ),
                ),
              ),

          ]),
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
}
