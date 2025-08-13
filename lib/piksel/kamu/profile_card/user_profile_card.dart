import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class UserProfileCard extends StatefulWidget {
  final String username;
  final String email;
  final String role;
  final String? avatarUrl;

  const UserProfileCard({
    required this.username,
    required this.email,
    required this.role,
    this.avatarUrl,
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
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade800, Colors.blue.shade400],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: InkWell(
                    onTap: _uploadAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.username,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.email,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                Chip(
                  label: Text(widget.role.toUpperCase()),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
