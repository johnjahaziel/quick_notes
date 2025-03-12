// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quicknotes/screens/navigation.dart';
import 'package:quicknotes/utility/styles.dart';
import 'package:quicknotes/widgets/fontprovider.dart';
import 'package:share_plus/share_plus.dart';

class Notescreen extends StatefulWidget {
  static const String id = 'Notescreen';
  final String? title;
  final String? description;
  final String? date;
  final String? day;
  final String? time;
  final int? index;

  const Notescreen({
    super.key,
    this.title,
    this.description,
    this.date,
    this.day,
    this.time,
    this.index
  });

  @override
  State<Notescreen> createState() => _NotescreenState();
}

class _NotescreenState extends State<Notescreen> {
  bool bookmark = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool _showFormattingOptions = false;
  TextAlign _textAlignment = TextAlign.left;
  IconData _alignmentIcon = Icons.format_align_left;
  Color _selectedTextColor = Colors.black;
  String _selectedFont = 'Roboto';
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;
  bool isHighlighting = false;
  Color highlightColor = Colors.yellow;
  List<TableData> tables = [];

  void toggleBold() {
    setState(() {
      isBold = !isBold;
    });
  }

  void toggleItalic() {
    setState(() {
      isItalic = !isItalic;
    });
  }

  void toggleUnderline() {
    setState(() {
      isUnderline = !isUnderline;
    });
  }

  void toggleStrikethrough() {
    setState(() {
      isStrikethrough = !isStrikethrough;
    });
  }

  void toggleHighlight() {
    setState(() {
      isHighlighting = !isHighlighting;
    });
  }

  void _showFontPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 15,left: 15),
          height: 350,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Font",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildFontOption('Roboto'),
              _buildFontOption('Lobster'),
              _buildFontOption('Pacifico'),
              _buildFontOption('Playfair Display'),
              _buildFontOption('Indie Flower'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFontOption(String fontName) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFont = fontName;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: _selectedFont == fontName ? Colors.grey[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(fontName, style: GoogleFonts.getFont(fontName, fontSize: 18)),
      ),
    );
  }

  TextStyle getFormattedTextStyle(BuildContext context) {
    var fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return GoogleFonts.getFont(
      _selectedFont,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.combine([
        if (isUnderline) TextDecoration.underline,
        if (isStrikethrough) TextDecoration.lineThrough,
      ]),
      fontSize: fontSizeProvider.fontSize,
    ).copyWith(
      color: (_selectedTextColor == Colors.black)
          ? Theme.of(context).textTheme.bodyLarge?.color
          : _selectedTextColor,
      backgroundColor: isHighlighting ? highlightColor : Colors.transparent,
    );
  }

  String date = '';
  String day = '';
  String time = '';

  void _showFontSizePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<FontSizeProvider>(
          builder: (context, fontSizeProvider, child) {
            double currentFontSize = fontSizeProvider.fontSize;

            return StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  height: 120,
                  child: Column(
                    children: [
                      const Text(
                        "Adjust Font Size",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle, size: 30),
                            onPressed: () {
                              if (currentFontSize > fontSizeProvider.minFontSize) {
                                fontSizeProvider.setFontSize(currentFontSize - 1);
                                setModalState(() {});
                              }
                            },
                          ),
                          Text(
                            "${currentFontSize.toInt()}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, size: 30),
                            onPressed: () {
                              if (currentFontSize < fontSizeProvider.maxFontSize) {
                                fontSizeProvider.setFontSize(currentFontSize + 1);
                                setModalState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void toggleBookmark() {
    setState(() {
      bookmark = !bookmark;
    });
  }

  void _toggleTextAlignment() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAlignmentOption(TextAlign.left, Icons.format_align_left),
              _buildAlignmentOption(TextAlign.center, Icons.format_align_center),
              _buildAlignmentOption(TextAlign.right, Icons.format_align_right),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlignmentOption(TextAlign align, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _textAlignment = align;
          _alignmentIcon = icon;
        });
        Navigator.pop(context);
      },
      child: CircleAvatar(
        backgroundColor: _textAlignment == align ? Colors.grey[300] : Colors.white,
        radius: 25,
        child: Icon(
          icon,
          color: Colors.black,
          size: 30,
        ),
      ),
    );
  }
  
  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorOption(Colors.black),
              _buildColorOption(Colors.red),
              _buildColorOption(Colors.blue),
              _buildColorOption(Colors.green),
              _buildColorOption(Colors.purple),
              _buildCustomColorOption(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildColorOption(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTextColor = ((color == Colors.black)
              ? Theme.of(context).textTheme.bodyLarge?.color
              : color)!;
        });
        Navigator.pop(context);
      },
      child: CircleAvatar(
        backgroundColor: color,
        radius: 20,
      ),
    );
  }

  void _showTableDialog() {
    int rows = 2;
    int columns = 2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Insert Table"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Rows"),
                onChanged: (value) => rows = int.tryParse(value) ?? 2,
              ),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Columns"),
                onChanged: (value) => columns = int.tryParse(value) ?? 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _insertTable(rows, columns);
              },
              child: Text("Insert"),
            ),
          ],
        );
      },
    );
  }

  void _insertTable(int rows, int columns) {
    setState(() {
      tables.add(TableData(rows, columns));
    });
  }

  Widget _buildCustomColorOption() {
    return GestureDetector(
      onTap: _pickCustomColor,
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
        child: const Icon(Icons.palette, color: Colors.black),
      ),
    );
  }

  void _pickCustomColor() {
    Color tempColor = _selectedTextColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Pick a Custom Color"),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                tempColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedTextColor = ((tempColor == Colors.black)
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : tempColor)!;
                });
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Done"),
            ),
          ],
        );
      },
    );
  }

  void _shareNote() {
    final String noteContent = "Title📝: ${widget.title}\n\nDescription:${widget.description}\n\nDate📅: ${widget.day}, ${widget.date} - ${widget.time}";
    Share.share(noteContent);
  }

  void _confirmDeleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, {'delete': true});
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedTextColor = Colors.black;

    titleController.text = widget.title ?? '';
    descriptionController.text = widget.description ?? '';

    date = widget.date ?? DateFormat('dd MMM yyyy').format(DateTime.now());
    day = widget.day ?? DateFormat('EEEE').format(DateTime.now());
    time = widget.time ?? DateFormat('h:mm a').format(DateTime.now());
  }

  void saveNote() {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both title and description!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime now = DateTime.now();
    String date = DateFormat('dd MMM yyyy').format(now);
    String day = DateFormat('EEEE').format(now);
    String time = DateFormat('h:mm a').format(now);

    Navigator.pop(context, {
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'day': day,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
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
                              padding: const EdgeInsets.only(right: 25, top: 16),
                              child: GestureDetector(
                                onTap: saveNote,
                                child: const Icon(
                                  Icons.save,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 5),
                      child: Stack(
                        children: [
                          TextField(
                            controller: titleController,
                            maxLines: null,
                            maxLength: 200,
                            inputFormatters: [LengthLimitingTextInputFormatter(200)],
                            decoration: InputDecoration(
                              hintText: 'Note Title...',
                              hintStyle: notetitle,
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            style: notetitle,
                            onChanged: (text) {
                              setState(() {});
                            },
                          ),
                          Positioned(
                            right: 8,
                            bottom: 2,
                            child: Text(
                              '${titleController.text.length}/200',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color.fromARGB(255, 87, 87, 87),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 2,
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15),
                      child: SizedBox(
                        height: tables.isNotEmpty ? 100 : 700,
                        child: TextField(
                          textAlign: _textAlignment,
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Enter your note here...',
                            hintStyle: notedescription,
                            border: InputBorder.none,
                          ),
                          style: getFormattedTextStyle(context),
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    for (var tableData in tables)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Table(
                        border: TableBorder.all(color: Colors.black),
                        children: List.generate(
                          tableData.rows,
                          (rowIndex) => TableRow(
                            children: List.generate(
                              tableData.columns,
                              (colIndex) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  controller: tableData.controllers[rowIndex][colIndex],
                                  decoration: InputDecoration(border: InputBorder.none),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: _showFormattingOptions ? Curves.easeOutBack : Curves.easeInBack,
                  height: _showFormattingOptions ? 50 : 0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 56, 56, 56),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)
                    )
                  ),
                  child: _showFormattingOptions
                    ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _showFontSizePicker,
                        child: const Icon(
                          Icons.exposure,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleBold,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.format_bold_outlined,
                            color: isBold ? Colors.yellow : Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleItalic,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.format_italic,
                            color: isItalic ? Colors.yellow : Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleUnderline,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.format_underline,
                            color: isUnderline ? Colors.yellow : Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleHighlight,
                        child: Image(
                          image: AssetImage('images/MarkerPen.png'),
                          height: 30,
                          width: 30,
                          color: isHighlighting ? Colors.yellow : Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleStrikethrough,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.strikethrough_s,
                            color: isStrikethrough ? Colors.yellow : Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _showFontPicker,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: const Icon(
                            Icons.abc,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showTableDialog();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: const Icon(
                            Icons.table_chart,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ) : SizedBox.shrink(),
                ),
                Stack(
                  children: [
                    Container(
                      height: 75,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: kgreen,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'BalsamiqSans',
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$day at $time',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'BalsamiqSans',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            SizedBox(
                              height: 75,
                              child: const VerticalDivider(
                                color: Colors.white,
                                width: 2,
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showFormattingOptions = !_showFormattingOptions;
                            });
                          },
                          child: const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showColorPicker();
                          },
                          child: Image(
                            image: AssetImage('images/ColorMode.png'),
                            height: 30,
                            width: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleTextAlignment,
                          child: Icon(
                            _alignmentIcon,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: _confirmDeleteNote,
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        GestureDetector(
                          onTap: _shareNote,
                          child: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TableData {
  int rows, columns;
  List<List<TextEditingController>> controllers = [];

  TableData(this.rows, this.columns) {
    for (int i = 0; i < rows; i++) {
      controllers.add(
        List.generate(columns, (index) => TextEditingController()),
      );
    }
  }
}