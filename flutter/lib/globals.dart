import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

String? Question = '';
String? Answer = '';
String? Result = '';
String? postText = '';
String? nickName = '{anonymous}';
String? deviceId = '';
String? bioDes = 'Beauty enthusiast | ChatGPT nerd | Sharing my passion for good ';
String? bioAvatar = 'https://dogemazon.net/ocai/user3.svg';
int follower = 0;
int following = 0;
int posting = 0;

List<Story> listStory = [];
int inPost = 0;
bool loading = false;
bool askHitReady = false;
bool micOn = false;
bool muteOn = false;
String AIKEY = '';
String QAResult = '';
String? titlePage = 'Project 68AP';
int goToPage = 0;
int i = 0;
double mean = 0.0;
double std = 0.0;
String tempPath = '';
String appDocPath = '';
String verseToday = '';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const btnColor = Color.fromRGBO(230, 230, 230, 0.9);

const versi = '3.17.0+17';
const serverToken = "[SERVER_BASE_API_TOKEN]";

const double cardWidth = 166;
const double cardHeight = 300;
const double headerHeight = 50;
const double titleHeight = 100;
const double buttonHeight = 50;

const double iconWidth = 28;
const double iconHeight = 28;

DateTime dtVerseToday = DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.now().toString());
DateTime dateToday = DateFormat("yyyy-MM-dd HH:mm:ss").parse(DateTime.now().toString());

String DateDiff(String date1, String date2) {

  DateTime datetime1 = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date1);
  DateTime datetime2 = DateFormat("yyyy-MM-dd HH:mm:ss").parse(date2);

  Duration timeDiff = datetime2.difference(datetime1);

  int days = timeDiff.inDays;
  int hours = (timeDiff.inHours % 24);
  int minutes = (timeDiff.inMinutes % 60);
  int seconds = 60 - (timeDiff.inSeconds % 60);

  String result = '';
  if (days > 0) {
    result = '$days day ago';
  } else if (hours > 0) {
    result = '$hours hour ago';
  } else if (minutes > 0) {
    result = '$minutes min ago';
  } else if (seconds > 0) {
    result = '$seconds sec ago';
  }

  return (result);
}

Future<String> getDirPath(String tipe) async {
  switch(tipe) {
    case "temp":
      Directory tempDir = await getTemporaryDirectory();
      tempPath = tempDir.path;
      return tempPath;
      break;
    case "doc":
      Directory appDocDir = await getApplicationDocumentsDirectory();
      appDocPath = appDocDir.path;
      return appDocPath;
      break;
  }
  return '';
}

String generateRandomString() {
  final random = Random();
  final charSet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final sections = List<String>.generate(4, (_) => _generateSection(charSet, random));
  String tmp = sections.join('-');
  print('GEN: $tmp');
  return tmp;
}

String _generateSection(String charSet, Random random) {
  final sectionLength = 5;
  final charCodes = List<int>.generate(
      sectionLength, (_) => charSet.codeUnitAt(random.nextInt(charSet.length)));
  return String.fromCharCodes(charCodes);
}

void deleteProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('profile'); // Replace 'preferenceKey' with the key of the preference you want to delete
}

void saveProfile(String profile) async {
  final prefs = await SharedPreferences.getInstance();
  String encoded = '';
  if (profile.length > 0) {
    encoded = base64.encode(utf8.encode(profile));
  }
  await prefs.setString('profile', encoded);
}

