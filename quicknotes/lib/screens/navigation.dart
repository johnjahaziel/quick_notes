import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicknotes/screens/bookmark.dart';
import 'package:quicknotes/screens/homepage.dart';
import 'package:quicknotes/screens/settings.dart';

class Navigation extends StatefulWidget {
  static const String id ='Navigation';
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);
  
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        backgroundColor: theme.scaffoldBackgroundColor,
        color: Color(0xff174E52),
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(microseconds: 200),
            curve: Curves.ease
          );
        },
        items: const [
            Icon(
              CupertinoIcons.house_fill,
              color: Colors.white,
            ),
            Icon(
              Icons.bookmark,
              color: Colors.white,
            ),
            Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          children: const [
            Homepage(),
            Bookmark(),
            Settings()
          ],
        ),
      ),
    );
  }
}