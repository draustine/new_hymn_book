import 'package:flutter/material.dart';
import 'variables.dart';
import '../main.dart';

import 'custom_widgets.dart';

class MyListView extends StatelessWidget {
  final List<List<String>> items = jsonHymnsList;

  MyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        title: Text(
          "HYMNS",
          style: appBarTitle,
        ),
      ),
      body: ListView.builder(
        itemCount: jsonHymnsList.length,
        itemBuilder: (context, index) {
          final hymnTitle = jsonHymnsList[index][0];
          final hymnData = jsonHymnsList[index][1];
          final number = jsonHymnsList[index][2];
          final titlePlus = jsonHymnsList[index][3];
          return Hymn(
            title: hymnTitle,
            body: hymnData,
            number: number,
            titlePlus: titlePlus,
          );
        },
      ),
    );
  }
}

class Hymn extends StatefulWidget {
  final String title;
  final String body;
  final String number;
  final String titlePlus;

  const Hymn(
      {super.key,
      required this.title,
      required this.body,
      required this.number,
      required this.titlePlus});

  @override
  HymnState createState() => HymnState();
}

class HymnState extends State<Hymn> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // backgroundColor: Colors.orangeAccent,
      collapsedBackgroundColor: Colors.lime,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 60,
                child: Text(
                  '${widget.number} ',
                  style: appBarTitle.copyWith(color: Colors.indigo),
                ),
              ),
              Expanded(
                child: Text(
                  widget.title,
                  style: appBarTitle.copyWith(color: Colors.indigo),
                ),
              ),
            ],
          ),
        ],
      ),
      onExpansionChanged: (expanded) {
        setState(() {
          isExpanded = expanded;
        });
      },
      children: <Widget>[
        if (isExpanded)
          Column(
            children: [
              Text(
                widget.titlePlus,
                textAlign: TextAlign.center,
                style: appBarTitle.copyWith(color: Colors.blue),
              ),
              HymnBody(
                body: widget.body,
              ),
            ],
          ), // Show the full text when expanded
      ],
    );
  }
}

class HymnBody extends StatelessWidget {
  final String body;

  const HymnBody({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final parts = body.split('\n');
    bool chorus = false;
    List<String> thisVerse = [];
    bool verse = false;
    bool response = false;
    String responsePattern = r'^\w{1,2}:';
    String numberPattern = r'^\d+\.$';
    String chorusPattern = r'^[\w\u0080-\uFFFF]{3,}:';
    RegExp verseStartPattern = RegExp(r'^\t|\d+\.\s+');
    List<String> thisResponse = [];
    List<Widget> hymnContent = [];

    for (int index = 0; index < parts.length; index++) {
      TextStyle textStyle;
      TextAlign textAlign = TextAlign.left;
      String thisPart = parts[index];
      // print(thisPart);

      if (RegExp(numberPattern).hasMatch(thisPart.trim())) {
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        verse = true;
        thisVerse = [thisPart];
        chorus = false;
        response = false;
        textStyle = numberStyle;
        textAlign = TextAlign.left;
      } else if (verseStartPattern.hasMatch(thisPart.trim())) {
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        verse = true;
        List<String> thisGroup = [];
        thisGroup = patternAndRemainder(thisPart.trim(), verseStartPattern);
        thisVerse.addAll(thisGroup);
        chorus = false;
        response = false;
        textStyle = numberStyle;
        textAlign = TextAlign.left;
      } else if (RegExp(chorusPattern).hasMatch(thisPart.trim())) {
        verse = false;
        response = false;
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        chorus = true;
        textAlign = TextAlign.left;
        textStyle = repeatingPartLabel;
        textStyle = textStyle.copyWith(
          fontSize: textStyle.fontSize ?? 22.0,
          color: textStyle.color ?? Colors.black,
        );
        hymnContent.add(Align(
          alignment: Alignment.topLeft,
          child: Text(
            thisPart,
            style: textStyle,
            textAlign: textAlign,
          ),
        ));
      } else if (RegExp(responsePattern).hasMatch(thisPart.trim())) {
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
        }
        thisResponse = [thisPart];
        chorus = false;
        verse = false;
        response = true;
      } else if (thisPart == '') {
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        verse = false;
        chorus = false;
        response = false;
        hymnContent.add(Text(thisPart));
      } else if (thisPart == thisPart.toUpperCase()) {
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        if (chorus) {
          textAlign = TextAlign.left;
          textStyle = repeatingUpperCaseBody;
          hymnContent.add(Align(
            alignment: Alignment.topLeft,
            child: formatTextWithBracketStyle(thisPart, textStyle, textAlign),
          ));
        } else {
          double newSize = upperCaseBody.fontSize! + 2;
          textStyle = upperCaseBody.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: newSize);
          textAlign = TextAlign.center;
          hymnContent.add(Align(
            alignment: Alignment.topCenter,
            child: formatTextWithBracketStyle(thisPart, textStyle, textAlign),
          ));
        }
      } else if (verse) {
        if (thisPart == '' || thisPart == ' ' || index == parts.length - 1) {
          if (index == parts.length - 1) {
            thisVerse.add(thisPart);
          } else {
            thisVerse.add('');
          }
          verse = false;
          // Create a row with verse number at the top and verse content below.
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        } else {
          thisVerse.add(thisPart);
        }
      } else if (response) {
        thisResponse.add(thisPart);
      } else if (chorus) {

        textAlign = TextAlign.left;
        textStyle = repeatingPartBody;
        hymnContent.add(Align(
          alignment: Alignment.topLeft,
          child: formatTextWithBracketStyle(thisPart, textStyle, textAlign),
        ));
      } else {
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        // Apply the specified text formatting for non-verse parts.
        textStyle = bodyStyle;
        textStyle = textStyle.copyWith(
          fontSize: textStyle.fontSize ?? 22.0,
          color: textStyle.color ?? Colors.black,
        );
        hymnContent.add(Align(
          alignment: Alignment.topLeft,
          child: formatTextWithBracketStyle(thisPart, textStyle, textAlign),
        ));
      }
      if (index == parts.length - 1) {
        if (thisResponse.isNotEmpty) {
          hymnContent.add(CustomResponse(thisResponse: thisResponse));
          thisResponse = [];
        }
        if (thisVerse.isNotEmpty) {
          hymnContent.add(CustomVerse(thisVerse: thisVerse));
          thisVerse = [];
        }
      }
    }
    return Column(
      children: hymnContent,
    );
  }
}

List<String> patternAndRemainder(String text, RegExp pattern){
  List<String> result = [];
  String verseNumber = '';
  String verse = '';
  Match? match = pattern.firstMatch(text);
  if (match != null){
    String matchedText = match.group(0) ?? "";
    verseNumber = matchedText.trim();
    // Find the index where the match ends
    int matchEndIndex = match.end;
    // Get the remaining part of the string
    verse = text.substring(matchEndIndex);
  }
  result = [verseNumber, verse];
  return result;
}