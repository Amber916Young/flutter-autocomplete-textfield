import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int? maxLength;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final Color? fillColor;
  final int maxLines;
  final bool isPassword;
  final bool isIcon;
  final Function? onTap;
  final Function? onChanged;
  final Function? onSuffixTap;
  final String? suffixIconUrl;
  final String? prefixIconUrl;
  final bool isSearch;
  final Function? onSubmit;
  final bool isEnabled;
  final TextCapitalization capitalization;
  final bool readOnly;
  final EdgeInsetsGeometry? contentPadding;
  const CustomTextField({
    Key? key,
    this.hintText = 'Write something...',
    this.controller,
    this.contentPadding,
    this.labelText,
    this.focusNode,
    this.maxLength = 0,
    this.nextFocus,
    this.readOnly = false,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSuffixTap,
    this.fillColor,
    this.onSubmit,
    this.onChanged,
    this.capitalization = TextCapitalization.none,
    this.onTap,
    this.isIcon = false,
    this.isPassword = false,
    this.suffixIconUrl,
    this.prefixIconUrl,
    this.isSearch = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  int textLength = 0;

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return TextFormField(
        minLines: 1,
        maxLines: widget.maxLines,
        controller: widget.controller,
        maxLength: widget.maxLength == 0 ? null : widget.maxLength,
        focusNode: widget.focusNode,
        style: themeData.textTheme.titleMedium?.copyWith(color: themeData.textTheme.bodyLarge!.color, fontSize: 20),
        textInputAction: widget.inputAction,
        keyboardType: widget.inputAction == TextInputAction.newline ? null : widget.inputType,
        cursorColor: themeData.primaryColor,
        textCapitalization: widget.capitalization,
        enabled: widget.isEnabled,
        autofocus: false,
        readOnly: widget.readOnly,
        obscureText: widget.isPassword ? _obscureText : false,
        inputFormatters: widget.inputType == TextInputType.phone
            ? <TextInputFormatter>[FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]
            : null,
        decoration: InputDecoration(
          contentPadding: widget.contentPadding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeData.primaryColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: themeData.primaryColor),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: themeData.primaryColor),
          ),
          isDense: true,
          hintText: widget.hintText,
          hintStyle: themeData.textTheme.titleMedium?.copyWith(fontSize: 16, color: themeData.primaryColor),
          filled: true,
        ),
        onTap: widget.onTap as void Function()?,
        onFieldSubmitted: (text) => widget.nextFocus != null
            ? FocusScope.of(context).requestFocus(widget.nextFocus)
            : widget.onSubmit != null
                ? widget.onSubmit!(text)
                : null,
        onChanged: (value) {
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        });
  }
}
