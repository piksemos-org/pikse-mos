import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../widgets/custom_color_picker.dart';

// Kelas data untuk setiap elemen teks di kanvas.
class TextElementData {
  final String id;
  String content;
  Color color;
  double fontSize;
  Offset position;
  double scale;
  double rotation;
  double width;
  double height;

  TextElementData({
    required this.id,
    this.content = 'Teks Baru',
    this.color = Colors.black,
    this.fontSize = 24.0,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.width = 0.0,
    this.height = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'color': color.value,
    'fontSize': fontSize,
    'position_dx': position.dx,
    'position_dy': position.dy,
    'scale': scale,
    'rotation': rotation,
    'width': width,
    'height': height,
  };

  factory TextElementData.fromJson(Map<String, dynamic> json) => TextElementData(
    id: json['id'],
    content: json['content'],
    color: Color(json['color']),
    fontSize: json['fontSize'],
    position: Offset(json['position_dx'], json['position_dy']),
    scale: json['scale'],
    rotation: json['rotation'],
    width: json['width'] ?? 0.0,
    height: json['height'] ?? 0.0,
  );
}

// Kelas data untuk setiap elemen gambar di kanvas.
class ImageData {
  final String id;
  final String filePath;
  final String extension;
  final int sizeInBytes;
  Offset position;
  double scale;
  double rotation;
  double width;
  double height;

  ImageData({
    required this.id,
    required this.filePath,
    required this.extension,
    required this.sizeInBytes,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.width = 100.0,
    this.height = 100.0,
  });

  File get file => File(filePath);

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'extension': extension,
    'sizeInBytes': sizeInBytes,
    'position_dx': position.dx,
    'position_dy': position.dy,
    'scale': scale,
    'rotation': rotation,
    'width': width,
    'height': height,
  };

  factory ImageData.fromJson(Map<String, dynamic> json) => ImageData(
    id: json['id'],
    filePath: json['filePath'],
    extension: json['extension'],
    sizeInBytes: json['sizeInBytes'],
    position: Offset(json['position_dx'], json['position_dy']),
    scale: json['scale'],
    rotation: json['rotation'],
    width: json['width'] ?? 100.0,
    height: json['height'] ?? 100.0,
  );
}

// Kelas data untuk pin penanda.
class PinMarkerData {
  final String id;
  Offset position;
  String description;

  PinMarkerData({required this.id, required this.position, required this.description});

  Map<String, dynamic> toJson() => {
    'id': id,
    'position_dx': position.dx,
    'position_dy': position.dy,
    'description': description,
  };

  factory PinMarkerData.fromJson(Map<String, dynamic> json) => PinMarkerData(
    id: json['id'],
    position: Offset(json['position_dx'], json['position_dy']),
    description: json['description'],
  );
}

class BriefDataModel extends ChangeNotifier {
  // Data Ukuran
  double panjang = 100.0;
  double lebar = 100.0;
  String satuanUkuran = 'cm';

  // Data Finishing (Struktur Baru)
  Map<String, dynamic> finishingOptions = {
    'Lubang': {'selected': false, 'samping': '0', 'vertikal': '0'},
    'Slongsong': {'selected': false, 'samping': false, 'vertikal': false},
    'Lipat': {'selected': false, 'samping': false, 'vertikal': false},
    'Polos': {'selected': true},
    'Custom': {'selected': false, 'notes': ''},
  };

  // Data Elemen Kanvas
  List<TextElementData> textElements = [];
  List<ImageData> imageElements = [];

  // Data Warna
  Color backgroundColor = Colors.white;
  List<ColorGradientStop> backgroundGradient = [];

  // Data Pin
  List<PinMarkerData> pins = [];

  // Undo/Redo State
  final List<String> _history = [];
  int _historyIndex = -1;
  bool _isUndoingOrRedoing = false;

  BriefDataModel() {
    saveStateToHistory();
  }

  // --- Metode Histori (Undo/Redo) ---
  void saveStateToHistory() {
    if (_isUndoingOrRedoing) return;

    final state = jsonEncode({
      'texts': textElements.map((e) => e.toJson()).toList(),
      'images': imageElements.map((e) => e.toJson()).toList(),
      'pins': pins.map((e) => e.toJson()).toList(),
      'backgroundColor': backgroundColor.value,
      'finishing': finishingOptions,
    });

    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(state);
    _historyIndex++;
    notifyListeners();
  }

  void _loadStateFromString(String stateString) {
    final state = jsonDecode(stateString);
    textElements = (state['texts'] as List).map((e) => TextElementData.fromJson(e)).toList();
    imageElements = (state['images'] as List).map((e) => ImageData.fromJson(e)).toList();
    pins = (state['pins'] as List).map((e) => PinMarkerData.fromJson(e)).toList();
    backgroundColor = Color(state['backgroundColor']);
    finishingOptions = state['finishing'];
    notifyListeners();
  }

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  void undo() {
    if (canUndo) {
      _isUndoingOrRedoing = true;
      _historyIndex--;
      _loadStateFromString(_history[_historyIndex]);
      _isUndoingOrRedoing = false;
    }
  }

  void redo() {
    if (canRedo) {
      _isUndoingOrRedoing = true;
      _historyIndex++;
      _loadStateFromString(_history[_historyIndex]);
      _isUndoingOrRedoing = false;
    }
  }

  // --- Metode Update ---
  void _resetAllElements() {
    for (var element in textElements) {
      element.position = Offset.zero;
      element.scale = 1.0;
      element.rotation = 0.0;
    }
    for (var element in imageElements) {
      element.position = Offset.zero;
      element.scale = 1.0;
      element.rotation = 0.0;
    }
  }

  void updateUkuran({double? p, double? l}) {
    panjang = p ?? panjang;
    lebar = l ?? lebar;
    _resetAllElements();
    saveStateToHistory();
    notifyListeners();
  }

  void updateFinishingOption(String key, {bool? selected, String? subKey, dynamic subValue}) {
    if (selected != null) {
      finishingOptions[key]['selected'] = selected;
      // Jika memilih opsi lain, batalkan "Polos"
      if (key != 'Polos' && selected) {
        finishingOptions['Polos']['selected'] = false;
      }
    }
    if (subKey != null && subValue != null) {
      finishingOptions[key][subKey] = subValue;
    }
    saveStateToHistory();
    notifyListeners();
  }

  void addTextElement(Offset initialPosition) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final textElement = TextElementData(id: id, position: initialPosition);
    
    // Hitung dimensi teks berdasarkan konten dan font size
    final textSpan = TextSpan(
      text: textElement.content,
      style: TextStyle(fontSize: textElement.fontSize),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    textElement.width = textPainter.width;
    textElement.height = textPainter.height;
    
    textElements.add(textElement);
    saveStateToHistory();
    notifyListeners();
  }

  void addImage(File file, String extension, int size, Offset initialPosition, Size canvasSize) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    double initialScale = 1.0;
    if (canvasSize.width > 0) {
      initialScale = (canvasSize.width / 4) / 100;
    }
    
    // Gunakan ukuran default yang proporsional dengan canvas
    double imageWidth = 100.0;
    double imageHeight = 100.0;
    
    // Jika canvas cukup besar, buat gambar lebih proporsional
    if (canvasSize.width > 200 && canvasSize.height > 200) {
      imageWidth = canvasSize.width / 4;
      imageHeight = canvasSize.height / 4;
    }
    
    final newImage = ImageData(
        id: id,
        filePath: file.path,
        extension: extension,
        sizeInBytes: size,
        position: initialPosition,
        scale: initialScale.clamp(0.1, 2.0),
        width: imageWidth,
        height: imageHeight,
    );
    imageElements.add(newImage);
    saveStateToHistory();
    notifyListeners();
  }

  void removeImage(String id) {
    imageElements.removeWhere((element) => element.id == id);
    saveStateToHistory();
    notifyListeners();
  }

  void removeTextElement(String id) {
    textElements.removeWhere((element) => element.id == id);
    saveStateToHistory();
    notifyListeners();
  }

  void updateElementTransform(String id, String type, {Offset? position, double? scale, double? rotation, Color? color}) {
    try {
      if (type == 'text') {
        final element = textElements.firstWhere((e) => e.id == id);
        if (position != null) element.position = position;
        if (scale != null) element.scale = scale;
        if (rotation != null) element.rotation = rotation;
        if (color != null) element.color = color;
      } else {
        final element = imageElements.firstWhere((e) => e.id == id);
        if (position != null) element.position = position;
        if (scale != null) element.scale = scale;
        if (rotation != null) element.rotation = rotation;
      }
      notifyListeners();
    } catch (e) { /* Element not found */ }
  }

  void onManipulationEnd() {
    saveStateToHistory();
  }

  void addPinMarker(Offset position, String description) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    pins.add(PinMarkerData(id: id, position: position, description: description));
    saveStateToHistory();
    notifyListeners();
  }

  void removePinMarker(String id) {
    pins.removeWhere((pin) => pin.id == id);
    saveStateToHistory();
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    backgroundColor = color;
    backgroundGradient.clear();
    saveStateToHistory();
    notifyListeners();
  }

  void updateTextElementContent(String id, String content) {
    try {
      final element = textElements.firstWhere((el) => el.id == id);
      element.content = content;
      
      // Update dimensi teks berdasarkan konten baru
      final textSpan = TextSpan(
        text: element.content,
        style: TextStyle(fontSize: element.fontSize),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      element.width = textPainter.width;
      element.height = textPainter.height;
      
      saveStateToHistory();
      notifyListeners();
    } catch (e) { /* Element not found */ }
  }
}
