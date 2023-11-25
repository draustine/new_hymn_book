import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Import this for the color picker

class FontSettings {
  String fontFamily;
  double fontSize;
  FontWeight fontWeight;
  Color color;

  FontSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
  });
}

FontSettings bodyStyle = FontSettings(
  fontFamily: 'LobsterTwo',
  fontSize: 24,
  fontWeight: FontWeight.w100,
  color: Colors.black,
);

FontSettings upperCaseBody = FontSettings(
  fontFamily: 'NoticiaText',
  fontSize: 20,
  fontWeight: FontWeight.normal,
  color: Colors.black,
);

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  FontSettings currentFontSettings = bodyStyle; // Initial font settings
  FontSettings currentUpperCaseFontSettings = upperCaseBody; // Initial font settings for upperCaseBody
  double currentFontSize = bodyStyle.fontSize; // Initial font size
  double currentUpperCaseFontSize = upperCaseBody.fontSize; // Initial font size for upperCaseBody

  void _updateFontFamily(String? fontFamily) {
    if (fontFamily != null) {
      setState(() {
        currentFontSettings.fontFamily = fontFamily;
      });
    }
  }

  void _updateUpperCaseFontFamily(String? fontFamily) {
    if (fontFamily != null) {
      setState(() {
        currentUpperCaseFontSettings.fontFamily = fontFamily;
      });
    }
  }

  void _updateFontSize(double? fontSize) {
    if (fontSize != null) {
      setState(() {
        currentFontSize = fontSize;
        currentFontSettings.fontSize = fontSize;
      });
    }
  }

  void _updateUpperCaseFontSize(double? fontSize) {
    if (fontSize != null) {
      setState(() {
        currentUpperCaseFontSize = fontSize;
        currentUpperCaseFontSettings.fontSize = fontSize;
      });
    }
  }

  void _updateFontWeight(FontWeight? fontWeight) {
    if (fontWeight != null) {
      setState(() {
        currentFontSettings.fontWeight = fontWeight;
      });
    }
  }

  void _updateUpperCaseFontWeight(FontWeight? fontWeight) {
    if (fontWeight != null) {
      setState(() {
        currentUpperCaseFontSettings.fontWeight = fontWeight;
      });
    }
  }

  void _updateFontColor(Color? color) {
    if (color != null) {
      setState(() {
        currentFontSettings.color = color;
      });
    }
  }

  void _updateUpperCaseFontColor(Color? color) {
    if (color != null) {
      setState(() {
        currentUpperCaseFontSettings.color = color;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Font Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Body Style',
            style: TextStyle(
              fontFamily: currentFontSettings.fontFamily,
              fontSize: currentFontSize, // Use currentFontSize here
              fontWeight: currentFontSettings.fontWeight,
              color: currentFontSettings.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildFontFamilyDropdown(currentFontSettings.fontFamily),
          _buildFontSizeSlider(currentFontSize), // Use currentFontSize here
          _buildFontWeightDropdown(currentFontSettings.fontWeight),
          _buildFontColorPicker(currentFontSettings.color),
          const SizedBox(height: 32),
          Text(
            'Upper Case Body',
            style: TextStyle(
              fontFamily: currentUpperCaseFontSettings.fontFamily,
              fontSize: currentUpperCaseFontSize, // Use currentUpperCaseFontSize here
              fontWeight: currentUpperCaseFontSettings.fontWeight,
              color: currentUpperCaseFontSettings.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildFontFamilyDropdown(currentUpperCaseFontSettings.fontFamily),
          _buildFontSizeSlider(currentUpperCaseFontSize), // Use currentUpperCaseFontSize here
          _buildFontWeightDropdown(currentUpperCaseFontSettings.fontWeight),
          _buildFontColorPicker(currentUpperCaseFontSettings.color),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Save the currentFontSettings and currentUpperCaseFontSettings
              // to a storage mechanism (e.g., SharedPreferences).
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildFontFamilyDropdown(String selectedFontFamily) {
    final availableFontFamilies = <String>['LobsterTwo', 'NoticiaText', 'OtherFonts'];

    return DropdownButton<String>(
      value: selectedFontFamily,
      onChanged: currentFontSettings == bodyStyle
          ? _updateFontFamily
          : _updateUpperCaseFontFamily,
      items: availableFontFamilies.map((fontFamily) {
        return DropdownMenuItem<String>(
          value: fontFamily,
          child: Text(fontFamily),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSlider(double selectedFontSize) {
    return Slider(
      value: selectedFontSize,
      min: 12,
      max: 36,
      onChanged: currentFontSettings == bodyStyle
          ? _updateFontSize
          : _updateUpperCaseFontSize,
    );
  }

  Widget _buildFontWeightDropdown(FontWeight selectedFontWeight) {
    final availableFontWeights = <FontWeight>[
      FontWeight.normal,
      FontWeight.bold,
      FontWeight.w100,
    ];

    return DropdownButton<FontWeight>(
      value: selectedFontWeight,
      onChanged: currentFontSettings == bodyStyle
          ? _updateFontWeight
          : _updateUpperCaseFontWeight,
      items: availableFontWeights.map((fontWeight) {
        return DropdownMenuItem<FontWeight>(
          value: fontWeight,
          child: Text(fontWeight.toString()),
        );
      }).toList(),
    );
  }

  Widget _buildFontColorPicker(Color selectedColor) {
    Color currentColor = selectedColor;

    return GestureDetector(
      onTap: () async {
        final pickedColor = await showDialog<Color>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Pick a Color'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: currentColor,
                  onColorChanged: (Color color) {
                    currentColor = color;
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(currentColor);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        if (pickedColor != null) {
          if (currentFontSettings == bodyStyle) {
            _updateFontColor(pickedColor);
          } else {
            _updateUpperCaseFontColor(pickedColor);
          }
        }
      },
      child: Container(
        color: selectedColor,
        height: 50,
        width: 50,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SettingsPage(),
  ));
}
