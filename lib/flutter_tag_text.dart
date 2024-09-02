import 'package:flutter/material.dart';
import 'package:tagtrigger/custom_text_field.dart';
import 'package:tagtrigger/flutter_auto_complete_controller.dart';

Map<String, TextStyle> tagStyles = {
  "@": const TextStyle(color: Colors.pinkAccent),
  "#": const TextStyle(color: Colors.blueAccent),
};

class FlutterTagTextField extends StatefulWidget {
  const FlutterTagTextField({super.key});

  @override
  State<FlutterTagTextField> createState() => _FlutterTagTextFieldState();
}

class _FlutterTagTextFieldState extends State<FlutterTagTextField> {
  final FlutterAutoCompleteController _controller = FlutterAutoCompleteController();
  final FocusNode _contextFocus = FocusNode();
  String _currentTriggerChar = '';
  bool _shouldSearch = false;
  final RegExp triggerRegExp = RegExp(r'^[\p{L}\p{N}-]*$', unicode: true);
  List<String> _predictions = [];
  Map<String, String> tags = {};
  final RegExp _triggerCharactersPattern = RegExp(r'[#@]');
  Set<String> triggerCharacters = {'@', '#'};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_tagListener);
    _controller.setTagStyles(tagStyles);
    _controller.setTriggerCharsPattern(triggerRegExp);
    _controller.setTags(tags);
  }

  String get _formattedText {
    String controllerText = _controller.text;
    if (controllerText.isEmpty) return "";
    List<String> result = [];
    int length = controllerText.length;
    int startIndex = 0;

    while (startIndex < length) {
      final char = controllerText[startIndex];
      if (_triggerCharactersPattern.hasMatch(char)) {
        int endIndex = startIndex + 1;
        // Continue until you hit a space or another trigger character
        while (endIndex < length &&
            !_triggerCharactersPattern.hasMatch(controllerText[endIndex]) &&
            controllerText[endIndex] != ' ') {
          endIndex++;
        }

        final tagOrMention = controllerText.substring(startIndex, endIndex);
        final parsedText = tags[tagOrMention] ?? tagOrMention;
        result.add(parsedText);

        startIndex = endIndex;
      } else {
        result.add(char);
        startIndex++;
      }
    }
    return result.join("");
  }

  void _tagListener() {
    _onCursorMove();
    int cursorPosition = _controller.selection.baseOffset;
    _controller.setFormattedText(_formattedText);
    print('$_shouldSearch $cursorPosition $_formattedText');
    if (!_shouldSearch) {
      setState(() {
        _predictions = [];
      });
    }
  }

  int? previousCursorPosition; // Track the previous cursor position

  void _onCursorMove() {
    _shouldSearch = false;

    String controllerText = _controller.text;
    TextEditingController controller = _controller;

    // Get the current cursor position
    int cursorPosition = controller.selection.baseOffset;

    // Return if the text is empty
    if (controllerText.isEmpty) {
      return;
    }

    // Determine if the cursor has moved back
    if (previousCursorPosition != null) {
      if (cursorPosition < previousCursorPosition!) {
        // Handle backward movement
        _handleCursorMoveBack(controllerText, cursorPosition);
      } else if (cursorPosition > previousCursorPosition!) {
        // Handle forward movement
        _handleCursorMoveForward(controllerText, cursorPosition);
      }
    }

    // Update the previous cursor position for future checks
    previousCursorPosition = cursorPosition;
  }

  void _handleCursorMoveBack(String text, int cursorPosition) {
    int startIndex = cursorPosition - 1;

    // Identify the start of the tag (search backwards)
    while (startIndex > 0 && text[startIndex] != ' ' && !_triggerCharactersPattern.hasMatch(text[startIndex])) {
      startIndex--;
    }

    // If the cursor is inside a tag (i.e., after the '#' and before a space or end of tag)
    if (startIndex > 0 && _triggerCharactersPattern.hasMatch(text[startIndex])) {
      _shouldSearch = true;
      _currentTriggerChar = text[startIndex];
      int endIndex = cursorPosition;
      while (endIndex < text.length && text[endIndex] != ' ') {
        endIndex++;
      }
      String query = text.substring(startIndex + 1, endIndex).trim();
      print("_handleCursorMoveBack query   $query");
      if (query.isNotEmpty && cursorPosition > startIndex + 1 && triggerRegExp.hasMatch(query)) {
        _shouldSearch = true;
        _updatePredictions(query);
      } else {
        _shouldSearch = false;
        setState(() {
          _predictions = [];
        });
      }
    }
  }

  void _handleCursorMoveForward(String text, int cursorPosition) {
    // Start from the current cursor position and find the start of the tag
    int startIndex = cursorPosition - 1;

    // Find the start of the tag by moving backward
    while (startIndex > 0 && text[startIndex] != ' ' && !_triggerCharactersPattern.hasMatch(text[startIndex])) {
      startIndex--;
    }

    // Check if the position is inside a tag
    // Tag is considered valid if it starts with a trigger character and ends with a non-space
    if (startIndex >= 0 && _triggerCharactersPattern.hasMatch(text[startIndex])) {
      _currentTriggerChar = text[startIndex];
      int endIndex = cursorPosition;
      while (endIndex < text.length && text[endIndex] != ' ') {
        endIndex++;
      }
      // Extract the tag content
      String query = text.substring(startIndex + 1, endIndex).trim();
      print("_handleCursorMoveForward query   $query");
      if (query.isNotEmpty && cursorPosition > startIndex + 1 && triggerRegExp.hasMatch(query)) {
        _shouldSearch = true;
        if (query.isNotEmpty) {
          _updatePredictions(query);
        } else {
          _shouldSearch = false;
          setState(() {
            _predictions = [];
          });
        }
      }
    }
  }

  void _onPredictionSelected(String selectedPrediction) {
    final text = _controller.text;
    final currentCursorPosition = _controller.selection.baseOffset;
    final position = currentCursorPosition - 1;
    _extractAndReplace(text, position, selectedPrediction);
  }

  void _updatePredictions(String query) {
    setState(() {
      if (_currentTriggerChar == '#') {
        _predictions = ['key1', 'key2', 'key3'];
      } else if (_currentTriggerChar == '@') {
        _predictions = ['name1', 'name2', 'name3'];
      }
    });
  }

  bool _extractAndReplace(String text, int endOffset, String selectedPrediction) {
    try {
      int index = text.substring(0, endOffset).lastIndexOf(_currentTriggerChar);

      if (index < 0) return false;

      final realValue = _getRealValue(selectedPrediction);
      final id = _getIdForValue(realValue);

      if (realValue.isNotEmpty) {
        String replacementText = '$_currentTriggerChar$id#$realValue# ';
        String displayText = '$_currentTriggerChar$realValue ';
        setState(() {
          _replaceMatchedText(text.substring(index, endOffset + 1), replacementText, displayText);
        });
        _shouldSearch = false;
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  String _getRealValue(String query) {
    return query;
  }

  String _getIdForValue(String realValue) {
    return '123';
  }

  void _replaceMatchedText(String matchedText, String replacementText, String displayText) {
    String currentText = _controller.text;
    int startIndex = currentText.lastIndexOf(matchedText);

    if (startIndex != -1) {
      // Update the storage format
      String newStorageText = currentText.replaceRange(
        startIndex,
        startIndex + matchedText.length,
        replacementText,
      );

      // Update the display format
      String newDisplayText = currentText.replaceRange(
        startIndex,
        startIndex + matchedText.length,
        displayText,
      );
      _controller.value = TextEditingValue(
        text: newDisplayText,
        selection: TextSelection.collapsed(offset: newDisplayText.length),
      );
      tags[displayText.trim()] = replacementText.trim();
      _controller.setTags(tags);
    }
  }

  void _insertTextAtCursor(String textToInsert) {
    final currentText = _controller.text;
    final cursorPosition = _controller.selection.baseOffset;
    final newText = currentText.replaceRange(
      cursorPosition,
      cursorPosition,
      "$textToInsert ",
    );
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: cursorPosition + textToInsert.length);
  }

  void _onHashTagTapped() {
    _insertTextAtCursor('#');
  }

  void _onAtSymbolTapped() {
    _insertTextAtCursor('@');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                onTap: () {
                  _onHashTagTapped();
                },
                child: Text("#")),
            SizedBox(
              width: 20,
            ),
            InkWell(
                onTap: () {
                  _onAtSymbolTapped();
                },
                child: Text("@")),
          ],
        ),
        CustomTextField(
          focusNode: _contextFocus,
          maxLines: 10,
          controller: _controller,
        ),
        if (_predictions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            itemCount: _predictions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_predictions[index]),
                onTap: () => _onPredictionSelected(_predictions[index]),
              );
            },
          ),
      ],
    );
  }
}
