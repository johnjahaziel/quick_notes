import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/screens/notescreen.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:quicknotes/widgets/homewidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  static const String id = 'Search';
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> notes = [];
  List<Map<String, String>> filteredNotes = [];
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_searchNotes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchNotes);
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes');

    if (notesString != null) {
      List<dynamic> decodedNotes = json.decode(notesString);
      setState(() {
        notes = decodedNotes.map((note) {
          return {
            'title': note['title'].toString(),
            'description': note['description'].toString(),
            'date': note['date'].toString(),
            'day': note['day'].toString(),
            'time': note['time'].toString(),
          };
        }).toList();
        filteredNotes = List.from(notes);
      });
    }
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', json.encode(notes));
  }

  void _searchNotes() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredNotes = notes
          .where((note) => note['title']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void addNote() async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notescreen()),
    );

    if (newNote != null) {
      setState(() {
        notes.add(newNote);
        filteredNotes = List.from(notes);
      });
      _saveNotes();
    }
  }

  void editNote(int index) async {
    if (isSelectionMode) {
      toggleSelection(index);
      return;
    }

    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notescreen(
          title: filteredNotes[index]['title'],
          description: filteredNotes[index]['description'],
          date: filteredNotes[index]['date'],
          day: filteredNotes[index]['day'],
          time: filteredNotes[index]['time'],
          index: notes.indexOf(filteredNotes[index]),
        ),
      ),
    );

    if (updatedNote != null) {
      setState(() {
        int originalIndex = notes.indexOf(filteredNotes[index]);
        notes[originalIndex] = updatedNote;
        filteredNotes = List.from(notes);
      });
      _saveNotes();
    }
  }

  void toggleSelectionMode() {
    setState(() {
      isSelectionMode = !isSelectionMode;
      selectedIndexes.clear();
    });
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
        if (selectedIndexes.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedIndexes.add(index);
        isSelectionMode = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
                      'Search',
                      style: settingstitle,
                    ),
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
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    style: BorderStyle.solid,
                    color: Color.fromARGB(255, 40, 40, 40),
                  ),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search notes...",
                  hintStyle: TextStyle(color: Colors.grey, fontFamily: 'BalsamiqSans'),
                  prefixIcon: const Icon(Icons.search, color: kgreen),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: kgreen),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              filteredNotes = List.from(notes);
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: filteredNotes.isEmpty
                    ? const Center(
                        child: Text(
                          "No notes found",
                          style: TextStyle(fontSize: 18, fontFamily: 'BalsamiqSans'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredNotes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () => editNote(index),
                              onLongPress: () => toggleSelection(index),
                              child: Homewidget(
                                title: filteredNotes[index]['title'] ?? '',
                                description: filteredNotes[index]['description'] ?? '',
                                date: filteredNotes[index]['date'] ?? '',
                                day: filteredNotes[index]['day'] ?? '',
                                time: filteredNotes[index]['time'] ?? '',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
