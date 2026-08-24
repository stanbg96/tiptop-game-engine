import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/features/feed/presentation/pages/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _navigateToHome,
                  child: const Text(
                    'Skip / Guest >',
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.purpleAccent, Colors.cyanAccent],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.gamepad, size: 44, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isLogin ? 'Log in to Game Engine' : 'Sign up for Game Engine',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create 3D games with AI, share & play with friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),
                  _buildAuthButton(
                    icon: Icons.person_outline,
                    text: 'Use Phone / Email / Username',
                    onTap: _navigateToHome,
                  ),
                  const SizedBox(height: 12),
                  _buildAuthButton(
                    icon: Icons.g_mobiledata,
                    text: 'Continue with Google',
                    onTap: _navigateToHome,
                  ),
                  const SizedBox(height: 12),
                  _buildAuthButton(
                    icon: Icons.sports_esports_outlined,
                    text: 'Continue with Discord / Gaming ID',
                    onTap: _navigateToHome,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? "Don't have an account? " : "Already have an account? ",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? 'Sign up' : 'Log in',
                        style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF161622),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}
