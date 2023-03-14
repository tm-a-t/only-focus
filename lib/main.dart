import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Only Focus',
      theme: ThemeData(
        useMaterial3: true,
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
  bool focusMode = false;
  Color seedColor = Colors.teal;
  String font = 'Roboto';
  bool darkMode = false;

  ThemeData _getCurrentTheme() {
    return Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: darkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  void _selectSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('color', color.value);
    setState(() {
      seedColor = color;
    });
  }

  void _selectFont(String name) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('font', name);
    setState(() {
      font = name;
    });
  }

  void _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', !darkMode);
    setState(() {
      darkMode = !darkMode;
    });
  }

  Future<void> _showColorDialog() async {
    const colorList = Colors.accents;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: _getCurrentTheme(),
          child: AlertDialog(
            title: const Text('Choose color'),
            content: SizedBox(
              width: 0,
              child: GridView.count(
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                crossAxisCount: 4,
                children: [
                  for (var color in colorList)
                    // for (var color in _getShades(materialColor))
                    Center(
                      child: InkWell(
                        onTap: () {
                          _selectSeedColor(color);
                          Navigator.of(context).pop();
                        },
                        customBorder: const CircleBorder(),
                        child: Ink(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: ShapeDecoration(
                            color: darkMode ? color.shade400 : color.shade700,
                            shape: const CircleBorder(),
                          ),
                          child: seedColor == color
                              ? Icon(
                                  Icons.check,
                                  color: color.computeLuminance() > .5
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showFontDialog() async {
    final theme = Theme.of(context);
    final textStyles = [
      'Roboto',
      'EB Garamond',
      'Bebas Neue',
      'Montserrat',
      'Dancing Script',
      'Amatic SC',
      'Rock Salt',
      'UnifrakturMaguntia',
      'Redacted Script',
      'Silkscreen',
      'Goblin One',
      'Gluten',
      'Syne',
      'Anonymous Pro',
      'Space Mono',
    ];

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: _getCurrentTheme(),
          child: AlertDialog(
            contentPadding: const EdgeInsets.only(
              left: 8.0,
              top: 16.0,
              right: 8.0,
              bottom: 24.0,
            ),
            title: const Text('Choose font'),
            content: SizedBox(
              width: min(MediaQuery.of(context).size.width, 360),
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var fontName in textStyles)
                    ListTile(
                      onTap: () {
                        _selectFont(fontName);
                        Navigator.of(context).pop();
                      },
                      title: Text(
                        fontName,
                        style: GoogleFonts.asMap()[fontName]!(),
                      ),
                      trailing: font == fontName ? const Icon(Icons.check) : null,
                      iconColor: theme.colorScheme.onSurface,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final colorValue = prefs.getInt('color');
      seedColor = (colorValue == null) ? Colors.teal : Color(colorValue);
      font = prefs.getString('font') ?? 'Roboto';
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getCurrentTheme();
    final isDesktop = [
      TargetPlatform.linux,
      TargetPlatform.windows,
      TargetPlatform.macOS,
    ].contains(Theme.of(context).platform);

    return AnimatedTheme(
      data: theme,
      child: Scaffold(
        body: Ink(
          height: double.infinity,
          width: double.infinity,
          color:
              focusMode ? theme.colorScheme.primary : theme.colorScheme.surface,
          child: InkWell(
            splashFactory: InkSplash.splashFactory,
            onTap: () {
              setState(() {
                focusMode = !focusMode;
              });
            },
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          focusMode ? 'Focus' : 'Relax',
                          style: GoogleFonts.asMap()[font]!(
                            textStyle: theme.textTheme.displayMedium!,
                            color: focusMode
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (!isDesktop) const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: isDesktop
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: AnimatedOpacity(
                          duration: focusMode
                              ? const Duration(milliseconds: 400)
                              : const Duration(milliseconds: 200),
                          opacity: focusMode ? 0 : 1,
                          curve: focusMode ? Curves.easeOut : Curves.easeIn,
                          child: IgnorePointer(
                            ignoring: focusMode,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconButton(
                                  iconData: Icons.color_lens,
                                  onPressed: _showColorDialog,
                                ),
                                const SizedBox(width: 24),
                                CustomIconButton(
                                  iconData: Icons.text_fields,
                                  onPressed: _showFontDialog,
                                ),
                                const SizedBox(width: 24),
                                CustomIconButton(
                                  iconData: darkMode
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  onPressed: _toggleDarkMode,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData iconData;
  final void Function()? onPressed;

  const CustomIconButton({required this.iconData, this.onPressed, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Ink(
        width: 56,
        height: 56,
        decoration: ShapeDecoration(
          color: theme.colorScheme.secondaryContainer,
          shape: const CircleBorder(),
        ),
        child: IconButton(
          iconSize: 24,
          icon: Icon(iconData),
          color: theme.colorScheme.onSecondaryContainer,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
