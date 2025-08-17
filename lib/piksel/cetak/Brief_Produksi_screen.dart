import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';

class BriefProduksiScreen extends StatefulWidget {
  final Map<String, dynamic> variant;
  const BriefProduksiScreen({super.key, required this.variant});

  @override
  State<BriefProduksiScreen> createState() => _BriefProduksiScreenState();
}

class _BriefProduksiScreenState extends State<BriefProduksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _panjangController = TextEditingController();
  final TextEditingController _lebarController = TextEditingController();
  String _satuan = 'CM';
  PlatformFile? _selectedFile;
  String? _finishing;
  final TextEditingController _customFinishingController =
      TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedFile = result.files.first;
      });

      final extension = _selectedFile?.extension?.toLowerCase();

      if (extension == 'jpg' || extension == 'png') {
        // Tampilkan informasi untuk format gambar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'File gambar terdeteksi. Sistem akan melakukan pengecekan otomatis ukuran, resolusi, dan warna.',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        // Tampilkan dialog peringatan untuk format lain
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Peringatan'),
            content: const Text(
              'Semua kesalahan file (salah ukuran, resolusi, warna, dll) adalah tanggung jawab pemberi file.',
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brief Produksi'),
        backgroundColor: const Color(0xFF069494),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informasi Bahan
              Text(
                'Bahan: ${widget.variant['name']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF069494),
                ),
              ),
              const SizedBox(height: 24),

              // Input Ukuran
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _panjangController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Panjang',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan panjang';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lebarController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Lebar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan lebar';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  DropdownButton<String>(
                    value: _satuan,
                    items: const [
                      DropdownMenuItem(value: 'CM', child: Text('CM')),
                      DropdownMenuItem(value: 'M', child: Text('M')),
                      DropdownMenuItem(value: 'MM', child: Text('MM')),
                    ],
                    onChanged: (value) => setState(() => _satuan = value!),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Upload File
              ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: Text(_selectedFile?.name ?? 'Pilih File Desain'),
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF069494),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedFile != null)
                Text(
                  'File terpilih: ${_selectedFile!.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              const SizedBox(height: 24),

              // Finishing
              DropdownButtonFormField<String>(
                value: _finishing,
                decoration: const InputDecoration(
                  labelText: 'Finishing',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Lubang', child: Text('Lubang')),
                  DropdownMenuItem(
                    value: 'Slongsong',
                    child: Text('Slongsong'),
                  ),
                  DropdownMenuItem(value: 'Lipat', child: Text('Lipat')),
                  DropdownMenuItem(value: 'Polos', child: Text('Polos')),
                  DropdownMenuItem(value: 'Kustom', child: Text('Kustom')),
                ],
                onChanged: (value) => setState(() => _finishing = value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap pilih finishing';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_finishing == 'Kustom')
                TextFormField(
                  controller: _customFinishingController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi Finishing Kustom',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_finishing == 'Kustom' &&
                        (value == null || value.isEmpty)) {
                      return 'Harap isi deskripsi finishing kustom';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 24),

              // Deskripsi
              TextFormField(
                controller: _deskripsiController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Tambahan',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Lanjutkan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedFile != null) {
                      // Navigasi ke halaman pembayaran
                      Navigator.pushNamed(context, '/payment');
                    } else if (_selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Harap pilih file desain terlebih dahulu',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF069494),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Lanjutkan ke Pembayaran'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
