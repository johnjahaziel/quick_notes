import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicknotes/screens/notescreen.dart';
import 'package:quicknotes/screens/search.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:quicknotes/widgets/homewidget.dart';
import 'package:quicknotes/widgets/themeprovider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Map<String, String>> notes = [];
  List<Map<String, String>> deletedNotes = [];
  bool isSelectionMode = false;
  Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadDeletedNotes();
  }

  void _sortNotes() {
    notes.sort((a, b) {
      bool aPinned = a['isPinned'] == 'true';
      bool bPinned = b['isPinned'] == 'true';

      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      return 0;
    });
  }

  void _togglePin(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notes[index]['isPinned'] = notes[index]['isPinned'] == 'true' ? 'false' : 'true';
      _sortNotes();
    });
    await prefs.setStringList('notes', notes.map((note) => jsonEncode(note)).toList());
    _saveNotes();
  }

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes');

    if (notesString != null && notesString.isNotEmpty) {
      List<dynamic> decodedNotes = json.decode(notesString);
      setState(() {
        notes = decodedNotes.map((note) {
          return {
            'title': note['title'].toString(),
            'description': note['description'].toString(),
            'date': note['date'].toString(),
            'day': note['day'].toString(),
            'time': note['time'].toString(),
            'isPinned': note['isPinned']?.toString() ?? 'false',
          };
        }).toList();
      });
    }
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notes));
  }

  void _loadDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? deletedNotesString = prefs.getString('deletedNotes');

    if (deletedNotesString != null) {
      List<dynamic> decodedDeletedNotes = json.decode(deletedNotesString);
      setState(() {
        deletedNotes = decodedDeletedNotes.map((note) {
          return {
            'title': note['title'].toString(),
            'description': note['description'].toString(),
            'date': note['date'].toString(),
            'day': note['day'].toString(),
            'time': note['time'].toString(),
          };
        }).toList();
      });
    }
  }

  void _saveDeletedNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('deletedNotes', json.encode(deletedNotes));
  }

  void deleteNoteToRecycleBin(int index) {
    setState(() {
      deletedNotes.add(notes[index]);
      notes.removeAt(index);
    });
    _saveNotes();
    _saveDeletedNotes();
  }

  void addNote() async {
    final newNote = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notescreen()),
    );

    if (newNote != null) {
        setState(() {
          notes.add(newNote);
        });
        _saveNotes();
      }
    }

  void editNote(int index) async {
    if (isSelectionMode) {
      toggleSelection(index);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notescreen(
          title: notes[index]['title'],
          description: notes[index]['description'],
          date: notes[index]['date'],
          day: notes[index]['day'],
          time: notes[index]['time'],
          index: index,
        ),
      ),
    );

    if (result != null) {
      if (result['delete'] == true) {
        setState(() {
          notes.removeAt(index);
        });
      } else {
        setState(() {
          notes[index] = result;
        });
      }
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

  void deleteSelectedNotes() async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, String>> deletedNotes = selectedIndexes.map((index) => notes[index]).toList();

    final String? deletedNotesString = prefs.getString('deleted_notes');
    List<Map<String, String>> recycleBinNotes = deletedNotesString != null
        ? List<Map<String, String>>.from(json.decode(deletedNotesString))
        : [];

    recycleBinNotes.addAll(deletedNotes);
    prefs.setString('deleted_notes', json.encode(recycleBinNotes));

    setState(() {
      notes = notes.asMap().entries
          .where((entry) => !selectedIndexes.contains(entry.key))
          .map((entry) => entry.value)
          .toList();
      selectedIndexes.clear();
      isSelectionMode = false;
    });

    _saveNotes();
  }

  void selectAll() {
    setState(() {
      if (selectedIndexes.length == notes.length) {
        selectedIndexes.clear();
        isSelectionMode = false;
      } else {
        selectedIndexes.addAll(List.generate(notes.length, (index) => index));
        isSelectionMode = true;
      }
    });
  }

  void sort() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Sort Notes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha,color: kgreen),
                  title: const Text("Sort by Title (A-Z)"),
                  onTap: () {
                    setState(() {
                      notes.sort((a, b) => a['title']!.toLowerCase().compareTo(b['title']!.toLowerCase()));
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha,color: kgreen),
                  title: const Text("Sort by Title (Z-A)"),
                  onTap: () {
                    setState(() {
                      notes.sort((a, b) => b['title']!.toLowerCase().compareTo(a['title']!.toLowerCase()));
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today,color: kgreen),
                  title: const Text("Sort by Date (Newest First)"),
                  onTap: () {
                    setState(() {
                      notes.sort((a, b) => DateTime.parse(b['date']!).compareTo(DateTime.parse(a['date']!)));
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today,color: kgreen,),
                  title: const Text("Sort by Date (Oldest First)"),
                  onTap: () {
                    setState(() {
                      notes.sort((a, b) => DateTime.parse(a['date']!).compareTo(DateTime.parse(b['date']!)));
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var isDarkMode = themeProvider.isDarkMode;
    var theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('images/RectQN.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10),
                      child: Text(
                        'Notes',
                        style: header,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: IconButton(
                        icon: Icon(
                          isDarkMode ? Icons.nightlight_round : Icons.sunny,
                          size: 32,
                          color: Colors.white
                        ),
                        onPressed: () {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: isSelectionMode ? selectAll : sort,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: kgreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        isSelectionMode ? Icons.select_all : Icons.sort,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: isSelectionMode ? deleteSelectedNotes : toggleSelectionMode,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: kgreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        isSelectionMode ? Icons.delete : Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: isSelectionMode ? () {}
                    : () {
                      Navigator.pushNamed(context, Search.id);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: kgreen,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child:  notes.isEmpty
                ? const Center(child: Text("No Notes yet"))
                : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: Key(notes[index]['title'] ?? index.toString()),
                        direction: DismissDirection.startToEnd,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Delete Note",
                                style: TextStyle(
                                  fontFamily: 'BalsamiqSans'
                                ),
                              ),
                              content: const Text(
                                "Are you sure you want to delete this note?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontFamily: 'BalsamiqSans'
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'BalsamiqSans'
                                    )
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          deleteNoteToRecycleBin(index);
                        },
                        child: GestureDetector(
                          onTap: () => editNote(index),
                          onLongPress: () => toggleSelection(index),
                          child: Row(
                            children: [
                              if (isSelectionMode)
                                Checkbox(
                                  activeColor: kgreen,
                                  value: selectedIndexes.contains(index),
                                  onChanged: (bool? value) {
                                    toggleSelection(index);
                                  },
                                ),
                              Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  transform: Matrix4.translationValues(
                                    isSelectionMode ? -8 : 0, 0, 0,
                                  ),
                                  child: Homewidget(
                                    title: notes[index]['title'] ?? '',
                                    description: notes[index]['description'] ?? '',
                                    date: notes[index]['date'] ?? '',
                                    day: notes[index]['day'] ?? '',
                                    time: notes[index]['time'] ?? '',
                                    isInitiallyPinned: notes[index]['isPinned'] == 'true',
                                    onPinToggle: () => _togglePin(index),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addNote,
          backgroundColor: kgreen,
          shape: const CircleBorder(
            eccentricity: 0.2,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
