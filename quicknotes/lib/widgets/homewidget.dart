// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homewidget extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final String day;
  final String time;
  final VoidCallback? onBookmarkToggle;
  final VoidCallback? onPinToggle;
  final bool isInitiallyBookmarked;
  final bool isInitiallyPinned;

  const Homewidget({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.day,
    required this.time,
    this.onBookmarkToggle,
    this.onPinToggle,
    this.isInitiallyBookmarked = false,
    this.isInitiallyPinned = false,
  });

  @override
  _HomewidgetState createState() => _HomewidgetState();
}

class _HomewidgetState extends State<Homewidget> {
  bool _showmoreOptions = false;
  bool isBookmarked = false;
  bool isPinned = false;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.isInitiallyBookmarked;
    isPinned = widget.isInitiallyPinned;
  }

  void _togglePin() {
    setState(() {
      isPinned = !isPinned;
    });
    if (widget.onPinToggle != null) {
      widget.onPinToggle!();
    }
  }

  void _toggleBookmark() async {
    if (widget.onBookmarkToggle != null) {
      widget.onBookmarkToggle!();
    } else {
      final prefs = await SharedPreferences.getInstance();
      List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];

      final noteData = jsonEncode({
        'title': widget.title,
        'description': widget.description,
        'date': widget.date,
        'day' : widget.day,
        'time' : widget.time
      });

      setState(() {
        if (isBookmarked) {
          bookmarks.remove(noteData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from bookmarks'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          bookmarks.add(noteData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to bookmarks'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        isBookmarked = !isBookmarked;
      });

      await prefs.setStringList('bookmarks', bookmarks);
    }
  }

  void _toggleOptions() {
    setState(() {
      _showmoreOptions = !_showmoreOptions;
    });
  }

  void _shareNote() {
    final String noteContent = "Title📝: ${widget.title}\n\nDescription:${widget.description}\n\nDate📅: ${widget.day}, ${widget.date} - ${widget.time}";
    Share.share(noteContent);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kgreen,
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 8),
                              child: Text(
                                widget.title,
                                style: hometitle,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: _togglePin,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 7),
                                    child: Icon(
                                      isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _toggleOptions,
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 2, top: 5),
                                    child: Icon(
                                      Icons.more_vert_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Divider(
                          color: Color(0xffFFFCFC),
                          thickness: 2,
                          height: 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: Text(
                            widget.description,
                            style: homedescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 30,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.date,
                          style: homedate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showmoreOptions)
                Padding(
                  padding: const EdgeInsets.only(right: 22, top: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: _showmoreOptions ? Curves.easeOutBack : Curves.easeInBack,
                    width: 134,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color.fromARGB(255, 70, 70, 70),
                      boxShadow: [
                        const BoxShadow(
                          offset: Offset(2, 4),
                          color: Color.fromARGB(255, 37, 37, 37),
                          blurRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        moreoption('Share', Icons.share, _shareNote),
                        const SizedBox(height: 4),
                        const Divider(
                          color: Color(0xffFFFCFC),
                          thickness: 2,
                          height: 2,
                        ),
                        moreoption(
                          isBookmarked ? 'Unbookmark' : 'Bookmark',
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          _toggleBookmark,
                        ),
                        const SizedBox(height: 4),
                        // const Divider(
                        //   color: Color(0xffFFFCFC),
                        //   thickness: 2,
                        //   height: 2,
                        // ),
                        // moreoption('Rename', Icons.drive_file_rename_outline_rounded, _renameNote),
                        // const SizedBox(height: 3),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
