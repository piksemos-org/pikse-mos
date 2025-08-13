import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenBoarding', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishBoarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Color(0xFF069494)),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: const [
                  BoardingSlide(
                    icon: Icons.layers_outlined,
                    title: 'Visualisasi Presisi dengan Blueprint',
                    subtitle:
                        'Unggah gambaran kasar Anda. Fitur Blueprint kami membantu desainer memahami visi Anda dengan akurat sebelum proses kreatif dimulai.',
                  ),
                  BoardingSlide(
                    icon: Icons.verified_outlined,
                    title: 'Kualitas Terjamin, Ukuran Akurat',
                    subtitle:
                        'Sistem cerdas kami akan menganalisis resolusi file Anda secara otomatis, memastikan hasil cetak setajam dan sepresisi yang diinginkan.',
                  ),
                  BoardingSlide(
                    icon: Icons.local_shipping_outlined,
                    title: 'Layanan Profesional Hingga ke Tangan Anda',
                    subtitle:
                        'Nikmati layanan antar langsung ke lokasi Anda dan garansi refund untuk kenyamanan maksimal. Fokus pada pekerjaan Anda, kami urus sisanya.',
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => buildDot(index, context)),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF069494),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  if (_currentPage < 2) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  } else {
                    _finishBoarding();
                  }
                },
                child: Text(
                  _currentPage < 2 ? 'Lanjut' : 'Jelajahi Piksel Mos',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 10,
      width: _currentPage == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index ? const Color(0xFF069494) : Colors.grey,
      ),
    );
  }
}

class BoardingSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const BoardingSlide({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: const Color(0xFF069494)),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
