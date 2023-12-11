import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


String authorisedUrl = 'https://www.dropbox.com/scl/fi/iphzf0svgeaez8rrq9pv4/Authorised-Users.txt?rlkey=8u7moxfuovdiafp7qsrdgzes8&dl=1 ';
String expirationDate = "2023-12-31"; // Set your app's expiration date here
late bool isActivated;
late bool isValid;
String activationStatusFile = 'activation_status';
List<String> authorisedUsers = [];
String username = '';
List<String> userNames = [];
List<String> authorisedUsersList = [];

late DateTime currentNetworkDate;
ValidityStatus validity = ValidityStatus(validity: false, message: 'Unverified');



double defaultMinFontSize = 18;
double minFontSize = 18;
Map<String, List<String>> jsonData = {};
late final int hymnCount;
Map<String, List<String>> jsonHymns = {};
List<List<String>> jsonHymnsList = [];
List hymnsList = [];
List<List<String>> hymnTitles = [];
TextStyle bodyStyle = GoogleFonts.farsan(fontSize: minFontSize + 7, fontWeight: FontWeight.w600, color: Colors.black);
TextStyle upperCaseBody = GoogleFonts.farsan(fontSize: minFontSize + 2, fontWeight: FontWeight.normal);
TextStyle repeatingUpperCaseBody = GoogleFonts.noticiaText(fontSize: minFontSize + 2, fontWeight: FontWeight.w600, color: Colors.purple);
TextStyle repeatingPartLabel = GoogleFonts.lobster(fontSize: minFontSize + 4, fontWeight: FontWeight.w100, color: Colors.green);
TextStyle appBarTitle = GoogleFonts.nunito(fontSize: minFontSize + 2, fontWeight: FontWeight.w800, color: Colors.white);
TextStyle numberStyle = GoogleFonts.noticiaText(fontSize: minFontSize + 4, fontWeight: FontWeight.normal, color: Colors.blue);
TextStyle hymnListStyle = GoogleFonts.mooli(fontSize: minFontSize + 4, fontWeight: FontWeight.normal, color: Colors.blue);
TextStyle repeatingPartBody = bodyStyle.copyWith(color: Colors.purple);
TextStyle hymnNumberStyle = appBarTitle.copyWith(fontSize: minFontSize + 4, fontWeight: FontWeight.w400, color: Colors.yellowAccent,);
TextStyle alertTitleTextStyle = GoogleFonts.montserrat(fontSize: minFontSize, fontWeight: FontWeight.bold, color: Colors.blue,);
TextStyle textInputTextStyle = GoogleFonts.neuton(fontSize: minFontSize + 4, fontWeight: FontWeight.normal, color: Colors.blue,);
TextStyle alertCommentTextStyle = GoogleFonts.pacifico(fontSize: minFontSize, fontWeight: FontWeight.normal, color: Colors.blue,);

const platform = MethodChannel('my_channel');
late SharedPreferences prefs;


class ValidityStatus {
  bool validity;
  String message;  ValidityStatus({required this.validity, required this.message});

}




Future<dynamic> callNativeFunction(String functionName,
    [dynamic parameter]) async {
  dynamic result;
  try {
    result = await platform.invokeMethod(functionName, parameter);
  } on PlatformException catch (e) {
    result = "Failed to call $functionName: ${e.message}";
  }
  return result;
}

dynamic getRecordFromMemory(String fileName) async {
  var result = prefs.get(fileName) ?? '';
  return result;
}

Future<String> getStringFromWeb(String fileUrl) async {
  var url = Uri.parse(fileUrl);
  String result = '';
  try {
    var response = await http.get(url);
    if (response.statusCode == 200) {
      // Fetching text from the file
      result = response.body;
    } else {
      // Handle any error when fetching the file
    }
  } catch (e) {
    // Handle any network or unexpected errors
  }
  return result;
}


List<String> convertObjectListToStringList(List<Object?> objectList) {
  List<String> stringList = objectList
      .whereType<String>() // Filters out non-String objects
      .toList();
  return stringList;
}

void getAllHymns(){
  Map<String, List<String>> tempJsonHymns = {};
  for (final item in jsonData.entries) {
    tempJsonHymns.putIfAbsent(item.key, () => item.value);
  }
  var mapEntries = tempJsonHymns.entries.toList();
  // Sort the list based on the first element of each value list
  mapEntries.sort((a, b) => a.value[0].compareTo(b.value[0]));
  // Create a new sorted map from the sorted list of entries
  jsonHymns = Map.fromEntries(mapEntries);
  jsonHymnsList = [];
  for (final item in jsonHymns.entries){
    jsonHymnsList.add([item.value[2], item.value[1], item.key, item.value[0]]);
  }
}

void getHymns(dynamic content) {
  String thisContent = cleanText(content);
  Map<String, List<String>> tempJsonHymns = {};
  for (final item in jsonData.entries) {
    final String item1 = cleanText(item.value[0]);
    final String item2 = cleanText(item.value[1]);
    if (item1.contains(thisContent) || item2.contains(thisContent)) {
      tempJsonHymns.putIfAbsent(item.key, () => item.value);
    }
  }
  var mapEntries = tempJsonHymns.entries.toList();

  // Sort the list based on the first element of each value list
  mapEntries.sort((a, b) => a.value[0].compareTo(b.value[0]));

  // Create a new sorted map from the sorted list of entries
  jsonHymns = Map.fromEntries(mapEntries);
  jsonHymnsList = [];
  for (final item in jsonHymns.entries){
    jsonHymnsList.add([item.value[2], item.value[1], item.key, item.value[0]]);
  }

}

void getHymnTitles(dynamic content) {
  String thisContent = cleanText(content);
  for (final item in jsonData.entries) {
    final String item1 = cleanText(item.value[2]);
    final String item2 = cleanText(item.value[1]);
    if (item1.contains(thisContent) || item2.contains(thisContent)) {
      hymnTitles.add([item.value[2],item.key]);
    }
  }
  hymnTitles.sort((a, b) => a[0].compareTo(b[0]));
  addHymnTitlesToJsonHymnsList();
}

void addHymnTitlesToJsonHymnsList(){
  jsonHymnsList = [];
  String key = '';
  String title = '';
  String body = '';
  String titlePlus = '';
  for (int index = 0; index < hymnTitles.length; index ++){
    key = hymnTitles[index][1];
    title = hymnTitles[index][0];
    body = jsonData[key]![1];
    titlePlus  = jsonData[key]![0];
    jsonHymnsList.add([title, body, key, titlePlus]);
  }
}



String cleanText(String text) {
  String cleanedText = '';
  String pattern = r'[Ẹ́Ẹ̀ẸÉÈèẹ́ẹ̀ẹé]';
  cleanedText = text.replaceAll(RegExp(pattern), 'E');
  pattern = r'[ÌỊỊ̀Ị́ỊÍìịỊ̀Ị́í]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'I');
  pattern = r'[ÁÀáà]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'A');
  pattern = r'[ŃǸṄṅǹń]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'N');
  pattern = r'[ÒỌỌ̀Ọ́ÓôòōọỌ̀Ọ́ó]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'O');
  pattern = r'[ŚṢȘŞșșśş]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'S');
  pattern = r'[ÙỤ̀Ụ́ỤÚùụụ̀ụ́ú]';
  cleanedText = cleanedText.replaceAll(RegExp(pattern), 'U');
  cleanedText = cleanedText.replaceAll(
      RegExp(r'[!@#$%^&*()_+{}\[\]:;<>,.?~\\\-=|’]'), '');
  cleanedText = cleanedText.replaceAll(r"'", "");

  return cleanedText.replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}


String toTitleCase(String input) {
  if (input.isEmpty) {
    return input;
  }

  final words = input.split(' ');
  final titleCaseWords = words.map((word) {
    if (word.length < 2) {
      return word.toUpperCase();
    }
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  });

  return titleCaseWords.join(' ');
}


saveFontSizeToPrefs(double size) async {
  prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('minFontSize', size);
}

