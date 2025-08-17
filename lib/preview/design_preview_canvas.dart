import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../piksel/desain/models/brief_data_model.dart';
import '../widgets/custom_color_picker.dart';

class DesignPreviewCanvas extends StatefulWidget {
  const DesignPreviewCanvas({super.key});

  @override
  State<DesignPreviewCanvas> createState() => _DesignPreviewCanvasState();
}

class _DesignPreviewCanvasState extends State<DesignPreviewCanvas> {
  String? _selectedId;
  String? _selectedType; // 'text' | 'image'
  bool _showGrid = true;
  bool _showRulers = true;
  bool _pinMode = false;
  int _tab = 0; // 0 canvas, 1 settings, 2 info
  double _gridSize = 20;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<BriefDataModel>();
    // Interpretasi baru: "panjang"=width, "lebar"=height
    final aspect = (data.lebar > 0 && data.panjang > 0)
        ? data.panjang / data.lebar // width / height = aspect ratio (landscape>1, portrait<1)
        : 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(data),
          const SizedBox(height: 12),
          // Canvas card (tanpa footer di dalamnya untuk hindari overflow)
          SizedBox(
            height: 340,
            child: _buildCanvasCard(data, aspect),
          ),
          const SizedBox(height: 12),
          // Footer info dipindah ke luar card agar tidak memaksa tinggi fixed
          _buildFrameFooter(data),
          const SizedBox(height: 12),
          _buildTabs(data),
          const SizedBox(height: 8),
          _buildTips(),
        ],
      ),
    );
  }

  Widget _buildHeader(BriefDataModel data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.design_services, color: Colors.blue.shade600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Blueprint Canvas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${data.panjang.toInt()} × ${data.lebar.toInt()} ${data.satuanUkuran}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tool(icon: _showGrid ? Icons.grid_on : Icons.grid_off, label: 'Grid', active: _showGrid,
                  onTap: () => setState(() => _showGrid = !_showGrid)),
              _tool(icon: _showRulers ? Icons.straighten : Icons.straighten_outlined, label: 'Rulers', active: _showRulers,
                  onTap: () => setState(() => _showRulers = !_showRulers)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Undo',
                      icon: Icon(Icons.undo, color: data.canUndo ? Colors.blue.shade600 : Colors.grey.shade400),
                      onPressed: data.canUndo ? data.undo : null,
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.shade300),
                    IconButton(
                      tooltip: 'Redo',
                      icon: Icon(Icons.redo, color: data.canRedo ? Colors.blue.shade600 : Colors.grey.shade400),
                      onPressed: data.canRedo ? data.redo : null,
                    ),
                    Container(width: 1, height: 20, color: Colors.grey.shade300),
                    IconButton(
                      tooltip: 'Pin',
                      icon: Icon(Icons.push_pin, color: _pinMode ? Colors.red.shade400 : Colors.grey.shade500),
                      onPressed: () => setState(() => _pinMode = !_pinMode),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _tool({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? Colors.blue.shade200 : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: active ? Colors.blue.shade600 : Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.blue.shade600 : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvasCard(BriefDataModel data, double aspect) {
    final ratio = (aspect.isFinite && aspect > 0) ? aspect : 1.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
      children: [
            _buildFrameHeader(data),
        Expanded(
            child: Container(
                margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: LayoutBuilder(
                builder: (context, constraints) {
                      // Hitung ukuran kanvas agar selalu sesuai rasio W:H dan fit ke area yang tersedia
                      double maxW = constraints.maxWidth;
                      double maxH = constraints.maxHeight;
                      double canvasW = maxW;
                      double canvasH = canvasW / ratio;
                      if (canvasH > maxH) {
                        canvasH = maxH;
                        canvasW = canvasH * ratio;
                      }

                      final size = Size(canvasW, canvasH);

                      dynamic selected;
                      if (_selectedId != null) {
                        try {
                          selected = _selectedType == 'text'
                              ? data.textElements.firstWhere((e) => e.id == _selectedId)
                              : data.imageElements.firstWhere((e) => e.id == _selectedId);
                        } catch (_) {
                          _selectedId = null;
                          _selectedType = null;
                        }
                      }

                      return Center(
                        child: SizedBox(
                          width: canvasW,
                          height: canvasH,
                          child: GestureDetector(
                            onTapDown: _pinMode
                                ? (d) => _showAddPinDialog(d.localPosition)
                                : null,
                            onTap: () {
                              if (!_pinMode) {
                                setState(() {
                                  _selectedId = null;
                                  _selectedType = null;
                                });
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              fit: StackFit.expand,
                              children: [
                                // Konten canvas di-clip agar objek tidak keluar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      _buildCanvasBackground(data, size),
                                      ...data.imageElements
                                          .where((e) => _selectedId != e.id)
                                          .map((e) => _buildElement(e, 'image', size)),
                                      ...data.textElements
                                          .where((e) => _selectedId != e.id)
                                          .map((e) => _buildElement(e, 'text', size)),
                                      if (selected != null) _buildElement(selected, _selectedType!, size),
                                      ...data.pins.map(_buildPin),
                                    ],
                                  ),
                                ),
                                // Handle di luar Clip agar bisa terlihat meski melewati tepi
                                if (selected != null) ..._buildHandles(selected, _selectedType!, size),
                                if (_pinMode) _buildPinOverlay(),
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
      ),
    );
  }

  Widget _buildFrameHeader(BriefDataModel data) {
    final aspect = data.panjang / data.lebar;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(bottom: BorderSide(color: Colors.blue.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.crop_square, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Canvas Frame', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                    Text('${data.panjang.toInt()} × ${data.lebar.toInt()} ${data.satuanUkuran}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue.shade600)),
                  ],
                ),
              ),
            ],
        ),
        const SizedBox(height: 8),
          _buildBannerShapeIndicator(aspect),
          // Preview Bentuk Banner dihapus agar tidak duplikasi dengan bagian ukuran/form
        ],
      ),
    );
  }

  Widget _buildBannerShapeIndicator(double aspect) {
    String text;
    IconData icon;
    Color color;
    if (aspect > 3) {
      text = 'Banner Panjang';
      icon = Icons.view_agenda;
      color = Colors.orange.shade600;
    } else if (aspect > 1.5) {
      text = 'Banner Landscape';
      icon = Icons.view_agenda_outlined;
      color = Colors.green.shade600;
    } else if (aspect > 0.8) {
      text = 'Banner Square';
      icon = Icons.crop_square;
      color = Colors.blue.shade600;
    } else if (aspect > 0.5) {
      text = 'Banner Portrait';
      icon = Icons.view_agenda_outlined;
      color = Colors.purple.shade600;
    } else {
      text = 'Banner Tinggi';
      icon = Icons.view_agenda;
      color = Colors.red.shade600;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
    );
  }

  // Preview mini dipindahkan ke bagian form ukuran banner, fungsi lama dinonaktifkan dari UI
  Widget _buildBannerPreview(BriefDataModel data) {
    final aspect = data.panjang / data.lebar;
    final w = 200.0;
    final h = (w / aspect).clamp(20.0, 100.0).toDouble();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Preview Bentuk Banner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              border: Border.all(color: Colors.blue.shade400, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${data.panjang.toInt()} × ${data.lebar.toInt()}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                const SizedBox(height: 2),
                Text('Aspect: ${aspect.toStringAsFixed(2)}:1', style: TextStyle(fontSize: 8, color: Colors.blue.shade600)),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildCanvasBackground(BriefDataModel data, Size size) {
    return Container(
      color: data.backgroundColor,
      child: CustomPaint(
        painter: _GridPainter(
          showGrid: _showGrid,
          showRulers: _showRulers,
          gridSize: _gridSize,
          maxX: data.panjang,
          maxY: data.lebar,
        ),
      ),
    );
  }

  Widget _buildElement(dynamic e, String type, [Size? canvasSize]) {
    return Positioned(
      left: e.position.dx,
      top: e.position.dy,
          child: GestureDetector(
        onTap: () => setState(() {
          _selectedId = e.id;
          _selectedType = type;
        }),
        onPanUpdate: _selectedId == e.id
            ? (d) {
                final model = context.read<BriefDataModel>();
                Offset next = e.position + d.delta;
                if (canvasSize != null) {
                  next = _clampPosition(e, next, canvasSize);
                }
                model.updateElementTransform(e.id, type, position: next);
              }
            : null,
        onPanEnd: _selectedId == e.id
            ? (_) => context.read<BriefDataModel>().onManipulationEnd()
            : null,
        child: Transform(
          transform: Matrix4.identity()
            ..translate(e.width / 2, e.height / 2)
            ..rotateZ(e.rotation)
            ..scale(e.scale)
            ..translate(-e.width / 2, -e.height / 2),
            child: Container(
              decoration: BoxDecoration(
              border: _selectedId == e.id
                  ? Border.all(color: Colors.blue.shade400, width: 2.0 / e.scale)
                    : null,
              borderRadius: BorderRadius.circular(4),
            ),
            child: type == 'text' ? _textWidget(e) : _imageWidget(e),
          ),
        ),
      ),
    );
  }

  Offset _clampPosition(dynamic e, Offset desired, Size canvasSize) {
    final double scaledW = (e.width as double) * (e.scale as double);
    final double scaledH = (e.height as double) * (e.scale as double);
    final double maxX = canvasSize.width - scaledW;
    final double maxY = canvasSize.height - scaledH;
    final double clampedX = maxX >= 0 ? desired.dx.clamp(0.0, maxX) as double : 0.0;
    final double clampedY = maxY >= 0 ? desired.dy.clamp(0.0, maxY) as double : 0.0;
    return Offset(clampedX, clampedY);
  }

  Widget _textWidget(TextElementData e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(e.content, style: TextStyle(fontSize: e.fontSize, color: e.color, fontWeight: FontWeight.w500)),
    );
  }

  Widget _imageWidget(ImageData e) {
    return Stack(children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(e.file, width: e.width, height: e.height, fit: BoxFit.contain),
        ),
      ),
      if (_selectedId == e.id)
        Positioned(
          top: -8,
          right: -8,
          child: GestureDetector(
            onTap: () => _confirmDeleteImage(e.id),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.red.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
    ]);
  }

  List<Widget> _buildHandles(dynamic e, String type, Size canvasSize) {
    final scaledW = e.width * e.scale;
    final scaledH = e.height * e.scale;
    final center = Offset(e.position.dx + scaledW / 2, e.position.dy + scaledH / 2);
    const size = 24.0;
    const half = size / 2;

    final List<Map<String, dynamic>> cfg = [
      {'pos': Offset(-scaledW / 2 - half, -scaledH / 2 - half), 'icon': Icons.rotate_90_degrees_ccw, 'color': Colors.orange, 'act': 'rot'},
      {'pos': Offset(scaledW / 2 - half, scaledH / 2 - half), 'icon': Icons.zoom_out_map, 'color': Colors.blue, 'act': 'scl'},
      // Handle move dihapus; drag langsung pada elemen terpilih
      if (type == 'text') {'pos': Offset(scaledW / 2 + half, 0), 'icon': Icons.color_lens, 'color': Colors.purple, 'act': 'clr'},
    ];

    return cfg.map((c) {
      final local = c['pos'] as Offset;
      final rp = Offset(
        center.dx + (local.dx * math.cos(e.rotation) - local.dy * math.sin(e.rotation)),
        center.dy + (local.dx * math.sin(e.rotation) + local.dy * math.cos(e.rotation)),
      );
      return Positioned(
        left: rp.dx - half,
        top: rp.dy - half,
        child: _handle(
          icon: c['icon'] as IconData,
          color: ((c['color']) is MaterialColor)
              ? (c['color'] as MaterialColor).shade400
              : (c['color'] as Color),
          onDrag: (d) => _manipulate(e, type, c['act'] as String, d, center),
          onTap: c['act'] == 'clr' ? () => _pickTextColor(e) : null,
        ),
      );
    }).toList();
  }

  Widget _handle({required IconData icon, required Color color, required Function(DragUpdateDetails) onDrag, VoidCallback? onTap}) {
    return Tooltip(
      message: 'Handle',
      child: GestureDetector(
        onPanUpdate: onDrag,
        onPanEnd: (_) => context.read<BriefDataModel>().onManipulationEnd(),
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2), boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
          ]),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
      ),
    );
  }

  void _manipulate(dynamic e, String type, String act, DragUpdateDetails d, Offset center) {
    final model = context.read<BriefDataModel>();
    switch (act) {
      case 'rot':
        final a0 = math.atan2((d.globalPosition - d.delta - center).dy, (d.globalPosition - d.delta - center).dx);
        final a1 = math.atan2((d.globalPosition - center).dy, (d.globalPosition - center).dx);
        model.updateElementTransform(e.id, type, rotation: e.rotation + (a1 - a0));
        break;
      case 'scl':
        final d0 = (d.globalPosition - d.delta - center).distance;
        final d1 = (d.globalPosition - center).distance;
        if (d0 > 0) {
          final ns = (e.scale * (d1 / d0)).clamp(0.1, 10.0);
          model.updateElementTransform(e.id, type, scale: ns);
        }
        break;
      case 'mov':
        model.updateElementTransform(e.id, type, position: e.position + d.delta);
        break;
    }
  }

  Widget _buildPin(PinMarkerData pin) {
    return Positioned(
      left: pin.position.dx - 16,
      top: pin.position.dy - 32,
      child: GestureDetector(
        onTap: () => _showPinDialog(pin),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16), boxShadow: [
            BoxShadow(color: Colors.red.shade400.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
          ]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.push_pin, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Flexible(
              child: Text(pin.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildPinOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.blue.shade50.withOpacity(0.25),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade600, borderRadius: BorderRadius.circular(10)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.push_pin, color: Colors.white),
              SizedBox(width: 8),
              Text('Tap canvas to add pin', style: TextStyle(color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(BriefDataModel data) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
      ]),
      child: Column(children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              _tabHeader('Canvas', 0, Icons.design_services),
              const SizedBox(width: 12),
              _tabHeader('Info', 2, Icons.info_outline),
            ]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildTabContent(data),
        ),
      ]),
    );
  }

  Widget _tabHeader(String title, int idx, IconData icon) {
    final sel = _tab == idx;
    return InkWell(
      onTap: () => setState(() => _tab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: sel ? Colors.blue.shade200 : Colors.grey.shade300),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: sel ? Colors.blue.shade600 : Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? Colors.blue.shade600 : Colors.grey.shade600)),
        ]),
      ),
    );
  }

  Widget _buildTabContent(BriefDataModel data) {
    switch (_tab) {
      case 0:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Canvas Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
          const SizedBox(height: 10),
          Wrap(spacing: 14, runSpacing: 14, children: [
            _setting('Background Color', GestureDetector(
              onTap: () => _pickBackground(),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: data.backgroundColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300))),
            )),
            _setting('Grid Size', Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(icon: const Icon(Icons.remove, size: 16), onPressed: () => setState(() => _gridSize = (_gridSize - 5).clamp(5, 100)), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)), child: Text('${_gridSize.toInt()}px', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
              IconButton(icon: const Icon(Icons.add, size: 16), onPressed: () => setState(() => _gridSize = (_gridSize + 5).clamp(5, 100)), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
            ])),
          ]),
          const SizedBox(height: 12),
          Text('Canvas Elements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 10, children: [
            _counter('Text', data.textElements.length, Colors.blue),
            _counter('Images', data.imageElements.length, Colors.green),
            _counter('Pins', data.pins.length, Colors.orange),
          ]),
        ]);
      case 2:
        final aspect = data.panjang / data.lebar;
        final area = data.panjang * data.lebar;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Canvas Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
          const SizedBox(height: 10),
          _infoRow('Dimensions', '${data.panjang.toInt()} × ${data.lebar.toInt()} ${data.satuanUkuran}'),
          _infoRow('Aspect Ratio', '${aspect.toStringAsFixed(2)}:1'),
          _infoRow('Total Elements', '${data.textElements.length + data.imageElements.length}'),
          _infoRow('Last Modified', DateTime.now().toString().substring(0, 16)),
          const SizedBox(height: 12),
          _analysis(data, aspect, area),
        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _counter(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
      ]),
    );
  }

  Widget _setting(String label, Widget control) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        control,
      ]),
    );
  }

  Widget _infoRow(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        Text(v, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _analysis(BriefDataModel data, double aspect, double area) {
    String t;
    String d;
    Color c;
    IconData i;
    if (aspect > 5) {
      t = 'Banner Ultra Panjang';
      d = 'Cocok untuk banner jalan raya atau spanduk besar';
      c = Colors.red.shade600;
      i = Icons.view_agenda;
    } else if (aspect > 3) {
      t = 'Banner Panjang';
      d = 'Ideal untuk banner toko atau event outdoor';
      c = Colors.orange.shade600;
      i = Icons.view_agenda_outlined;
    } else if (aspect > 1.5) {
      t = 'Banner Landscape';
      d = 'Bagus untuk banner display';
      c = Colors.green.shade600;
      i = Icons.view_agenda_outlined;
    } else if (aspect > 0.8) {
      t = 'Banner Square';
      d = 'Serbaguna untuk berbagai keperluan';
      c = Colors.blue.shade600;
      i = Icons.crop_square;
    } else if (aspect > 0.5) {
      t = 'Banner Portrait';
      d = 'Cocok untuk standing banner';
      c = Colors.purple.shade600;
      i = Icons.view_agenda_outlined;
    } else {
      t = 'Banner Ultra Tinggi';
      d = 'Ideal untuk banner gedung';
      c = Colors.red.shade600;
      i = Icons.view_agenda;
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: c.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: c.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(i, color: c, size: 20), const SizedBox(width: 8), Text('Analisis Banner', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c))]),
        const SizedBox(height: 8),
        Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
        const SizedBox(height: 4),
        Text(d, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 8, children: [
          _metric('Luas', '${area.toStringAsFixed(0)} ${data.satuanUkuran}²', Icons.area_chart),
          _metric('Perbandingan', '${aspect.toStringAsFixed(1)}:1', Icons.compare_arrows),
        ]),
      ]),
    );
  }

  Widget _metric(String l, String v, IconData i) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [
        Icon(i, size: 16, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        Text(l, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.center),
        Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildFrameFooter(BriefDataModel data) {
    final aspect = data.panjang / data.lebar;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          _infoCol('Ukuran Aktual', '${data.panjang.toInt()} × ${data.lebar.toInt()} ${data.satuanUkuran}'),
          _infoCol('Aspect Ratio', '${aspect.toStringAsFixed(2)}:1'),
          _infoCol('Luas', '${(data.panjang * data.lebar).toStringAsFixed(0)} ${data.satuanUkuran}²'),
        ]),
        // Template ukuran umum dihapus di sini; dipusatkan sebagai "Template cepat" pada form ukuran banner
      ]),
    );
  }

  Widget _infoCol(String l, String v) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
        const SizedBox(height: 2),
        Text(v, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
      ]),
    );
  }

  // Template ukuran umum dipindahkan ke "Template cepat" di form ukuran banner

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(Icons.lightbulb_outline, color: Colors.blue.shade600, size: 20), const SizedBox(width: 8), Text('Panduan Penggunaan', style: TextStyle(color: Colors.blue.shade700, fontSize: 14, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 8),
        Text('Use the colored handles to manipulate elements. Orange for rotation, blue for scaling, green for moving, and purple for text color.', style: TextStyle(color: Colors.blue.shade700, fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // Dialogs & helpers
  void _showPinDialog(PinMarkerData pin) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.push_pin, color: Colors.red.shade400), const SizedBox(width: 8), const Text('Pin Details')]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pin.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Text('Position: (${pin.position.dx.toInt()}, ${pin.position.dy.toInt()})', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ]),
              actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                TextButton(
                  onPressed: () {
                    context.read<BriefDataModel>().removePinMarker(pin.id);
                    Navigator.of(ctx).pop();
                  },
            child: Text('Delete', style: TextStyle(color: Colors.red.shade400)),
          ),
        ],
      ),
    );
  }

  void _showAddPinDialog(Offset pos) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.push_pin, color: Colors.blue.shade600), const SizedBox(width: 8), const Text('Add Pin Note')]),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter your note...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: Colors.grey.shade50),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<BriefDataModel>().addPinMarker(pos, controller.text);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
                ),
              ],
            ),
          );
    setState(() => _pinMode = false);
  }

  void _confirmDeleteImage(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.delete, color: Colors.red.shade400), const SizedBox(width: 8), const Text('Delete Image')]),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade400, foregroundColor: Colors.white),
            onPressed: () {
              context.read<BriefDataModel>().removeImage(id);
              Navigator.of(ctx).pop();
              setState(() {
                _selectedId = null;
                _selectedType = null;
              });
            },
            child: const Text('Delete'),
          )
        ],
      ),
    );
  }

  void _pickBackground() {
    final data = context.read<BriefDataModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.color_lens, color: Colors.blue.shade600), const SizedBox(width: 8), const Text('Choose Background Color')]),
        content: CustomColorPicker(
          initialColor: data.backgroundColor,
          onColorChanged: (c) => data.setBackgroundColor(c),
          onGradientChanged: (_) {},
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade600, foregroundColor: Colors.white), onPressed: () => Navigator.of(ctx).pop(), child: const Text('Apply')),
        ],
      ),
    );
  }

  void _pickTextColor(TextElementData e) {
    Color picked = e.color;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(children: [Icon(Icons.color_lens, color: Colors.purple.shade400), const SizedBox(width: 8), const Text('Choose Text Color')]),
        content: CustomColorPicker(initialColor: e.color, onColorChanged: (c) => picked = c, onGradientChanged: (_) {}),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade600, foregroundColor: Colors.white),
            onPressed: () {
              context.read<BriefDataModel>().updateElementTransform(e.id, 'text', color: picked);
              context.read<BriefDataModel>().onManipulationEnd();
              Navigator.of(ctx).pop();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final bool showGrid;
  final bool showRulers;
  final double gridSize;
  final double maxX;
  final double maxY;
  _GridPainter({required this.showGrid, required this.showRulers, required this.gridSize, required this.maxX, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGrid && !showRulers) return;
    final paint = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    if (showGrid) {
      for (double x = 0; x <= size.width; x += gridSize) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
      for (double y = 0; y <= size.height; y += gridSize) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }
    }
    if (showRulers) {
      final ruler = Paint()..color = Colors.grey.shade400..strokeWidth = 1;
      const int divisions = 10;
      for (int i = 0; i <= divisions; i++) {
        final double t = i / divisions;
        final double x = t * size.width;
        final double y = t * size.height;
        canvas.drawLine(Offset(x, 0), Offset(x, 15), ruler);
        canvas.drawLine(Offset(0, y), Offset(15, y), ruler);
        final String labelX = (t * maxX).toStringAsFixed(0);
        final String labelY = (t * maxY).toStringAsFixed(0);
        final tpX = TextPainter(
          text: TextSpan(text: labelX, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          textDirection: TextDirection.ltr,
        )..layout();
        final tpY = TextPainter(
          text: TextSpan(text: labelY, style: TextStyle(color: Colors.grey.shade600, fontSize: 10)),
          textDirection: TextDirection.ltr,
        )..layout();
        tpX.paint(canvas, Offset(x - tpX.width / 2, 2));
        tpY.paint(canvas, Offset(2, y - tpY.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
