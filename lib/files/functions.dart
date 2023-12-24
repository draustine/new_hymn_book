import 'dart:convert';
import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'variables.dart';
import 'package:http/http.dart' as http;







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




Future<bool> checkInternetConnection() async {
  bool result = await InternetConnectionChecker().hasConnection;
  if (result == true) {
    log('Internet connection is available');
  } else {
    log('No internet connection');
  }
  return result;
}


Future<void> saveLink(String key, String value) async {
  await prefs.setString(key, value);
}

Future<String> getLink(String key, currentValue) async {
  String value = prefs.getString(key) ?? currentValue;
  return value;
}

bool convertToBool(String stringRepresentation) {
  bool booleanValue = false;
  if (stringRepresentation.toLowerCase() == 'true') {
    booleanValue = true;
  }
  return booleanValue;
}


void storeStringInMemory(String variableName, String url) async {
  await prefs.setString(variableName, url);
}


Future<String?> getStringFromMemory(String fileName) async {
  String? textFromFile = prefs.getString(fileName);
  return textFromFile;
}


Future<void> downloadAndSaveFile({required String url, required String fileName, required String content}) async {
  try {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      String fileContent = response.body;
      content = fileContent;
      await prefs.setString(fileName, fileContent);
    } else {
      //TODO: Develop or remove
    }
  } catch (e) {
    //TODO: Show alert to the user
  }
}


Future<void> saveMap(Map<String, dynamic> myMap, String mapName) async {
  prefs.setString(mapName, mapToString(myMap)); // Save the map as a string
}

String mapToString(Map<String, dynamic> map) {
  return map.entries.map((entry) {
    return '${entry.key}=${entry.value}';
  }).join(',');
}


Map<String, List<String>> convertMap (Map<String, dynamic> myMap){
  Map<String, List<String>> convertedMap =
    myMap.map((key, value) => MapEntry(key, value.cast<String>().toList()));
  return convertedMap;
}


Future<Map<String, List<String>>> retrieveMap(String key) async {
  prefs = await SharedPreferences.getInstance();
  final encodedData = prefs.getString(key);

  if (encodedData != null) {
    // Decode the JSON string back into a map:
    final decodedData = jsonDecode(encodedData);

    // Check if the decoded data is a map:
    if (decodedData is Map<String, dynamic>) {
      // Return the decoded map:
      return decodedData.map((key, value) {
        // Check if the value is a List<String>:
        if (value is List<dynamic>) {
          return MapEntry(key, value.cast<String>().toList());
        } else {
          // Handle other cases if needed.
          return MapEntry(key, <String>[]);
        }
      });
    }
  }

  return {}; // Return an empty map if no data is found
}



Future<void> commonShowToast({required String msg, required int duration, required context}) async {
  Future.delayed(Duration.zero, () {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: Duration(seconds: duration),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  });
}