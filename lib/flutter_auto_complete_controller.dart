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

    List<TextSpan> spans = [];
    int start = 0;

    while (start < text.length) {
      // Identify the start of a tag
      if (_tagStyles.containsKey(text[start])) {
        int end = start + 1;
        // Find the end of the tag (non-space character sequence)
        while (end < text.length && text[end] != ' ' && !_tagStyles.containsKey(text[end])) {
          end++;
        }
        // Extract the tag and apply the appropriate style
        final tag = text.substring(start, end);
        spans.add(_getStyledTag(tag));
        start = end; // Move start to the end of the tag
      } else {
        // Find the next space or trigger character
        int end = start;
        while (end < text.length && text[end] != ' ' && !_tagStyles.containsKey(text[end])) {
          end++;
        }
        // Add the non-tag text
        spans.add(TextSpan(text: text.substring(start, end), style: style));
        start = end; // Move start to the end of the word or space
      }

      // Add a space if we're not at the end of the text
      if (start < text.length && text[start] == ' ') {
        spans.add(const TextSpan(text: " "));
        start++;
      }
    }

    return TextSpan(children: spans, style: style);
  }

  TextSpan _getStyledTag(String word) {
    String triggerChar = word[0];

    // Apply style based on the trigger character
    if (_tags.containsKey(word)) {
      return TextSpan(
        text: word,
        style: _tagStyles[triggerChar],
      );
    } else {
      // If the tag is not found, return it as normal text with default style
      return TextSpan(text: word, style: _tagStyles[triggerChar] ?? TextStyle());
    }
  }
}
