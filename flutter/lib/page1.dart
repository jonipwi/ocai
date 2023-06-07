import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:ocai/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

class MyPage1 extends StatefulWidget {
  const MyPage1({super.key, required this.title});

  final String title;

  @override
  State<MyPage1> createState() => _MyPage1State();
}

class _MyPage1State extends State<MyPage1> {

  TextEditingController QAController = TextEditingController();

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blueAccent,
  ];

  bool showAvg = true;

  late int menuIndex;
  late int btnIndex;

  Barcode? result;
  QRViewController? controller;

  bool isSignIn = false;
  String? hasil = '';
  bool isCamera = false;
  bool isCheckIn = true;

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

  Future<void> postURL(String Url, String data, String page) async {
    if (inPost <= 0) {
      inPost++;

      var map = new Map<String, dynamic>();
      map['data'] = '${data}';

      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded"
      };

      var url = Uri.parse(Url);
      final response = await http.post(
          url, body: map, headers: headers);

      String rawJson = response.body.toString();
      Map<String, dynamic> resi = jsonDecode(rawJson);
      //print('DATA: ${resi['uuid']} -> ${resi['results']} ');
      //ScaffoldMessenger.of(context).showSnackBar(
      //    SnackBar(content: Text('Data: ${resi['results']}')));
      hasil = '';
      if ((resi['uuid'].contains(deviceId)) &&
          (resi['results'].contains('[OK]'))) {
        if ((resi['results'].contains('new uuid created')) ||
            (resi['results'].contains('password matched'))) {
          setState(() {
            isSignIn = true;
          });
        } else {
          setState(() {
            isSignIn = false;
          });
        }
      } else if (resi['results'].contains('[OK]')) {
        if (resi['results'].contains('new uuid created')) {
          setState(() {
            isSignIn = true;
            deviceId = resi['uuid'];
          });
        } else {
          setState(() {
            isSignIn = false;
          });
        }
      }

    }

  }

  Future<Null> AskAI(String deviceid, String q) async {
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

  /**** NOT USING --> SHARE PREFERENCES
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // var deviceData = <String, dynamic>{};
    late String identifier;

    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        identifier = iosDeviceInfo.identifierForVendor; // unique ID on iOS
      } else {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        identifier = androidDeviceInfo.androidId; // unique ID on Android
      }
      /* if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
        } else if (Platform.isWindows) {
          deviceData =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
        }
      }*/
    } on PlatformException {
      identifier = 'Failed';
      /* deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      }; */
    }

    if (!mounted) return;

    setState(() {
      //_deviceData = deviceData;
      //_deviceId = _deviceData["device"];
      _deviceId = identifier;
      print('deviceId : ${_deviceId}');
      deviceId = _deviceId;
      //print('deviceId : ${deviceId}');
    });
  }
  *****/

  Future<String?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? encodedProfile = prefs.getString('profile');
    if (encodedProfile != null) {
      String decoded = utf8.decode(base64.decode(encodedProfile));
      setState(() {
        deviceId = decoded.trim();
      });
      return decoded;
    } else {
      setState(() {
        deviceId = '';
      });
    }
    //print('0.UUID: $deviceId');
    return deviceId;
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  void Initialized() async {
    //deleteProfile();
    var chk = await getProfile();
    if ((chk != null) && (chk.toString().trim().length > 0)) {
      //Post Logging
      inPost = 0;
      await postURL('https://dogemazon.net/ocai/log.php', '${deviceId}', 'PROFILE');
      if (isSignIn) {
        print('1.UUID: $deviceId');
      }
    } else {
      //Generate Id
      String temp = '';
      int i=0;
      while (i < 5) {
        i++;
        if (!isSignIn) {
          temp = await generateRandomString();
          //print('2.UUID: $temp');
          inPost = 0;
          await postURL(
              'https://dogemazon.net/ocai/log.php', '${temp}', 'PROFILE');
        } else {
          i = 10;
        }
      }
      if (isSignIn) {
        deviceId = temp;
        saveProfile('${deviceId}');
        print('3.UUID: $deviceId');
      }
    }

  }

  @override
  void initState() {
    super.initState();
    Initialized();

    startTimer();
    print('Start timer...');
    callPage(0, 'Home');
    askHitReady = false;
    btnIndex = 0;
    menuIndex = 0;
  }

  @override
  void dispose() {
    _timer.cancel();
    controller?.dispose();
    super.dispose();
    print('Exiting timer...');
  }

  @override
  Widget build(BuildContext context) {
    //WidgetsFlutterBinding.ensureInitialized();
    //Wakelock.enable();

    final double width = MediaQuery
        .of(context)
        .size
        .width;
    final double height = MediaQuery
        .of(context)
        .size
        .height;
    final double outrange = 30.0;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          callPage(0, 'Home');
        },
        child: Stack(
            children: [
              (goToPage == 0) ? Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: width,
                  height: height,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(50, 50, 80, 0.9),
                  ),
                ),
              ) : Container(),

              Positioned(
                top: outrange,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Container(
                    width: width - 12,
                    height: headerHeight + titleHeight + buttonHeight +
                        cardHeight,
                    color: Colors.transparent,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Row(
                                      children: [
                                          Text('$deviceId', style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.bold)),
                                        GestureDetector(
                                            onTap: () {
                                              Clipboard.setData(ClipboardData(text: '${deviceId}'));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Ticket copied!')));
                                            },
                                            child: Icon(Icons.copy_all, color: Colors.white70)
                                        ),
                                      ]),
                                      Text('${nickName}', style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                    ]
                                ),
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    'https://dogemazon.net/ocai/default.png',
                                  ),
                                )
                              ]),
                          SizedBox(height: 10),
                          Text('START YOUR', style: TextStyle(
                              fontFamily: 'Righteous',
                              fontSize: 38,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal)),
                          Text('OCAI-3', style: TextStyle(
                              fontFamily: 'Righteous',
                              fontSize: 38,
                              color: Colors.orangeAccent,
                              fontWeight: FontWeight.normal)),
                          Text('JOURNEY', style: TextStyle(
                              fontFamily: 'Righteous',
                              fontSize: 38,
                              color: Colors.white70,
                              fontWeight: FontWeight.normal)),

                          SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      menuIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    width: (width - 40) / 3,
                                    height: 30,
                                    //color: Color.fromRGBO(250, 250, 250, 0.9),
                                    decoration: BoxDecoration(
                                      color: (menuIndex == 0) ? Colors.orangeAccent : Color.fromRGBO(250, 250, 250, 0.9),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(0,
                                              3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text('All'),
                                    )
                                  ),
                                ),

                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      menuIndex = 1;
                                    });
                                  },
                                  child: Container(
                                    width: (width - 40) / 3,
                                    height: 30,
                                    //color: Color.fromRGBO(250, 250, 250, 0.9),
                                    decoration: BoxDecoration(
                                      color: (menuIndex == 1) ? Colors.orangeAccent : Color.fromRGBO(250, 250, 250, 0.9),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20)
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: Offset(
                                              0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text('Flesh'),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        menuIndex = 2;
                                      });
                                    },
                                    child: Container(
                                      width: (width - 40) / 3,
                                      height: 30,
                                      //color: Color.fromRGBO(250, 250, 250, 0.9),
                                      decoration: BoxDecoration(
                                        color: (menuIndex == 2) ? Colors.orangeAccent : Color.fromRGBO(250, 250, 250, 0.9),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: Offset(
                                                0, 3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text('Spirit'),
                                      ),
                                    )
                                ),

                              ]),

                          //------ Card Practicer --------
                          SizedBox(height: 10),
                          Container(
                            color: Colors.transparent,
                            width: width - 12,
                            height: 200,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: (menuIndex == 0) ? Row(
                                children: [
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/eat2.jpeg', status: '4 hours ago', title: 'Eat Healthy', description: 'Balance & Healthy'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/exercise.png', status: '3 days ago', title: 'Body Exercise', description: 'Walking & Jogging'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/sleep2.jpg', status: '8 hours ago', title: 'Sleep Comfort', description: 'Relaxing & Recovering'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/yoga.jpeg', status: '12 hours ago', title: 'Pray Meditation', description: 'Faith & Relationship'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/reading1.jpg', status: '5 hours ago', title: 'Wisdom Knowledge', description: 'Reading & Listening'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/love1.png', status: '1 week ago', title: 'Loving Cares', description: 'Charity Love & Kindness'),
                                ],
                              ) : (menuIndex == 1) ? Row(
                                children: [
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/eat2.jpeg', status: '4 hours ago', title: 'Eat Healthy', description: 'Balance & Healthy'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/exercise.png', status: '3 days ago', title: 'Body Exercise', description: 'Walking & Jogging'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/sleep2.jpg', status: '8 hours ago', title: 'Sleep Comfort', description: 'Relaxing & Recovering'),
                                ],
                              ) : (menuIndex == 2) ? Row(
                                children: [
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/yoga.jpeg', status: '12 hours ago', title: 'Pray Meditation', description: 'Faith & Relationship'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/reading1.jpg', status: '5 hours ago', title: 'Wisdom Knowledge', description: 'Reading & Listening'),
                                  CustomWidget(color: Color.fromRGBO(250, 250, 250, 0.9), width: cardWidth, height: cardHeight,
                                      image: 'https://dogemazon.net/ocai/love1.png', status: '1 week ago', title: 'Loving Cares', description: 'Charity Love & Kindness'),
                                ],
                              ) : Container(),
                            ),
                          ),

                          SizedBox(height: 20),
                          Center(
                              child: Text('This version is for Educational Purposes.', style: TextStyle(color: Colors.white))
                          ),
                          Center(
                            child: Text('version $versi', style: TextStyle(color: Colors.white))
                          )
                        ]),
                  ),
                ),
              ),

              Positioned(
                bottom: 20,
                left: 20,
                child: Container(
                  width: width - 40,
                  height: 60,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 250, 240, 0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30)
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
                  child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5, left: 30, right: 30),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  btnIndex = 0;
                                });
                                print(btnIndex);
                              },
                              child: (btnIndex == 0)
                                  ? Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/home3.svg',
                                  color: Colors.orangeAccent,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/home3.svg',
                                  color: Color.fromRGBO(190, 190, 190, 0.9),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  btnIndex = 1;
                                });
                                print(btnIndex);
                              },
                              child: (btnIndex == 1)
                                  ? Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/network2.svg',
                                  color: Colors.orangeAccent,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/network2.svg',
                                  color: Color.fromRGBO(190, 190, 190, 0.9),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  btnIndex = 2;
                                });
                                print(btnIndex);
                                GPTDialogue();
                              },
                              child: (btnIndex == 2)
                                  ? Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/chatgptbtn.svg',
                                  color: Colors.orangeAccent,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/chatgptbtn.svg',
                                  color: Color.fromRGBO(190, 190, 190, 0.9),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  btnIndex = 3;
                                });
                                print(btnIndex);
                              },
                              child: (btnIndex == 3)
                                  ? Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/user3.svg',
                                  color: Colors.orangeAccent,
                                  fit: BoxFit.cover,
                                ),
                              )
                                  : Container(
                                width: iconWidth,
                                height: iconHeight,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: SvgPicture.network(
                                  'https://dogemazon.net/ocai/user3.svg',
                                  color: Color.fromRGBO(190, 190, 190, 0.9),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                          ]
                      )
                  ),
                ),
              ),

              //----GPT Chat Assistance
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

              (goToPage == 66) ? Positioned(
                bottom: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    GPTDialogue();
                  },
                  child: Container(
                    width: 52.0,
                    height: 52.0,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(240, 250, 240, 0.6),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(0)
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
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: SvgPicture.network(
                        'https://dogemazon.net/ocai/chatgptbtn.svg',
                        color: Color.fromRGBO(90, 150, 90, 0.9),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ) : Container(),

            ]),
      ),

    );
  }

  //------------- Functions
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
        text = Text('Flesh', style: style);
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
        text = Text('Spirit', style: style);
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

class CustomWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String title;
  final String description;
  final String status;
  final String image;

  const CustomWidget({Key? key, required this.width, required this.height, required this.color,
    required this.title, required this.description, required this.status, required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 10, top: 5),
      child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)
            ),
            image: DecorationImage(
              image: NetworkImage('$image'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Container(
                      width: (width - 10) / 2,
                      height: 24,
                      //color: Colors.red,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(220, 180, 50, 0.9),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                      ),
                      child: Center(
                        child: Text('$status', style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
                ],
              ),
              Container(),
              Container(
                  width: width,
                  height: 42,
                  //color: Colors.red,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(210, 210, 210, 0.8),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' $title',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14)),
                          Text(' ${description}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: Colors.black54)),
                        ],
                      )
                    ]),
                ),
              ),
            ],
          )
      ),

    );
  }
}
