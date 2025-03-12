import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Recyclebin extends StatefulWidget {
  static const String id = 'Recyclebin';
  const Recyclebin({super.key});

  @override
  State<Recyclebin> createState() => _RecyclebinState();
}

class _RecyclebinState extends State<Recyclebin> {
  List<Map<String, String>> deletedNotes = [];

  @override
  void initState() {
    super.initState();
    _loadDeletedNotes();
  }

  void _loadDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deletedNotesString = prefs.getString('deletedNotes');

    if (deletedNotesString != null) {
      List<dynamic> decodedDeletedNotes = json.decode(deletedNotesString);
      DateTime now = DateTime.now();

      List<Map<String, String>> filteredNotes = decodedDeletedNotes
        .map((note) => Map<String, String>.from({
              'title': note['title']?.toString() ?? '',
              'description': note['description']?.toString() ?? '',
              'date': note['date']?.toString() ?? '',
              'day': note['day']?.toString() ?? '',
              'time': note['time']?.toString() ?? '',
              'deletedAt': note['deletedAt']?.toString() ?? DateTime.now().toIso8601String(),
            }))
        .where((note) {
          DateTime deletedAt = DateTime.parse(note['deletedAt']!);
          return now.difference(deletedAt).inDays < 30;
        })
        .toList();

      setState(() {
        deletedNotes = filteredNotes;
      });

      _saveDeletedNotes();
    }
  }

  void _saveDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();

    deletedNotes = deletedNotes.where((note) {
      DateTime deletedAt = DateTime.parse(note['deletedAt']!);
      return now.difference(deletedAt).inDays < 30;
    }).toList();

    prefs.setString('deletedNotes', json.encode(deletedNotes));
  }

  void restoreNote(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final String? notesString = prefs.getString('notes');
    List<Map<String, String>> existingNotes = notesString != null
        ? List<Map<String, String>>.from(json.decode(notesString).map((note) => Map<String, String>.from(note)))
        : [];

    Map<String, String> noteToRestore = {
    'title': deletedNotes[index]['title'] ?? '',
    'description': deletedNotes[index]['description'] ?? '',
    'date': deletedNotes[index]['date'] ?? '',
    'day': deletedNotes[index]['day']?.isNotEmpty == true
        ? deletedNotes[index]['day']!
        : DateFormat('EEEE').format(DateTime.now()),
    'time': deletedNotes[index]['time']?.isNotEmpty == true
        ? deletedNotes[index]['time']!
        : DateFormat('h:mm a').format(DateTime.now()),
  };

    existingNotes.add(noteToRestore);

    await prefs.setString('notes', json.encode(existingNotes));
    setState(() {
      deletedNotes.removeAt(index);
    });

    _saveDeletedNotes();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Note restored successfully")),
    );
  }

  void permanentlyDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you want to permanently delete this note? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  deletedNotes.removeAt(index);
                });
                _saveDeletedNotes();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Note deleted permanently")),
                );
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
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
                      'Recyclin Bin',
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
                      padding: const EdgeInsets.only(right: 25, top: 20),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Expanded(
              child: deletedNotes.isEmpty
            ? Center(child: Text("No deleted notes"))
            : ListView.builder(
                itemCount: deletedNotes.length,
                itemBuilder: (context, index) {
                  DateTime deletedAt = DateTime.parse(deletedNotes[index]['deletedAt']!);
                  int daysLeft = 30 - DateTime.now().difference(deletedAt).inDays;

                  return Column(
                    children: [
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: kgreen
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      deletedNotes[index]['title'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BalsamiqSans',
                                        fontSize: 22
                                      ),
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      deletedNotes[index]['description'] ?? '',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'BalsamiqSans',
                                        fontSize: 15
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 80,
                                color: const Color.fromARGB(255, 53, 53, 53),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      height: 80,
                                      child: VerticalDivider(
                                        width: 2,
                                        thickness: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.restore, color: const Color.fromARGB(255, 36, 238, 43)),
                                      onPressed: () => restoreNote(index),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => permanentlyDelete(index),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          "Deleted notes expire in $daysLeft day${daysLeft == 1 ? '' : 's'}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}