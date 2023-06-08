import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? Question = '';
String? Answer = '';
String? Result = '';

String? nickName = '{anonymous}';
String? deviceId = '';
String? bioDes = 'Beauty enthusiast | ChatGPT nerd | Sharing my passion for good ';
String? bioAvatar = 'https://dogemazon.net/ocai/user3.svg';
int follower = 10;
int following = 20;
int posting = 100;

int inPost = 0;
bool loading = false;
bool askHitReady = false;
bool micOn = false;
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

const btnColor = Color.fromRGBO(230, 230, 230, 0.9);

const versi = '3.13.0+13';
const serverToken = "[SERVER_BASE_API_TOKEN]";

const double cardWidth = 166;
const double cardHeight = 300;
const double headerHeight = 50;
const double titleHeight = 100;
const double buttonHeight = 50;

const double iconWidth = 28;
const double iconHeight = 28;

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

