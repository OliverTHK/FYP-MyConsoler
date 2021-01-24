import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ModifiedLengthLimitingTextInputFormatter
    extends LengthLimitingTextInputFormatter {
  // ignore: unused_field
  final int _maxLength;

  ModifiedLengthLimitingTextInputFormatter(this._maxLength) : super(_maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return the new value when the old value has not reached the max
    // limit or the old value is composing too.
    if (newValue.composing.isValid) {
      if (maxLength != null &&
          maxLength > 0 &&
          oldValue.text.characters.length == maxLength &&
          !oldValue.composing.isValid) {
        return oldValue;
        //START OF FIX
      } else if (newValue.text.characters.length > maxLength) {
        return oldValue;
      }
      //END OF FIX
      return newValue;
    }
    if (maxLength != null &&
        maxLength > 0 &&
        newValue.text.characters.length > maxLength) {
      // If already at the maximum and tried to enter even more, keep the old
      // value.
      if (oldValue.text.characters.length == maxLength) {
        return oldValue;
      }
      return truncate(newValue, maxLength);
    }
    return newValue;
  }

  static TextEditingValue truncate(TextEditingValue value, int maxLength) {
    final CharacterRange iterator = CharacterRange(value.text);
    if (value.text.characters.length > maxLength) {
      iterator.expandNext(maxLength);
    }
    final String truncated = iterator.current;
    return TextEditingValue(
      text: truncated,
      selection: value.selection.copyWith(
        baseOffset: min(value.selection.start, truncated.length),
        extentOffset: min(value.selection.end, truncated.length),
      ),
      composing: TextRange.empty,
    );
  }
}
