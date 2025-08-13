import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:piksel_mos/main.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  XFile? _mediaFile;
  bool _isLoading = false;
  VideoPlayerController? _videoController;

  Future<void> _pickMedia() async {
    final ImagePicker picker = ImagePicker();
    // Allow picking both image and video
    final XFile? pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      setState(() {
        _mediaFile = pickedFile;
        // If it's a video, initialize a controller to show a preview
        if (pickedFile.path.endsWith('.mp4') ||
            pickedFile.path.endsWith('.mov')) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.file(File(_mediaFile!.path))
            ..initialize().then((_) {
              setState(() {}); // Update UI when video is initialized
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

      // 1. Upload File to Storage
      await supabase.storage.from('media_posts').upload(filePath, file);

      // 2. Get Public URL
      final mediaUrl = supabase.storage
          .from('media_posts')
          .getPublicUrl(filePath);

      // 3. Determine Media Type
      final mediaType = (fileExt == 'mp4' || fileExt == 'mov')
          ? 'video'
          : 'image';

      // 4. Save Data to Table
      await supabase.from('posts').insert({
        'media_url': mediaUrl,
        'media_type': mediaType,
        'caption': _captionController.text.trim(),
        'user_id': supabase.auth.currentUser!.id,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload successful!'),
          backgroundColor: Colors.green,
        ),
      );
      // Return true to signal a refresh is needed
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
              // Media Preview Area
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

              // Select Media Button
              OutlinedButton.icon(
                icon: const Icon(Icons.perm_media_outlined),
                label: const Text('Select Media'),
                onPressed: _pickMedia,
              ),
              const SizedBox(height: 24),

              // Caption Text Field
              TextFormField(
                controller: _captionController,
                decoration: const InputDecoration(
                  labelText: 'Caption',
                  hintText: 'Write a caption...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Caption cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Upload Button
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
