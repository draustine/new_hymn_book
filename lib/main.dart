import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '/files/display.dart';
import 'package:ntp/ntp.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'files/functions.dart';
import 'files/variables.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.robotoSlabTextTheme(),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = true;

  Future<void> initialiseSharedPreferences() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs = _prefs;
     });
    bool isInternetAccessible = await checkInternetConnection();
    setState(() {
      isThereInternetAccess = isInternetAccessible;
      getAuthorisationParameters();
    });

  }



  Future<void> requestPermissions() async {
    await initialiseSharedPreferences();
    await fetchHymnsJsonFile();
    Map<Permission, PermissionStatus> statuses = {};
    // Request each permission one by one and await the result of each request
    statuses[Permission.contacts] = await Permission.contacts.request();
    statuses[Permission.location] = await Permission.location.request();

    // Check if permissions are granted before continuing with your operations
    if (statuses[Permission.contacts] == PermissionStatus.granted &&
        statuses[Permission.location] == PermissionStatus.granted) {
      // Permissions are granted, proceed with your operations that require these permissions

    } else {
      exit(0);
    }
  }

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomePage(),
    );
  }


  Future<void> fetchHymnsJsonFile() async {
    bool internetAvailable = await checkInternetConnection();
    if(internetAvailable){
      await commonShowToast(msg: 'Internet access is available', duration: 3, context: context);
      final response = await http.get(Uri.parse(hymnJsonUrl));
      if (response.statusCode == 200) {
        // Parse the JSON response
        final thisJsonData = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() {
          jsonData = convertMap(thisJsonData);
          hymnCount = jsonData.length;
        });
        // Save the JSON data to shared_preferences
        await prefs.setString(localHymnsKey, jsonEncode(convertMap(thisJsonData)));
      } else {
        throw Exception('Failed to download JSON file');
      }
    } else {
      await commonShowToast(msg: 'No Internet access!!!', duration: 3, context: context);
      try{
        final Map<String, List<String>> retrievedData  = await retrieveMap(localHymnsKey);
        setState(() {
          jsonData = copyMap(retrievedData);
          hymnCount = jsonData.length;
        });
      } catch (e){
        showToast(msg: 'There is no List in memory', duration: 3);
        log(e.toString());
      }
    }

  }




  void getAuthorisationParameters() async {
    //Get activation status from memory
    var check = await getRecordFromMemory(activationStatusFile);
    setState(() {
      if (check != '') {
        isActivated = check;
      } else {
        isActivated = false;
      }
    });
    prefs.setBool(activationStatusFile, isActivated);
    if (!isActivated) {
      //Get list of authorised user accounts
      String users = await getStringFromWeb(authorisedUrl);
      setState(() {
        authorisedUsersList = users.split('\n');
      });
      //Get list of user accounts on the device
      String objectString = await callNativeFunction('getGoogleAccounts');
      setState(() {
        if (objectString != "No Account") {
          userNames = objectString.split("\n");
        }
      });
      setState(() {
        username = '';
        if (objectString != "No Account") {
          for (final String account in userNames) {
            for (final String user in authorisedUsersList) {
              if (account.trim().toLowerCase() == user.trim().toLowerCase()) {
                username = account;
                break;
              }
            }
            if (username != '') {
              break;
            }
          }
          if(username == ''){
            showToast(msg: 'Application not authorised for this device', duration: 2);
          }
        } else {
          showToast(msg: 'No gmail account found on device', duration: 3);
        }
      });
      currentNetworkDate = await NTP.now(lookUpAddress: 'time.google.com');
      setState(() {
        checkValidity();
      });
    }
  }

  Future<void> checkValidity() async {
    bool _isValid = false;
    try {
      if (currentNetworkDate.isAfter(DateTime.parse(expirationDate))) {
        // The app has expired
        validity.message = 'Your Copy has expired.\nPlease contact support.';
        _isValid = false;
      } else {
        // The app is still valid
        _isValid = true;
      }
    } catch (e) {
      // Handle NTP request errors
      _isValid = false;
      validity.message =
          'Failed to fetch network date: $e\nEnsure that you have internet access';
    }
    isValid = _isValid;
  }

  String authorisedUser() {
    String user = '';
    if (userNames.isNotEmpty) {
      for (final String account in userNames) {
        if (authorisedUsersList.contains(account)) {
          user = account;
          break;
        }
      }
    }
    return user;
  }

  loadFontSizeFromPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      minFontSize = prefs.getDouble('minFontSize') ?? defaultMinFontSize;
    });
  }

  void increaseFontSize() {
    setState(() {
      minFontSize += 1.0;
      saveFontSizeToPrefs(minFontSize);
    });
  }

  void decreaseFontSize() {
    setState(() {
      minFontSize -= 1.0;
      saveFontSizeToPrefs(minFontSize);
    });
  }

  void showToast({required String msg, required int duration}) {
    Future.delayed(Duration.zero, () {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: Duration(seconds: duration),
          action: SnackBarAction(
            label: 'OK',
            onPressed: scaffold.hideCurrentSnackBar,
          ),
        ),
      );
    });
  }
}
