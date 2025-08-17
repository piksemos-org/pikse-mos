import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../models/brief_data_model.dart';
import '../../../preview/design_preview_canvas.dart';

class BriefScreen extends StatelessWidget {
  const BriefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF069494),
        foregroundColor: Colors.white,
        title: Text(
          'Brief Desain Banner',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
      ),
      body: const _BriefForm(),
    );
  }
}

class _BriefForm extends StatefulWidget {
  const _BriefForm();

  @override
  State<_BriefForm> createState() => _BriefFormState();
}

class _BriefFormState extends State<_BriefForm> {
  final _formKey = GlobalKey<FormState>();
  late List<TextEditingController> _textControllers;
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _previewKey = GlobalKey();
  late final TextEditingController _sizeUnitController =
      TextEditingController();
  late BriefDataModel _briefModel;
  bool _lockAspect = false;
  double _lockedRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _textControllers = [];
    final briefData = context.read<BriefDataModel>();
    briefData.addListener(_syncControllers);
    _syncControllers();
  }

  void _syncControllers() {
    final briefData = context.read<BriefDataModel>();
    if (_textControllers.length != briefData.textElements.length) {
      for (var controller in _textControllers) {
        controller.dispose();
      }
      _textControllers = [];
      for (var element in briefData.textElements) {
        final controller = TextEditingController(text: element.content);
        controller.addListener(() {
          if (element.content != controller.text) {
            context.read<BriefDataModel>().updateTextElementContent(
              element.id,
              controller.text,
            );
          }
        });
        _textControllers.add(controller);
      }
      if (mounted) setState(() {});
    } else {
      for (var i = 0; i < briefData.textElements.length; i++) {
        if (_textControllers[i].text != briefData.textElements[i].content) {
          _textControllers[i].text = briefData.textElements[i].content;
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _briefModel = context.read<BriefDataModel>();
  }

  Future<void> _takeScreenshot() async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) return;

      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      final image = await boundary?.toImage();
      final byteData = await image?.toByteData(format: ImageByteFormat.png);
      final imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes != null) {
        await ImageGallerySaver.saveImage(imageBytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Screenshot saved to gallery')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving screenshot: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _sizeUnitController.dispose();
    _briefModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final briefData = context.watch<BriefDataModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              key: _previewKey,
              child: SizedBox(
                height: 450,
                child: DesignPreviewCanvas(key: _canvasKey),
              ),
            ),
            const SizedBox(height: 24),
            _formSectionCard(
              title: 'Ukuran Banner',
              child: _buildUkuranInput(briefData),
            ),
            _formSectionCard(
              title: 'Opsi Finishing',
              child: _buildFinishingOptions(briefData),
            ),
            _formSectionCard(
              title: 'Teks dalam Banner',
              child: _buildTextInputs(briefData),
            ),
            _formSectionCard(
              title: 'Unggah Gambar Pendukung',
              child: _buildImageUploader(briefData),
            ),
            // Background color picker dipindahkan ke Canvas Settings di dalam Blueprint Canvas,
            // sehingga bagian ini dihapus untuk menghindari duplikasi UI.
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                onPressed: () {},
                child: const Text('Create Desain'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formSectionCard({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF069494),
              ),
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildFinishingOptions(BriefDataModel briefData) {
    final isLubang = briefData.finishingOptions['Lubang']['selected'] as bool;
    final isSlongsong =
        briefData.finishingOptions['Slongsong']['selected'] as bool;
    final isLipat = briefData.finishingOptions['Lipat']['selected'] as bool;
    final isPolos = briefData.finishingOptions['Polos']['selected'] as bool;

    Widget chip(String label, bool selected, VoidCallback onTap) => FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.teal.shade50,
      checkmarkColor: Colors.teal,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih jenis finishing:',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(
              'Lubang (Mata Ayam)',
              isLubang,
              () => briefData.updateFinishingOption(
                'Lubang',
                selected: !isLubang,
              ),
            ),
            chip(
              'Slongsong',
              isSlongsong,
              () => briefData.updateFinishingOption(
                'Slongsong',
                selected: !isSlongsong,
              ),
            ),
            chip(
              'Lipat',
              isLipat,
              () =>
                  briefData.updateFinishingOption('Lipat', selected: !isLipat),
            ),
            FilterChip(
              label: const Text('Polos (Tanpa Finishing)'),
              selected: isPolos,
              onSelected: (_) {
                briefData.updateFinishingOption('Polos', selected: !isPolos);
                if (!isPolos) {
                  // Jika memilih Polos, nonaktifkan yang lain
                  briefData.updateFinishingOption('Lubang', selected: false);
                  briefData.updateFinishingOption('Slongsong', selected: false);
                  briefData.updateFinishingOption('Lipat', selected: false);
                  briefData.updateFinishingOption('Custom', selected: false);
                }
              },
              selectedColor: Colors.red.shade50,
              checkmarkColor: Colors.red,
            ),
          ],
        ),

        if (isLubang) ...[
          const SizedBox(height: 16),
          Text(
            'Detail Lubang (Mata Ayam)',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _numberStepper(
                label: 'Samping (buah)',
                value:
                    int.tryParse(
                      briefData.finishingOptions['Lubang']['samping'] ?? '0',
                    ) ??
                    0,
                onChanged: (v) => briefData.updateFinishingOption(
                  'Lubang',
                  subKey: 'samping',
                  subValue: v.toString(),
                ),
              ),
              _numberStepper(
                label: 'Atas/Bawah (buah)',
                value:
                    int.tryParse(
                      briefData.finishingOptions['Lubang']['vertikal'] ?? '0',
                    ) ??
                    0,
                onChanged: (v) => briefData.updateFinishingOption(
                  'Lubang',
                  subKey: 'vertikal',
                  subValue: v.toString(),
                ),
              ),
            ],
          ),
        ],

        if (isSlongsong) ...[
          const SizedBox(height: 16),
          Text(
            'Detail Slongsong',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('Samping (Kanan & Kiri)'),
                selected:
                    briefData.finishingOptions['Slongsong']['samping'] as bool,
                onSelected: (v) => briefData.updateFinishingOption(
                  'Slongsong',
                  subKey: 'samping',
                  subValue: v,
                ),
              ),
              FilterChip(
                label: const Text('Vertikal (Atas & Bawah)'),
                selected:
                    briefData.finishingOptions['Slongsong']['vertikal'] as bool,
                onSelected: (v) => briefData.updateFinishingOption(
                  'Slongsong',
                  subKey: 'vertikal',
                  subValue: v,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Metode build lainnya tetap sama
  Widget _buildUkuranInput(BriefDataModel briefData) {
    final aspect = briefData.panjang > 0 && briefData.lebar > 0
        ? (briefData.panjang / briefData.lebar)
        : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: briefData.panjang.toString(),
                decoration: const InputDecoration(
                  labelText: 'Lebar (Width)',
                  border: OutlineInputBorder(),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final pBaru = double.tryParse(value);
                  if (pBaru == null) return;
                  if (_lockAspect) {
                    briefData.updateUkuran(p: pBaru, l: (pBaru / _lockedRatio));
                  } else {
                    briefData.updateUkuran(p: pBaru);
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('×'),
            ),
            Expanded(
              child: TextFormField(
                initialValue: briefData.lebar.toString(),
                decoration: const InputDecoration(
                  labelText: 'Tinggi (Height)',
                  border: OutlineInputBorder(),
                  suffixText: 'cm',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final lBaru = double.tryParse(value);
                  if (lBaru == null) return;
                  if (_lockAspect) {
                    briefData.updateUkuran(p: (lBaru * _lockedRatio), l: lBaru);
                  } else {
                    briefData.updateUkuran(l: lBaru);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilterChip(
              label: Row(
                children: const [
                  Icon(Icons.lock, size: 16),
                  SizedBox(width: 6),
                  Text('Kunci Rasio'),
                ],
              ),
              selected: _lockAspect,
              onSelected: (v) {
                setState(() {
                  _lockAspect = v;
                  if (v) {
                    // width/height
                    _lockedRatio = (briefData.lebar == 0)
                        ? 1.0
                        : (briefData.panjang / briefData.lebar);
                  }
                });
              },
              selectedColor: Colors.teal.shade50,
              checkmarkColor: Colors.teal,
            ),
            const SizedBox(width: 12),
            Text(
              'Aspect (W:H): ${aspect.toStringAsFixed(2)}:1',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text('Template cepat:', style: TextStyle(color: Colors.grey.shade700)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _sizeChip(briefData, 100, 30),
            _sizeChip(briefData, 100, 100),
            _sizeChip(briefData, 60, 100),
            _sizeChip(briefData, 300, 50),
          ],
        ),
      ],
    );
  }

  Widget _sizeChip(BriefDataModel data, double p, double l) {
    final sel = data.panjang == p && data.lebar == l;
    return ChoiceChip(
      label: Text('${p.toStringAsFixed(0)}×${l.toStringAsFixed(0)} cm'),
      selected: sel,
      onSelected: (_) => data.updateUkuran(p: p, l: l),
      selectedColor: Colors.teal.shade50,
      side: BorderSide(color: sel ? Colors.teal : Colors.grey.shade300),
      labelStyle: TextStyle(
        color: sel ? Colors.teal.shade700 : Colors.grey.shade800,
      ),
    );
  }

  Widget _numberStepper({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onChanged(value > 0 ? value - 1 : 0),
          ),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputs(BriefDataModel briefData) {
    // Cek untuk memastikan controller sinkron
    if (_textControllers.length != briefData.textElements.length) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: briefData.textElements.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Teks baris ke-${index + 1}',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => briefData.removeTextElement(
                      briefData.textElements[index].id,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Tambah Teks'),
          onPressed: () {
            final canvasSize =
                _canvasKey.currentContext?.size ?? const Size(200, 200);
            briefData.addTextElement(
              Offset(canvasSize.width / 4, canvasSize.height / 4),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageUploader(BriefDataModel briefData) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text('Unggah Gambar/File'),
      onPressed: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile != null) {
          final file = File(pickedFile.path);
          final canvasSize =
              _canvasKey.currentContext?.size ?? const Size(200, 200);
          briefData.addImage(
            file,
            p.extension(file.path),
            await file.length(),
            Offset(canvasSize.width / 4, canvasSize.height / 4),
            canvasSize,
          );
        }
      },
    );
  }
}
