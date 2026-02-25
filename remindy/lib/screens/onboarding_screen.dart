import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardData {
  final String title;
  final String subtitle;

  const OnboardData({required this.title, required this.subtitle});
}

final List<OnboardData> pages = const [
  const OnboardData(
    title: 'Remindy',
    subtitle: 'Never forget a deadline again',
  ),
  const OnboardData(
    title: 'Stay Organized',
    subtitle: 'Track everything easily',
  ),
  const OnboardData(
    title: 'Achieve More',
    subtitle: 'Focus on what matters most',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  void _goNext() {
    if (_current < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Widget _buildDot(int index) {
    bool isActive = _current == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 18 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF4A90E2)
            : const Color(0xFF4A90E2).withAlpha(80),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomHeight = screenHeight * 0.13; // 13%
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD6EEDF), Color(0xFFC8E6E6), Color(0xFFBFD8F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _current = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Use asset image instead of icon, fallback to icon if missing
                          Image.asset(
                            'assets/brain.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.psychology,
                              size: 120,
                              color: Color(0xFF2F3A4A),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            page.title,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F3A4A),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              page.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF5F6C7B),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // WHITE BAR
                Container(
                  height: bottomHeight,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildDot(index),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 170,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _goNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _current == pages.length - 1 ? 'Start' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // SKIP BUTTON (top-left, themed, not flush to corner)
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, left: 18),
                  child: TextButton(
                    onPressed: _goHome,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                        255,
                        0,
                        66,
                        189,
                      ).withAlpha((0.95 * 255).toInt()),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
