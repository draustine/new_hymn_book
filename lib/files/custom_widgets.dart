import 'package:flutter/material.dart';
import 'variables.dart';
import '../main.dart';



class CustomVerse extends StatelessWidget {
  final List<String> thisVerse;

  const CustomVerse({super.key,
    required this.thisVerse,
  });

  final TextAlign textAlign = TextAlign.start;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 30, // Adjust the width for the verse number column.
          child: Text(
            thisVerse[0],
            style: numberStyle, // Style for verse number.
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: thisVerse.sublist(1).map((verseContent) {
              return formatTextWithBracketStyle(verseContent, bodyStyle, textAlign);
            }).toList(),
          ),
        ),
      ],
    );
  }
}


class CustomResponse extends StatelessWidget {
  final List<String> thisResponse;

  const CustomResponse({super.key,
    required this.thisResponse,
  });

  final TextAlign textAlign = TextAlign.start;


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40, // Adjust the width for the verse number column.
          child: Text(
            thisResponse[0],
            style: repeatingPartLabel, // Style for verse number.
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: thisResponse.sublist(1).map((verseContent) {
              return formatTextWithBracketStyle(verseContent, repeatingPartBody, textAlign);
            }).toList(),
          ),
        ),
      ],
    );
  }
}


Widget formatTextWithBracketStyle(String text, TextStyle defaultStyle, TextAlign textAlign) {
  TextStyle bracketStyle = defaultStyle.copyWith(color: Colors.red);
  final bracketMatches = RegExp(r'\(.+?\)').allMatches(text);
  if (bracketMatches.isNotEmpty) {
    List<InlineSpan> spans = [];
    int previousEnd = 0;
    for (Match match in bracketMatches) {
      int start = match.start;
      int end = match.end;
      String matchedText = match.group(0) ?? '';
      // Add the default style for the text before the bracketed portion
      if (start > previousEnd) {
        spans.add(TextSpan(
          text: text.substring(previousEnd, start),
          style: defaultStyle,
        ));
      }
      // Add the different style for the bracketed portion
      spans.add(TextSpan(
        text: matchedText,
        style: bracketStyle,
      ));
      previousEnd = end;
    }
    // Add the default style for the text after the last bracketed portion
    if (previousEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(previousEnd),
        style: defaultStyle,
      ));
    }
    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign,
    );
  } else {
    // If there are no bracket matches, apply the default style to the entire text
    return Text(
      text,
      style: defaultStyle,
      textAlign: textAlign,
    );
  }
}
