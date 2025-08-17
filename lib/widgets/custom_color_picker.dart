import 'dart:math';
import 'package:flutter/material.dart';

class ColorGradientStop {
  Color color;
  double stop;

  ColorGradientStop({required this.color, required this.stop});
}

enum PickerType { solid, gradient }
enum ColorValueType { rgb, cmyk }

class CustomColorPicker extends StatefulWidget {
  final Color? initialColor;
  final List<ColorGradientStop>? initialGradient;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<List<ColorGradientStop>> onGradientChanged;

  const CustomColorPicker({
    super.key,
    this.initialColor,
    this.initialGradient,
    required this.onColorChanged,
    required this.onGradientChanged,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late PickerType _pickerType;
  late HSVColor _hsvColor;
  late List<ColorGradientStop> _gradientStops;
  ColorValueType _colorValueType = ColorValueType.rgb;

  @override
  void initState() {
    super.initState();
    if (widget.initialGradient != null && widget.initialGradient!.isNotEmpty) {
      _pickerType = PickerType.gradient;
      _gradientStops = widget.initialGradient!
          .map((s) => ColorGradientStop(color: s.color, stop: s.stop))
          .toList();
      _hsvColor = HSVColor.fromColor(_gradientStops.first.color);
    } else {
      _pickerType = PickerType.solid;
      _hsvColor = HSVColor.fromColor(widget.initialColor ?? Colors.red);
      _gradientStops = [
        ColorGradientStop(color: Colors.white, stop: 0.0),
        ColorGradientStop(color: Colors.black, stop: 1.0),
      ];
    }
  }

  void _onColorChanged() {
    widget.onColorChanged(_hsvColor.toColor());
  }

  void _onGradientChanged() {
    _gradientStops.sort((a, b) => a.stop.compareTo(b.stop));
    widget.onGradientChanged(_gradientStops);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<PickerType>(
          segments: const [
            ButtonSegment(value: PickerType.solid, label: Text('Solid Color')),
            ButtonSegment(value: PickerType.gradient, label: Text('Gradient')),
          ],
          selected: {_pickerType},
          onSelectionChanged: (newSelection) {
            setState(() {
              _pickerType = newSelection.first;
            });
          },
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pickerType == PickerType.solid
              ? _buildSolidColorMode()
              : _buildGradientMode(),
        ),
      ],
    );
  }

  Widget _buildSolidColorMode() {
    return Column(
      key: const ValueKey('solid'),
      children: [
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(flex: 2, child: LayoutBuilder(builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) => _updateHueFromGesture(details.localPosition, constraints.biggest),
                  onPanStart: (details) => _updateHueFromGesture(details.localPosition, constraints.biggest),
                  child: CustomPaint(painter: _ColorWheelPainter(hue: _hsvColor.hue), child: const SizedBox.expand()),
                );
              })),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: LayoutBuilder(builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) => _updateSVFromGesture(details.localPosition, constraints.biggest),
                  onPanStart: (details) => _updateSVFromGesture(details.localPosition, constraints.biggest),
                  child: CustomPaint(painter: _SVBoxPainter(hsvColor: _hsvColor), child: const SizedBox.expand()),
                );
              })),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAlphaSlider(),
        const SizedBox(height: 16),
        _buildValueDisplay(),
        const SizedBox(height: 16),
        _buildPresetPalettes(),
      ],
    );
  }

  Widget _buildGradientMode() {
    return Column(
      key: const ValueKey('gradient'),
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            gradient: _gradientStops.length >= 2
                ? LinearGradient(
              colors: _gradientStops.map((s) => s.color).toList(),
              stops: _gradientStops.map((s) => s.stop).toList(),
            )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _gradientStops.length,
          itemBuilder: (context, index) {
            return _buildGradientStopTile(index);
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Add Stop'),
          onPressed: () {
            setState(() {
              _gradientStops.add(ColorGradientStop(color: _gradientStops.last.color, stop: 0.5));
              _onGradientChanged();
            });
          },
        )
      ],
    );
  }

  Widget _buildGradientStopTile(int index) {
    final stop = _gradientStops[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final newColor = await _showColorSelectionDialog(stop.color);
                    if (newColor != null) {
                      setState(() {
                        stop.color = newColor;
                        _onGradientChanged();
                      });
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: stop.color,
                      border: Border.all(color: Colors.grey),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Stop ${index + 1}'),
                ),
                if (_gradientStops.length > 2)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        _gradientStops.removeAt(index);
                        _onGradientChanged();
                      });
                    },
                  )
              ],
            ),
            Slider(
              value: stop.stop,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                setState(() {
                  stop.stop = value;
                  _onGradientChanged();
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Future<Color?> _showColorSelectionDialog(Color initialColor) {
    final GlobalKey<_CustomColorPickerState> dialogPickerKey = GlobalKey();

    return showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: CustomColorPicker(
          key: dialogPickerKey,
          initialColor: initialColor,
          onColorChanged: (c) {},
          onGradientChanged: (g) {},
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              final selectedColor = dialogPickerKey.currentState?._hsvColor.toColor();
              Navigator.of(context).pop(selectedColor);
            },
          ),
        ],
      ),
    );
  }

  void _updateHueFromGesture(Offset localPosition, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final dx = localPosition.dx - centerX;
    final dy = localPosition.dy - centerY;
    final angle = atan2(dy, dx);
    final hue = (angle * 180 / pi + 360) % 360;
    setState(() {
      _hsvColor = _hsvColor.withHue(hue);
      _onColorChanged();
    });
  }

  void _updateSVFromGesture(Offset localPosition, Size size) {
    final saturation = (localPosition.dx / size.width).clamp(0.0, 1.0);
    final value = 1.0 - (localPosition.dy / size.height).clamp(0.0, 1.0);
    setState(() {
      _hsvColor = _hsvColor.withSaturation(saturation).withValue(value);
      _onColorChanged();
    });
  }

  Widget _buildAlphaSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Transparency'),
        Slider(
          value: _hsvColor.alpha,
          onChanged: (value) {
            setState(() {
              _hsvColor = _hsvColor.withAlpha(value);
              _onColorChanged();
            });
          },
        ),
      ],
    );
  }

  Widget _buildValueDisplay() {
    return Column(
      children: [
        SegmentedButton<ColorValueType>(
          segments: const [
            ButtonSegment(value: ColorValueType.rgb, label: Text('RGB')),
            ButtonSegment(value: ColorValueType.cmyk, label: Text('CMYK')),
          ],
          selected: {_colorValueType},
          onSelectionChanged: (newSelection) {
            setState(() => _colorValueType = newSelection.first);
          },
        ),
        const SizedBox(height: 8),
        _colorValueType == ColorValueType.rgb ? _buildRgbDisplay() : _buildCmykDisplay(),
      ],
    );
  }

  Widget _buildRgbDisplay() {
    final color = _hsvColor.toColor();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('R: ${color.red}'),
        Text('G: ${color.green}'),
        Text('B: ${color.blue}'),
      ],
    );
  }

  Widget _buildCmykDisplay() {
    final cmyk = _rgbToCmyk(_hsvColor.toColor());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('C: ${(cmyk[0] * 100).toStringAsFixed(0)}%'),
        Text('M: ${(cmyk[1] * 100).toStringAsFixed(0)}%'),
        Text('Y: ${(cmyk[2] * 100).toStringAsFixed(0)}%'),
        Text('K: ${(cmyk[3] * 100).toStringAsFixed(0)}%'),
      ],
    );
  }

  Widget _buildPresetPalettes() {
    final List<List<Color>> palettes = [
      [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.indigo, Colors.purple],
      [const Color(0xfff44336), const Color(0xffe91e63), const Color(0xff9c27b0), const Color(0xff673ab7)],
      [const Color(0xff00bcd4), const Color(0xff009688), const Color(0xff4caf50), const Color(0xff8bc34a)],
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: palettes.length,
        separatorBuilder: (context, index) => const VerticalDivider(),
        itemBuilder: (context, index) {
          final palette = palettes[index];
          return Row(
            children: palette.map((color) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _hsvColor = HSVColor.fromColor(color).withAlpha(_hsvColor.alpha);
                    _onColorChanged();
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<double> _rgbToCmyk(Color color) {
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;
    final k = 1.0 - [r, g, b].reduce(max);
    if (k == 1.0) return [0, 0, 0, 1];
    final c = (1 - r - k) / (1 - k);
    final m = (1 - g - k) / (1 - k);
    final y = (1 - b - k) / (1 - k);
    return [c, m, y, k];
  }
}

class _ColorWheelPainter extends CustomPainter {
  final double hue;
  const _ColorWheelPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    const List<Color> colors = [
      Color.fromARGB(255, 255, 0, 0), Color.fromARGB(255, 255, 255, 0),
      Color.fromARGB(255, 0, 255, 0), Color.fromARGB(255, 0, 255, 255),
      Color.fromARGB(255, 0, 0, 255), Color.fromARGB(255, 255, 0, 255),
      Color.fromARGB(255, 255, 0, 0),
    ];
    final shader = SweepGradient(colors: colors).createShader(Rect.fromCircle(center: center, radius: radius));

    final wheelPaint = Paint()..shader = shader;
    canvas.drawCircle(center, radius, wheelPaint);

    final angle = (hue - 90) * (pi / 180.0);
    final thumbX = center.dx + cos(angle) * radius;
    final thumbY = center.dy + sin(angle) * radius;
    final thumbPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _ColorWheelPainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

class _SVBoxPainter extends CustomPainter {
  final HSVColor hsvColor;
  const _SVBoxPainter({required this.hsvColor});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final saturationGradient = LinearGradient(
      colors: [Colors.white, HSVColor.fromAHSV(1.0, hsvColor.hue, 1.0, 1.0).toColor()],
    );
    final saturationPaint = Paint()..shader = saturationGradient.createShader(rect);
    canvas.drawRect(rect, saturationPaint);

    final valueGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.transparent, Colors.black],
    );
    final valuePaint = Paint()..shader = valueGradient.createShader(rect);
    canvas.drawRect(rect, valuePaint);

    final thumbX = hsvColor.saturation * size.width;
    final thumbY = (1.0 - hsvColor.value) * size.height;
    final thumbPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(thumbX, thumbY), 6, thumbPaint);
  }

  @override
  bool shouldRepaint(covariant _SVBoxPainter oldDelegate) {
    return oldDelegate.hsvColor != hsvColor;
  }
}
