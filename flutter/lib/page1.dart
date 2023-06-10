import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'dart:io' show File, Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:ocai/widgets.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';

class MyPage1 extends StatefulWidget {
  const MyPage1({super.key, required this.title});

  final String title;

  @override
  State<MyPage1> createState() => _MyPage1State();
}

enum TtsState { playing, stopped, paused, continued }

class _MyPage1State extends State<MyPage1> {

  late FlutterTts flutterTts;
  String? language = 'en-AU';
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;

  TtsState ttsState = TtsState.stopped;

  get isPlaying => ttsState == TtsState.playing;
  get isStopped => ttsState == TtsState.stopped;
  get isPaused => ttsState == TtsState.paused;
  get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

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
            dateToday = DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.now().toString());
          });
        }
      },
    );
  }

  final ImagePicker _picker = ImagePicker();

  List<XFile>? _imageFileList;
  dynamic _pickImageError;
  void _setImageFileListFromFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }
  static final String uploadEndPoint = 'https://dogemazon.net/ocai/upload.php';
  late Future<File> file;
  String status = '';
  late String base64Image;
  late File tmpFile;
  String errMessage = 'Error Uploading Image';

  /*Future<void> captureAndUploadImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Upload the image to the backend
      uploadImage(pickedFile.path);
    }
  }*/

  /** Future<XFile?> resizeImage(File imageFile) async {
    final targetWidth = 16 * 100; // 16 times 100 (arbitrary scale factor)
    final targetHeight = 9 * 100; // 9 times 100 (arbitrary scale factor)

    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final tempFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final tempFilePath = '$tempPath/$tempFileName';

    final resizedImage = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      tempFilePath,
      quality: 90, // Adjust the quality as needed
      minHeight: targetHeight,
      minWidth: targetWidth,
    );

    return resizedImage;
  } **/

  Future<XFile> convertPickedFileToXFile(PickedFile pickedFile) async {
    final String originalPath = pickedFile.path;
    final String directory = (await getTemporaryDirectory()).path;
    final String newFilePath = join(directory, basename(originalPath));

    await File(originalPath).copy(newFilePath);

    return XFile(newFilePath);
  }

  setFileParent() async {
    // Pick an image.
    try {
      /*final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );*/

      // Pick an image.
      //final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      // Capture a photo.
      //final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      // Pick a video.
      //final XFile? galleryVideo = await _picker.pickVideo(source: ImageSource.gallery);
      // Capture a video.
      //final XFile? cameraVideo = await _picker.pickVideo(source: ImageSource.camera);
      // Pick multiple images.
      //final List<XFile> images = await _picker.pickMultiImage();

      PickedFile? pickedFile = await ImagePicker().getImage(
          source: ImageSource.camera,
          maxHeight: 512,
          maxWidth: 512,
      );
      if (pickedFile != null) {
        File photo = File(pickedFile.path);
        //final resizedImage = await resizeImage(File(pickedFile!.path));
        //final XFile xFile = await convertPickedFileToXFile(photo!);
        if (photo != null) {
          // Upload the image to the backend
          //uploadImage(pickedFile.path);

          setState(() {
            //_setImageFileListFromFile(photo);
            tmpFile = File(photo!.path);
            base64Image = base64Encode(tmpFile.readAsBytesSync());
          });
        }
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });
    }

    //ScaffoldMessenger.of(context).showSnackBar(
    //    const SnackBar(content: Text('Force edit photo')));

    startUpload();
  }

  setStatus(String message) {
    setState(() {
      status = message;
      print(status);
    });
  }

  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    print(fileName);
    upload(fileName);
  }

  upload(String fileName) {
    http.post(
        Uri.parse(uploadEndPoint),
        body: {
          "image": base64Image,
          "name": fileName,
          "deviceid": deviceId,
        }
    ).then((result) {
      print(result.body.toString());
      if (result.statusCode == 200) {
        setState(() {
          final data = jsonDecode(result.body);
          print(' ${data['avatar']} \n ${data['message']}');
          if (data['avatar'] != '') bioAvatar = data['avatar'];
        });
      }
      setStatus(result.statusCode == 200 ? result.body : errMessage);
    }).catchError((error) {
      setStatus(error);
    });
  }

  Future<void> postURL(String Url, String data, String page) async {
    if (inPost <= 0) {
      inPost++;

      Map<String, String> qParams = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${serverToken}',
        'x-device': '${deviceId}',
        'x-target': '${data}',
      };

      var map = new Map<String, dynamic>();
      map['data'] = '${data}';

      Map<String, String> headers = {
        "Content-Type": "application/x-www-form-urlencoded"
      };

      var url = Uri.parse(Url);
      final response = await http.post(
          url, body: map, headers: qParams);

      String rawJson = response.body.toString();
      if (rawJson.toLowerCase().contains('error')) {
        BuildContext? context = navigatorKey.currentContext;
        ScaffoldMessenger.of(context!).showSnackBar(
            SnackBar(content: Text('raw: ${rawJson}')));
      }
      Map<String, dynamic> resi = jsonDecode(rawJson);
      //print('DATA: ${resi['uuid']} -> ${resi['results']} ');
      hasil = '';
      if ((resi['uuid'].contains(deviceId)) &&
          (resi['results'].contains('[OK]'))) {
        if ((resi['results'].contains('new uuid created')) ||
            (resi['results'].contains('password matched'))) {
          setState(() {
            isSignIn = true;
            bioAvatar = resi['avatar'];
            String decoded = utf8.decode(base64.decode(resi['api']));
            AIKEY = decoded;
            follower = resi['follower'];
            following = resi['following'];
            posting = resi['posting'];
          });
        } else {
          setState(() {
            isSignIn = false;
            AIKEY = '';
            follower = 0;
            following = 0;
            posting = 0;
          });
        }
      } else if (resi['results'].contains('[OK]')) {
        if (resi['results'].contains('new uuid created')) {
          setState(() {
            isSignIn = true;
            deviceId = resi['uuid'];
            bioAvatar = resi['avatar'];
            String decoded = utf8.decode(base64.decode(resi['api']));
            AIKEY = decoded;
            follower = resi['follower'];
            following = resi['following'];
            posting = resi['posting'];
          });
        } else {
          setState(() {
            isSignIn = false;
            AIKEY = '';
            follower = 0;
            following = 0;
            posting = 0;
          });
        }
      }

    }

  }

  //--------- TTS
  void initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    if (isAndroid) {
      flutterTts.setInitHandler(() {
        setState(() {
          print("TTS Initialized");
        });
      });
    }

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future ttsPause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  Future<void> recordAudio(BuildContext context) async {
    final record = Record();
    final mypath = await getDirPath("temp");
    print(mypath);
    // Check and request permission
    if (await record.hasPermission()) {
      // Get the state of the recorder
      bool isRecording = await record.isRecording();
      setState(() {
        micOn = isRecording;
      });

      if (isRecording) {
        // Stop recording
        await record.stop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stop record audio.')),
        );
      } else {
        // Start recording
        await record.start(
          path: '${mypath}/myOpenAI.m4a',
          encoder: AudioEncoder.aacLc, // by default
          bitRate: 128000, // by default
          samplingRate: 44100, // by default
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Start record audio')),
        );
      }
    }
  }

  Future<String> convertSpeechToText(String apiKey, String filePath) async {
    try {
      var url = Uri.https("api.openai.com", "v1/audio/transcriptions");
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(({"Authorization": "Bearer $apiKey"}));
      request.fields["model"] = 'whisper-1';
      request.fields["language"] = "en";
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      var response = await request.send();
      var newresponse = await http.Response.fromStream(response);
      final responseData = json.decode(newresponse.body);

      return responseData['text'];
    } catch(e) {
      return 'error';
    }
  }

  void ttsParentSpeak(String text) {
    ttsStop();
    Future.delayed(const Duration(milliseconds: 500), () {
      ttsSpeak(text!);
    });
  }

  Future ttsStop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future ttsSpeak(String text) async {
    //await flutterTts.setLanguage('en-AU');
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text!.isNotEmpty) {
        await flutterTts.speak(text!);
      }
    }
  }

  void setAudioParent(BuildContext context) async {
    await ttsStop();

    QAResult = '';

    await recordAudio(context);

    String apiKey = "${AIKEY}";
    convertSpeechToText(apiKey, '${tempPath}/myOpenAI.m4a').then((value) {
      //print(value);
      if (!value.toLowerCase().contains('error')) {
        Future.delayed(const Duration(milliseconds: 500), () {
          ttsSpeak(value!);
        });

        setState(() {
          QAResult = '${value}';
          bioDes = '${value}';
        });
      }
    });
  }

  Future<Null> verseTodayAI(String deviceid, String q) async{

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
    String fetchRequestUrl = "https://dogemazon.net/ocai/verse.php?q=${encoded}";
    try {
      final responseData = await http.get(
          Uri.parse(fetchRequestUrl),
          headers: qParams
      );
      if (responseData.statusCode == 200) {
        //print(responseData.body);
        dtVerseToday = DateTime.now();
        final data = responseData.body.split('|');
        String decoded = utf8.decode(base64.decode(data[1]));
        setState(() {
          Result = decoded;
          Answer = Result;
          loading = false;
          verseToday = decoded;
        });
        print('$verseToday');
        ttsParentSpeak('$verseToday');
      }
    } catch (e) {
      print('Verse Today: Error Http!');
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

  void setFollowParent(String fid) {
    inPost = 0;
    //print('$deviceId:$fid');
    String encoded = base64.encode(utf8.encode('$deviceId:$fid'));
    postURL('https://dogemazon.net/ocai/follow.php', '$encoded', 'FOLLOW');
  }
  void gotoParentMenu(int menu) {
    setState(() {
      menuIndex = menu;
    });
  }

  void callPage(int page, String title) {
    setState(() {
      if (page == 0) btnIndex = 0;
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
    initTts();
    micOn = true;
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
    flutterTts.stop();
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
              Positioned(
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
              ),

              Positioned(
                top: outrange,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Container(
                    width: width - 12,
                    height: headerHeight + titleHeight + buttonHeight +
                        cardHeight + (outrange * 2),
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      btnIndex = 3;
                                    });
                                    print(btnIndex);
                                    callPage(33, 'Profile');
                                  },
                                  child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white54,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20)
                                        ),
                                      ),
                                      child: (bioAvatar!.contains('.svg')) ? SvgPicture.network(
                                        '$bioAvatar',
                                        color: Color.fromRGBO(190, 190, 190, 0.9),
                                        fit: BoxFit.cover,
                                      ) : CircleAvatar(
                                        backgroundImage: NetworkImage('$bioAvatar'),
                                      ),
                                  ),
                                  /** CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      'https://dogemazon.net/ocai/default.png',
                                    ),
                                  ), **/
                                ),
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

              (btnIndex > 0) ? Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: width,
                  height: height,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(10, 10, 10, 0.7),
                  ),
                ),
              ) : Container(),

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
                                callPage(0, 'Home');
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
                                verseTodayAI('${deviceId}','Please give me only 1 of quotes for today meditation');
                                callPage(11, 'Community');
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
                                callPage(33, 'Profile');
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

              //----Community
              (goToPage == 11) ? Positioned(
                top: outrange + 30,
                left: 20,
                child: Container(
                  width: width - 40,
                  height: height - outrange - 120,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 250, 240, 0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(33),
                        topRight: Radius.circular(33),
                        bottomLeft: Radius.circular(33),
                        bottomRight: Radius.circular(33)
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
                  child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(13),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Community', style: TextStyle(fontFamily: 'Righteous', color: Colors.black, fontSize: 20)),
                                GestureDetector(
                                  onTap: () {
                                    //postUpload();
                                  },
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: Colors.orangeAccent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(13),
                                          topRight: Radius.circular(13),
                                          bottomLeft: Radius.circular(13),
                                          bottomRight: Radius.circular(13)
                                      ),
                                    ),
                                    child: SvgPicture.network(
                                      'https://dogemazon.net/ocai/share.svg',
                                      color: Colors.black,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ]),
                        ),

                        Container(
                          width: width - 40,
                          height: height - outrange - 200,
                          child: SingleChildScrollView(
                            child: Column(
                                children: [
                                  CardWidget(width: width, height: height, color: Colors.white, ttsParentSpeak: ttsParentSpeak,
                                    avatar: '$bioAvatar', nick: '$nickName', gotoParentMenu: gotoParentMenu, creator: '4RAH1-L4MT9-PLZ7V-0E5HB',
                                    timestamp: DateDiff(dateToday.toString(), dtVerseToday.toString()), story: '$verseToday', setFollowParent: setFollowParent,
                                    image: '', tag: '#meditation #pray #spiritual', datastr: '31,11,6,25',
                                  ),

                                  CardWidget(width: width, height: height, color: Colors.white, ttsParentSpeak: ttsParentSpeak, setFollowParent: setFollowParent,
                                    avatar: 'https://dogemazon.net/ocai/me.jpg', nick: '$nickName', gotoParentMenu: gotoParentMenu, creator: 'ETKN0-QRDU2-15NI6-0VQE0',
                                    timestamp: '1 mins ago', story: 'For God hath not given us the spirit of fear; but of power, and of love, and of a sound mind. 2 Timothy 1:7',
                                    image: 'https://www.worldchallenge.org/sites/default/files/210707-pc-web.jpg', tag: '#meditation #pray #spiritual', datastr: '51,1,9,210',
                                  ),

                                ]),
                          ),
                        ),
                      ]),
                ),
              ) : Container(),

              //----Profile
              (goToPage == 33) ? Positioned(
                top: outrange + 50,
                left: 20,
                child: Container(
                  width: width - 40,
                  height: height - outrange - 150,
                  //color: Color.fromRGBO(250, 250, 250, 0.9),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(240, 250, 240, 0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(33),
                        topRight: Radius.circular(0),
                        bottomLeft: Radius.circular(33),
                        bottomRight: Radius.circular(33)
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
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setFileParent();
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white54,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40),
                                        topRight: Radius.circular(40),
                                        bottomLeft: Radius.circular(40),
                                        bottomRight: Radius.circular(40)
                                    ),
                                  ),
                                  child: (bioAvatar!.contains('.svg')) ? SvgPicture.network(
                                    '$bioAvatar',
                                    color: Color.fromRGBO(190, 190, 190, 0.9),
                                    fit: BoxFit.cover,
                                  ) : CircleAvatar(
                                    backgroundImage: NetworkImage('$bioAvatar'),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setFileParent();
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 56, left: 56),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12)
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(2),
                                    child: SvgPicture.network(
                                      'https://dogemazon.net/ocai/camera.svg',
                                      color: Colors.black,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                            ]),
                        SizedBox(height: 10),
                        Text(
                          '$nickName',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: '${deviceId}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Ticket copied!')));
                          },
                          child: Text(
                            '$deviceId',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        QrImageView(
                          data: '${deviceId}',
                          version: QrVersions.auto,
                          size: 150,
                          gapless: false,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Followers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '$follower',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Following',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '$following',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Posts',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '$posting',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$bioDes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            // Handle edit button press
                            print('0.Audio');
                            setAudioParent(context);
                          },
                          child: Container(
                            width: 100,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)
                              ),
                            ),
                            child: Center(
                              child: Row(
                                  children:[
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle edit button press
                                        print('1.Audio');
                                        setAudioParent(context);
                                      },
                                      child: Icon((micOn) ? Icons.mic_off : Icons.mic),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        // Handle edit button press
                                        print('2.Audio');
                                        setAudioParent(context);
                                      },
                                      child: Text(' Edit Bio'),
                                    ),
                                  ]),
                            ),
                          ),
                        ),
                        SizedBox(height: 50),

                      ],
                    ),
                  ),
                ),
              ) : Container(),

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

  const CustomWidget(
      {Key? key, required this.width, required this.height, required this.color,
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
                  padding: EdgeInsets.only(
                      left: 5, right: 5, top: 2, bottom: 2),
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
                                style: TextStyle(fontSize: 11, color: Colors
                                    .black54)),
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

class CardWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final String avatar;
  final String nick;
  final String timestamp;
  final String image;
  final String story;
  final String tag;
  final String datastr;
  final String creator;
  final Function gotoParentMenu;
  final Function ttsParentSpeak;
  final Function setFollowParent;

  CardWidget({Key? key, required this.width, required this.height, required this.color, required this.ttsParentSpeak,
    required this.avatar, required this.nick, required this.timestamp, required this.image, required this.creator,
    required this.story, required this.tag, required this.datastr, required this.gotoParentMenu, required this.setFollowParent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = datastr.split(',');

    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: Container(
        width: width,
        //height: height,
        //color: Color.fromRGBO(250, 250, 250, 0.9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
              bottomLeft: Radius.circular(13),
              bottomRight: Radius.circular(13)
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      //Profile
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)
                          ),
                        ),
                        child: (avatar.contains('.svg')) ? SvgPicture.network(
                          '$avatar',
                          color: Color.fromRGBO(190, 190, 190, 0.9),
                          fit: BoxFit.cover,
                        ) : CircleAvatar(
                          backgroundImage: NetworkImage('$avatar'),
                        ),
                      ),
                      Text(' $nick', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  //Time
                  Text('$timestamp', style: TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              SizedBox(height: 3),
              (image.length > 0) ? Container(
                  width: width,
                  height: width * 9/16,
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)
                    ),
                    image: DecorationImage(
                      image: NetworkImage('$image'),
                      fit: BoxFit.cover,
                    ),
                  )
              ) : Container(),
              Container(
                child: Text('$story',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
              SizedBox(height: 3),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$tag', style: TextStyle(fontSize: 11, color: Colors.blueAccent, fontStyle: FontStyle.italic)),
                  ]
              ),
              SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //Button Like
                  GestureDetector(
                    onTap: (){
                      //gotoParentMenu(0);
                      setFollowParent('$creator');
                    },
                    child: Container(
                        width: (width - 40) / 5,
                        height: 30,
                        //color: Color.fromRGBO(250, 250, 250, 0.9),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_up_alt_outlined, color: Colors.black54, size: 16),
                            Text(' ${data[0]}', style: TextStyle(color: Colors.black54, fontSize: 11)),
                          ],
                        )
                    ),
                  ),
                  //Button Dislike
                  GestureDetector(
                    onTap: (){
                      //gotoParentMenu(0);
                      setFollowParent('$creator');
                    },
                    child: Container(
                        width: (width - 40) / 5,
                        height: 30,
                        //color: Color.fromRGBO(250, 250, 250, 0.9),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.thumb_down_alt_outlined, color: Colors.black54, size: 16),
                            Text(' ${data[1]}', style: TextStyle(color: Colors.black54, fontSize: 11)),
                          ],
                        )
                    ),
                  ),
                  //Button Comment
                  GestureDetector(
                    onTap: (){
                      //gotoParentMenu(0);
                      setFollowParent('$creator');
                      Future.delayed(const Duration(milliseconds: 500), () {
                        ttsParentSpeak('$story');
                      });
                    },
                    child: Container(
                        width: (width - 40) / 5,
                        height: 30,
                        //color: Color.fromRGBO(250, 250, 250, 0.9),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment_outlined, color: Colors.black54, size: 16),
                            Text(' ${data[2]}', style: TextStyle(color: Colors.black54, fontSize: 11)),
                          ],
                        )
                    ),
                  ),
                  //Button Share
                  GestureDetector(
                    onTap: (){
                      //gotoParentMenu(0);
                      setFollowParent('$creator');
                    },
                    child: Container(
                        width: (width - 40) / 5,
                        height: 30,
                        //color: Color.fromRGBO(250, 250, 250, 0.9),
                        decoration: BoxDecoration(
                          color: btnColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20)
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.question_answer_outlined, color: Colors.black54, size: 16),
                            Text(' ${data[3]}', style: TextStyle(color: Colors.black54, fontSize: 11)),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
