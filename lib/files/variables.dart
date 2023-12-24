import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String hymnJsonUrl = "https://www.dropbox.com/scl/fi/r5e1n45l0oy0qumy9qx5i/Composed_Hymns.json?rlkey=rbhbdzacei5yowqvi014tnjud&dl=1";
String authorisedUrl = 'https://www.dropbox.com/scl/fi/iphzf0svgeaez8rrq9pv4/Authorised-Users.txt?rlkey=8u7moxfuovdiafp7qsrdgzes8&dl=1 ';
String expirationDate = "2024-01-31"; // Set your app's expiration date here
String localHymnsJson = "";
String localHymnsKey = "localHymnsString";
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
late bool isThereInternetAccess;

class ValidityStatus {
  bool validity;
  String message;  ValidityStatus({required this.validity, required this.message});

}





