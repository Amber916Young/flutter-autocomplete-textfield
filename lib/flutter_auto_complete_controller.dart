import 'package:flutter/material.dart';

class FlutterAutoCompleteController extends TextEditingController {
  FlutterAutoCompleteController({String? text}) : super(text: text);
  late Map<String, TextStyle> _tagStyles;
  late Map<String, String> _tags;
  late String _formattedText;

  String get formattedText => _formattedText;

  RegExp? _triggerCharsPattern;

  void setFormattedText(String formattedText) {
    _formattedText = formattedText;
  }
  void setTagStyles(Map<String, TextStyle> tagStyles) {
    _tagStyles = tagStyles;
  }

  void setTriggerCharsPattern(triggerCharsPattern) {
    _triggerCharsPattern = triggerCharsPattern;
  }

  void setTags(Map<String, String> tags) {
    _tags = tags;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    assert(!value.composing.isValid || !withComposing || value.isComposingRangeValid);

    return _buildTextSpan(style);
  }

  TextSpan _buildTextSpan(TextStyle? style) {
    if (text.isEmpty) return const TextSpan();

    final splitText = text.split(" ");
    List<TextSpan> spans = [];
    int start = 0;

    for (int i = 0; i < splitText.length; i++) {
      final currentText = splitText[i];
      final triggerChar = currentText.isNotEmpty && _tagStyles.containsKey(currentText[0]) ? currentText[0] : null;

      if (triggerChar != null) {
        final styledText = _getStyledTag(currentText);
        spans.add(styledText);
      } else {
        spans.add(TextSpan(text: currentText, style: style));
      }

      spans.add(const TextSpan(text: " "));
    }

    return TextSpan(children: spans, style: style);
  }

  TextSpan _getStyledTag(String word) {
    String triggerChar = word[0];
    String tagWithoutTrigger = word.substring(1);

    // Check if the tag is in the _tags Map
    if (_tags.containsKey(word)) {
      return TextSpan(
        text: word,
        style: _tagStyles[triggerChar],
      );
    } else {
      // If the tag is not found, return it as normal text
      return TextSpan(text: word);
    }
  }
}
