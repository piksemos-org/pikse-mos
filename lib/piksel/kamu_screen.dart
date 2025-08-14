import 'package:flutter/material.dart';
import 'package:piksel_mos/main.dart';
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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw 'User not found';

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
          SnackBar(content: Text('Failed to load profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF069494),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  toolbarHeight: 45.0,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: const Text(''),
                ),
                SliverToBoxAdapter(
                  child: UserProfileCard(
                    userData: _userData ?? {},
                    onProfileUpdated: _fetchUserProfile,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const NavigationGrid(),
                      SettingsCard(
                        title: 'Profile Settings',
                        items: const [
                          {'icon': Icons.edit, 'title': 'Edit Profile'},
                          {'icon': Icons.security, 'title': 'Security'},
                        ],
                      ),
                      SettingsCard(
                        title: 'Support Area',
                        items: const [
                          {
                            'icon': Icons.description,
                            'title': 'Terms & Conditions',
                          },
                          {'icon': Icons.support_agent, 'title': 'Helpdesk'},
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
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
