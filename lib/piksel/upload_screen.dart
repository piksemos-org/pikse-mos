import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:piksel_mos/main.dart';

enum AspectRatioCategory { portrait, square, landscape }

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _titleController = TextEditingController();
  XFile? _mediaFile;
  bool _isLoading = false;
  VideoPlayerController? _videoController;
  AspectRatioCategory _selectedRatio = AspectRatioCategory.square;

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
        if (pickedFile.path.endsWith('.mp4') ||
            pickedFile.path.endsWith('.mov')) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(File(_mediaFile!.path))
            ..initialize().then((_) {
              setState(() {});
              _videoController?.play();
              _videoController?.setLooping(true);
            });
        } else {
          _videoController?.dispose();
          _videoController = null;
        }
      });
    }
  }

  double _getAspectRatioValue(AspectRatioCategory category) {
    switch (category) {
      case AspectRatioCategory.portrait:
        return 4 / 5;
      case AspectRatioCategory.square:
        return 1.0;
      case AspectRatioCategory.landscape:
        return 1.91 / 1;
    }
  }

  Future<void> _uploadPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a media file first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final file = File(_mediaFile!.path);
      final fileExt = _mediaFile!.path.split('.').last.toLowerCase();
      final fileName = 'post_${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'public/$fileName';

      await supabase.storage.from('media_posts').upload(filePath, file);

      final mediaUrl = supabase.storage
          .from('media_posts')
          .getPublicUrl(filePath);

      final mediaType = (fileExt == 'mp4' || fileExt == 'mov')
          ? 'video'
          : 'image';

      await supabase.from('posts').insert({
        'media_url': mediaUrl,
        'media_type': mediaType,
        'caption': _captionController.text.trim(),
        'title': _titleController.text.trim(),
        'media_aspect_ratio': _getAspectRatioValue(_selectedRatio),
        'user_id': supabase.auth.currentUser!.id,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _titleController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload New Content')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _mediaFile == null
                      ? const Center(child: Text('No media selected.'))
                      : (_videoController != null &&
                            _videoController!.value.isInitialized)
                      ? VideoPlayer(_videoController!)
                      : Image.file(File(_mediaFile!.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                icon: const Icon(Icons.perm_media_outlined),
                label: const Text('Select Media'),
                onPressed: _pickMedia,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a title for your post...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Write a caption...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<AspectRatioCategory>(
                value: _selectedRatio,
                decoration: const InputDecoration(
                  labelText: 'Aspect Ratio',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AspectRatioCategory.portrait,
                    child: Text('Portrait (4:5)'),
                  ),
                  DropdownMenuItem(
                    value: AspectRatioCategory.square,
                    child: Text('Square (1:1)'),
                  ),
                  DropdownMenuItem(
                    value: AspectRatioCategory.landscape,
                    child: Text('Landscape (1.91:1)'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRatio = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadPost,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text('Upload Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
