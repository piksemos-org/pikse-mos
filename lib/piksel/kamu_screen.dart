import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'kamu/profile_card/user_profile_card.dart';
import 'kamu/profile_navigation/navigation_grid.dart';
import 'kamu/widgets/settings_card.dart';

class KamuScreen extends StatefulWidget {
  const KamuScreen({super.key});

  @override
  State<KamuScreen> createState() => _KamuScreenState();
}

class _KamuScreenState extends State<KamuScreen> {
  Map<String, dynamic>? _userData;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      final response = await _supabase
          .from('users')
          .select('username, email, role, avatar_url')
          .eq('id', user!.id)
          .single();

      setState(() {
        _userData = response;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat profil: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF069494),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            title: const SizedBox.shrink(),
          ),
          SliverToBoxAdapter(
            child: UserProfileCard(
              username: _userData?['username'] ?? '',
              email: _userData?['email'] ?? '',
              role: _userData?['role'] ?? 'Pengguna',
              avatarUrl: _userData?['avatar_url'],
              onProfileUpdated: _fetchUserProfile,
            ),
          ),
          SliverToBoxAdapter(
            child: _userData == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const NavigationGrid(),
                      SettingsCard(
                        title: 'Pengaturan Profil',
                        items: [
                          {'icon': Icons.edit, 'title': 'Edit Profil'},
                          {'icon': Icons.security, 'title': 'Keamanan'},
                        ],
                      ),
                      SettingsCard(
                        title: 'Area Dukungan',
                        items: [
                          {
                            'icon': Icons.description,
                            'title': 'Syarat & Ketentuan',
                          },
                          {'icon': Icons.support_agent, 'title': 'Bantuan CS'},
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Keluar'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Colors.red.shade600,
                          ),
                          onPressed: () async {
                            await _supabase.auth.signOut();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}
