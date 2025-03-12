// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:quicknotes/widgets/homewidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  List<Map<String, String>> bookmarkedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? bookmarks = prefs.getStringList('bookmarks');

    if (bookmarks != null) {
      setState(() {
        bookmarkedNotes = bookmarks.map((note) {
          final decoded = jsonDecode(note) as Map<String, dynamic>;
          return {
            'title': decoded['title'] as String,
            'description': decoded['description'] as String,
            'date': decoded['date'] as String,
            'day': decoded.containsKey('day') ? decoded['day'] as String : '',
            'time': decoded.containsKey('time') ? decoded['time'] as String : '',
          };
        }).toList();
      });
    }
  }

  void _removeBookmark(String title, String description, String date, String day, String time) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

    bookmarks.removeWhere((note) {
      final decoded = jsonDecode(note) as Map<String, dynamic>;
      return decoded['title'] == title &&
            decoded['description'] == description &&
            decoded['date'] == date &&
            decoded['day'] == day &&
            decoded['time'] == time;
    });

    await prefs.setStringList('bookmarks', bookmarks);

    setState(() {
      bookmarkedNotes = bookmarkedNotes.where((note) =>
        note['title'] != title ||
        note['description'] != description ||
        note['date'] != date ||
        note['day'] != day ||
        note['time'] != time).toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from bookmarks')),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
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
                    'Bookmarks',
                    style: settingstitle,
                  ),
                ),
              ),
              Row(
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
                        child: const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 25,
                            color: kgreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: bookmarkedNotes.isEmpty
                ? const Center(child: Text("No bookmarks yet"))
                : ListView.builder(
                    itemCount: bookmarkedNotes.length,
                    itemBuilder: (context, index) {
                      final note = bookmarkedNotes[index];
                      return Homewidget(
                        title: note['title']!,
                        description: note['description']!,
                        date: note['date']!,
                        day: note['day']!,
                        time: note['time']!,
                        onBookmarkToggle: () => _removeBookmark(
                          note['title']!,
                          note['description']!,
                          note['date']!,
                          note['day']!,
                          note['time']!
                        ),
                        isInitiallyBookmarked: true,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
