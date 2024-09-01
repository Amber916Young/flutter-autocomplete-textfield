import 'package:flutter/material.dart';
import 'package:tagtrigger/custom_text_field.dart';
import 'package:tagtrigger/flutter_auto_complete_controller.dart';

Map<String, TextStyle> tagStyles = {
  "@": TextStyle(color: Colors.pinkAccent),
  "#": TextStyle(color: Colors.blueAccent),
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
  final RegExp regExp = RegExp(r'^[\p{L}\p{N}-]*$', unicode: true);
  List<String> _predictions = []; // List to store predictions
  Map<String, String> tags = {};
  final RegExp _triggerCharactersPattern = RegExp(r'[@#]');
  Set<String> triggerCharacters = {'@', '#'};
  String? _lastCachedText;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_tagListener);
    _controller.setTagStyles(tagStyles);
    _controller.setTriggerCharsPattern(regExp);
    _controller.setTags(tags);
  }
  String get _formattedText {
    String controllerText =_controller.text;

    if (controllerText.isEmpty) return "";

    final splitText = controllerText.split(" ");

    List<String> result = [];
    int length = splitText.length;

    for (int i = 0; i < length; i++) {
      final text = splitText[i];

      if (text.contains(_triggerCharactersPattern)) {
        final parsedText = tags[text]??"";
        result.add(parsedText);
      } else {
        result.add(text);
      }
    }

    final resultString = result.join(" ");

    return resultString;
  }

  void _tagListener() {
    int cursorPosition = _controller.selection.baseOffset;
    print('Cursor position: $cursorPosition');
    if (cursorPosition > 0 && cursorPosition <= _controller.text.length) {
      String lastCharacter = _controller.text.substring(cursorPosition - 1, cursorPosition);
      print('Last character before cursor: $lastCharacter');
    }
    //
    // if (_backtrackAndSearch()) {
    //   print('Re-entered search context due to backtracking.');
    //   return; // Exit if backtracking triggers a search
    // }
    String text = _controller.text;
    final position = cursorPosition - 1;
    _controller.setFormattedText(_formattedText);

    if (position >= 0) {
      String query = _extractValidQuery(text, position);
      print("query $query");
      if (query.isNotEmpty) {
        _updatePredictions(query);
      } else {
        _shouldSearch = false;
        setState(() {
           _predictions = [];
        });
      }
    }
    // Activate search context if a trigger character is found
    if (position >= 0 && ['#', '@'].contains(text[position])) {
      _currentTriggerChar = text[position];
      _shouldSearch = true;
    }
  }

  bool _backtrackAndSearch() {
    String text = _controller.text;
    if (!text.contains(_triggerCharactersPattern)) return false;

    _lastCachedText = text;
    final length = _controller.selection.baseOffset - 1;

    for (int i = length; i >= 0; i--) {
      if ((i == length && triggerCharacters.contains(text[i])) ||
          !triggerCharacters.contains(text[i]) && !regExp.hasMatch(text[i])) {
        return false;
      }

      if (triggerCharacters.contains(text[i])) {
        final doesTagExistInRange = tags.keys.any(
          (tag) => text.indexOf(tag, i) == i && text.indexOf(tag, i) + tag.length == length + 1,
        );

        if (doesTagExistInRange) return false;

        _currentTriggerChar = text[i];
        _shouldSearch = true;
        if (text.isNotEmpty) {
          _extractAndSearch(text, length);
        }

        return true;
      }
    }

    return false;
  }

  void _extractAndSearch(String text, int length) {
    // Here you would implement the logic for what should happen when the search context is re-entered.
    print('Extracting and searching for: ${text.substring(length)}');
  }

  String _extractValidQuery(String text, int endOffset) {
    int index = text.lastIndexOf(_currentTriggerChar, endOffset);
    if (index < 0) return '';
    final query = text.substring(index + 1, endOffset + 1).trim();
    if (query.contains(' ') || !regExp.hasMatch(query)) {
      return '';
    }
    return query;
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
        _shouldSearch = false; // Stop search after replacement
        _predictions = []; // Clear predictions
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return false;
  }

  String _getRealValue(String query) {
    // Mock logic: return a "real value" based on the query
    // Replace this with your actual logic to fetch the real value
    if (_currentTriggerChar == '#') {
      return 'realvalue';
    } else if (_currentTriggerChar == '@') {
      return 'kate';
    }
    return query;
  }

  String _getIdForValue(String realValue) {
    // Mock logic: return an "id" based on the real value
    // Replace this with your actual logic to fetch the id
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
