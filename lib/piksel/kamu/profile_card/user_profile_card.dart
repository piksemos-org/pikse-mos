import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UserProfileCard extends StatefulWidget {
  final String username;
  final String email;
  final String role;
  final String? avatarUrl;
  final Function() onProfileUpdated;

  const UserProfileCard({
    required this.username,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.onProfileUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _UserProfileCardState createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late String? _avatarUrl = widget.avatarUrl;

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    try {
      final user = _supabase.auth.currentUser;
      final filePath =
          'avatars/${user!.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage
          .from('avatars')
          .upload(filePath, File(image.path));

      final newAvatarUrl = _supabase.storage
          .from('avatars')
          .getPublicUrl(filePath);

      await _supabase
          .from('users')
          .update({'avatar_url': newAvatarUrl})
          .eq('id', user.id);

      setState(() => _avatarUrl = newAvatarUrl);
      widget.onProfileUpdated();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: InkWell(
        onTap: _uploadAvatar,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Layer 1: Background Image
                if (_avatarUrl != null)
                  Image.network(
                    _avatarUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey,
                    child: const Center(
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  ),

                // Layer 2: Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),

                // Text Content
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Glassmorphism Role Badge
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          color: Colors.black.withOpacity(0.2),
                        ),
                        child: Text(
                          widget.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
