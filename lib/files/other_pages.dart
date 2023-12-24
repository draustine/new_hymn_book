import 'package:flutter/material.dart';
import 'expandable_list_view.dart';
import 'functions.dart';
import 'variables.dart';
import '../main.dart';


class ThisHymn extends StatefulWidget {
  final String thisNumber;

  const ThisHymn({super.key, required this.thisNumber});

  @override
  State<ThisHymn> createState() => _ThisHymnState();
}

class _ThisHymnState extends State<ThisHymn> {


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

  @override
  Widget build(BuildContext context) {
    String theKey = widget.thisNumber;
    List? thisHymn = jsonHymns[theKey];
    if (thisHymn != null) {
      String thisTitle = thisHymn[2];
      String comment = '';
      String thisBody = thisHymn[1];
      List<String> titleLines = thisHymn[0].split('\n');
      if (titleLines.length > 1){
       comment = titleLines.sublist(1).join('\n');
      }
      List<Widget> thisContent = [];
      if (comment != ''){
        thisContent.add(
          Text(
            comment,
            style: bodyStyle.copyWith(color: Colors.purple, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
          ),
        );
      }

      thisContent.add(HymnBody(body: thisBody));

      return Scaffold(
        //backgroundColor: Colors.tealAccent,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.red,
            centerTitle: true,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hymn $theKey',
                  textAlign: TextAlign.center,
                  style: hymnNumberStyle,
                ),
                Text(
                  thisTitle,
                  textAlign: TextAlign.center,
                  style: appBarTitle,
                ),
              ],
            ),
          ),
        body: GestureDetector(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: thisContent, // Display the hymn content.
                  ),
                ),
              ],
            ),
          ),
          onScaleUpdate: (details){
            setState(() {
              minFontSize = minFontSize * details.scale;
              saveFontSizeToPrefs(minFontSize);
            });
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('ERROR OCCURRED'),
        ),
      );
    }
  }
}
