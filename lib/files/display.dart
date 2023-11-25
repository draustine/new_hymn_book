import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'expandable_list_view.dart';
import 'variables.dart';
import 'other_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  double opacity = 0.0;

  int count = 0;
  String validityText = '';
  Widget screenToShow = HomePage();
  String buttonText = 'BACK';
  dynamic result = [];

  @override
  void initState() {
    super.initState();
    // Start the animation
    loadJsonData();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        opacity = 1.0; // Change opacity to 1 to fade in the image
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: GestureDetector(
        onTap: () {
          gestureDetectorHandler();
        },
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: AnimatedOpacity(
            opacity: opacity,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 200),
            child: Image.asset(
              'images/old_hymn_book.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void gestureDetectorHandler() {
    bool hasAccess = checkAccess();
    if (hasAccess) {
      chooseHymn();
    } else {
      validity.validity = false;
      validityInfo();
    }
  }

  bool checkAccess() {
    if (isActivated) {
      return true;
    } else {
      if (username != '') {
        isActivated = true;
        prefs.setBool(activationStatusFile, isActivated);
        return true;
      } else {
        bool access = isValid;
        return access;
      }
    }
  }

  void validityInfo() {
    bool valid = validity.validity;
    String message = validity.message;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Validity Message'.toUpperCase(),
            style: repeatingUpperCaseBody,
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
          ),
          backgroundColor: Colors.lightGreen,
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: repeatingUpperCaseBody.copyWith(fontSize: 30),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                if (!valid) {
                  exit(0);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadJsonData() async {
    final String jsonContent =
    await rootBundle.loadString('assets/Composed_Hymns.json');

    final Map<String, dynamic> jsonMap = json.decode(jsonContent);

    setState(() {
      jsonData = jsonMap.map((key, value) {
        return MapEntry(key, List<String>.from(value));
      });
      hymnCount = jsonData.length;
      // for(final String key in jsonData.keys){
      //   print(jsonData[key]);
      // }
    });
  }

  void increaseFontSize() {
    setState(() {
      minFontSize += 2.0;
      saveFontSizeToPrefs(minFontSize);
    });
  }

  void decreaseFontSize() {
    setState(() {
      minFontSize -= 2.0;
      saveFontSizeToPrefs(minFontSize);
    });
  }


  void chooseHymn() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        buttonText = 'DISPLAY ALL';
        result = [];
        screenToShow = MyListView();
        getAllHymns();
        validityText = '';
        count = 0;
        TextEditingController textFieldController = TextEditingController();
        FocusNode myFocusNode = FocusNode();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              alignment: Alignment.center,
              actionsAlignment: MainAxisAlignment.center,
              backgroundColor: Colors.tealAccent,
              titleTextStyle: alertTitleTextStyle,
              title: const Text(
                "Input Hymn Number or Part of hymn",
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                height: 200,
                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      focusNode: myFocusNode,
                      autofocus: true,
                      style: textInputTextStyle,
                      textAlign: TextAlign.center,
                      controller: textFieldController,
                      onChanged: (input) {
                        inputChange(input: input);
                        setState(() {}); // Update the dialog content
                      },
                    ),
                    Text(validityText), // Display input text
                  ],
                ),
              ),
              actions: [
                Center(
                  child: ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          textFieldController.text = '';
                        },
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: (){
                          textFieldController.text = '';
                          inputChange(input: '');
                          setState(() {});
                        },
                        child: const Text(
                            'CLEAR'
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          //Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => screenToShow,
                            ),
                          );
                          // textFieldController.text = '';
                        },
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void inputChange({required String input}){
    result = getValidityText(input);
    validityText = result[0];
    screenToShow = result[1];
    count = result[2];
    if (count == 0) {
      buttonText = "BACK";
      screenToShow = const HomePage();
    } else if (count == 1) {
      buttonText = "DISPLAY HYMN";
    } else {
      buttonText = "DISPLAY LIST";
    }
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

List<dynamic> getValidityText(dynamic input) {
  String comment = '';
  jsonHymns = {};
  hymnTitles = [];
  int count = 0;
  Widget screenToShow = MyListView();
  if (int.tryParse(input) != null) {
    if (int.parse(input) <= hymnCount) {
      jsonHymns[input] = jsonData[input]!;
      dynamic thisHymn = jsonHymns[input];
      hymnTitles.add([thisHymn[2], input]);
      comment = 'Hymn $input : ${thisHymn[2]}';
      screenToShow = ThisHymn(thisNumber: input);
      count = 1;
    } else {
      getHymnTitles(input);
      count = hymnTitles.length;
      if (count == 1) {
        String key = hymnTitles[0][1];
        jsonHymns[key] = jsonData[key]!;
        comment = 'Hymn $key : ${hymnTitles[0][0]}';
        screenToShow = ThisHymn(thisNumber: key);
      } else {
        if (count == 0) {
          comment = 'There is no match!';
          screenToShow = const HomePage();
        } else {
          comment = '$count hymns matches';
          screenToShow = const Placeholder();
        }
      }
    }
  } else {
    getHymnTitles(input);
    count = hymnTitles.length;
    if (count == 1) {
      String key = hymnTitles[0][1];
      jsonHymns[key] = jsonData[key]!;
      comment = 'Hymn $key : ${hymnTitles[0][0]}';
      screenToShow = ThisHymn(thisNumber: key);
    } else {
      if (count == 0) {
        comment = 'There is no match!';
        screenToShow = const HomePage();
      } else {
        comment = '$count hymns matches';
        screenToShow = MyListView();
      }
    }
  }
  return [comment, screenToShow, count];
}
