import 'package:flutter/material.dart';
import 'package:piksel_mos/main.dart'; // Pastikan import ValueNotifier ada
import 'package:piksel_mos/piksel/kamu/profile_card/user_profile_card.dart';
import 'package:piksel_mos/piksel/kamu/profile_navigation/navigation_grid.dart';
import 'package:piksel_mos/piksel/kamu/widgets/settings_card.dart';

class KamuScreen extends StatefulWidget {
  const KamuScreen({super.key});

  @override
  State<KamuScreen> createState() => _KamuScreenState();
}

class _KamuScreenState extends State<KamuScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    // Menampilkan loading indicator saat mengambil data
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      final response = await supabase
          .from('users')
          .select('username, email, role, avatar_url')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _userData = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // PERBAIKAN: Latar belakang utama diatur di sini
      backgroundColor: const Color(0xFF069494),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                // PERBAIKAN: Header transparan yang kosong dan menempel
                const SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: SizedBox.shrink(), // Judul dikosongkan
                ),

                // PERBAIKAN: Kartu profil diletakkan sebagai item pertama di scroll view
                SliverToBoxAdapter(
                  child: UserProfileCard(
                    // Mengirim seluruh data pengguna
                    userData: _userData ?? {},
                    // PERBAIKAN KRUSIAL: Mengirim fungsi refresh ke child widget
                    onProfileUpdated: _fetchUserProfile,
                  ),
                ),

                // Widget lainnya
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const NavigationGrid(),
                      SettingsCard(
                        title: 'Pengaturan Profil',
                        items: const [
                          {'icon': Icons.edit, 'title': 'Edit Profil'},
                          {'icon': Icons.security, 'title': 'Keamanan'},
                        ],
                      ),
                      SettingsCard(
                        title: 'Area Dukungan',
                        items: const [
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
                            await supabase.auth.signOut();
                            if (mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
