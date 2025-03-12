import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/screens/recyclebin.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:quicknotes/widgets/fontprovider.dart';
import 'package:quicknotes/widgets/themeprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int deletedNotesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDeletedNotesCount();
  }

  void _loadDeletedNotesCount() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deletedNotesString = prefs.getString('deletedNotes');

    if (deletedNotesString != null) {
      List<dynamic> deletedNotesList = json.decode(deletedNotesString);
      setState(() {
        deletedNotesCount = deletedNotesList.length;
      });
    }
  }

  void openRecycleBin() async {
    await Navigator.pushNamed(context, Recyclebin.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var fontSizeProvider = Provider.of<FontSizeProvider>(context);
    var themeProvider = Provider.of<ThemeProvider>(context);
    var theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 75,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: kgreen,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(55),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Settings',
                    style: settingstitle,
                  )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Navigation.id);
                      },
                      child: Container(
                        height: 32,
                        width: 45,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(1, 2),
                              color: Colors.black,
                              blurRadius: 2,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: const Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                            color: kgreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 20, top: 16),
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: kgreen
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 8),
                  child: Text(
                    'Theme',
                    style: TextStyle(
                      fontFamily: 'BalsamiqSans',
                      color:  Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  if (themeProvider.isDarkMode) {
                    themeProvider.toggleTheme();
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.sunny,
                      size: 40,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Light',
                      style: settingstheme
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () {
                  if (!themeProvider.isDarkMode) {
                    themeProvider.toggleTheme();
                  }
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.dark_mode_sharp,
                      size: 35,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Dark',
                      style: settingstheme
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 2),
              // Column(
              //   children: [
              //     Icon(
              //       Icons.system_security_update,
              //       size: 35,
              //     ),
              //     const SizedBox(height: 30),
              //     Text(
              //       'System',
              //       style: settingstheme
              //     ),
              //   ],
              // )
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            thickness: 2,
            height: 2,
          ),
          const SizedBox(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: kgreen
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 8),
                  child: Text(
                    'Font Size',
                    style: TextStyle(
                      fontFamily: 'BalsamiqSans',
                      color:  Colors.white
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Slider(
                  value: fontSizeProvider.fontSize,
                  min: fontSizeProvider.minFontSize,
                  max: fontSizeProvider.maxFontSize,
                  divisions: (fontSizeProvider.maxFontSize - fontSizeProvider.minFontSize).toInt(),
                  label: fontSizeProvider.fontSize.toString(),
                  onChanged: (newSize) {
                    fontSizeProvider.setFontSize(newSize);
                  },
                  activeColor: kgreen,
                  inactiveColor: Colors.grey,
                ),
                const SizedBox(height: 20),
                Text(
                  'Sample Text',
                  style: TextStyle(
                    fontFamily: 'BalsamiqSans',
                    fontSize: fontSizeProvider.fontSize,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: fontSizeProvider.restoreDefaultFontSize,
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(kgreen)
                    ),
                    child: const Text(
                      'Restore Default',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "BalsamiqSans"
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(
            height: 2,
            thickness: 2,
            color: Colors.grey,
          ),
          const SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: openRecycleBin,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white70,
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 2),
                    color: Colors.grey,
                    blurRadius: 2,
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 15,right: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recycle Bin',
                      style: TextStyle(
                        fontFamily: 'BalsamiqSans',
                        color: Colors.black,
                        fontSize: 15
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 2,),
                        Text(
                          '($deletedNotesCount)',
                          style: TextStyle(
                            fontFamily: 'BalsamiqSans',
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Divider(
            height: 2,
            thickness: 2,
            color: Colors.grey,
          ),
        ]
      ),
    );
  }
}