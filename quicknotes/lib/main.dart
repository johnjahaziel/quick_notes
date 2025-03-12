import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/screens/notescreen.dart';
import 'package:quicknotes/screens/recyclebin.dart';
import 'package:quicknotes/screens/search.dart';
import 'package:quicknotes/widgets/fontprovider.dart';
import 'package:quicknotes/widgets/themeprovider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            initialRoute: '/',
            routes: {
              '/': (context) => const Navigation(),
              Notescreen.id: (context) => const Notescreen(),
              Navigation.id: (context) => const Navigation(),
              Search.id: (context) => const Search(),
              Recyclebin.id: (context) => const Recyclebin()
            },
          );
        },
      ),
    );
  }
}
