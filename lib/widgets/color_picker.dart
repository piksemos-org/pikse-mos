import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlockPicker(
      pickerColor: currentColor,
      onColorChanged: onColorChanged,
    );
  }
}
