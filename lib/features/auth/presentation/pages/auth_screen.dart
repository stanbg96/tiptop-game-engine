import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/feed/presentation/pages/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _navigateToHome(String username) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10121D),
        content: Text('🎉 Добре дошъл в TipTop, $username!', style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
    );
  }

  // 1. PHONE / EMAIL AUTH MODAL (1:1 with TikTok)
  void _showPhoneEmailAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF10121D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppTheme.laserPink, width: 1),
      ),
      builder: (context) => DefaultTabController(
        length: 2,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 14),
              Text(
                _isLogin ? 'Вход с Телефон или Имейл' : 'Регистрация с Телефон или Имейл',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const TabBar(
                indicatorColor: AppTheme.laserPink,
                indicatorWeight: 2.5,
                labelColor: AppTheme.laserPink,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(icon: Icon(Icons.phone_android, size: 18), text: 'Телефон'),
                  Tab(icon: Icon(Icons.email_outlined, size: 18), text: 'Имейл / Username'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: TabBarView(
                  children: [
                    _buildPhoneAuthTab(),
                    _buildEmailAuthTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneAuthTab() {
    final phoneController = TextEditingController();
    final codeController = TextEditingController();
    bool codeSent = false;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                  child: const Center(child: Text('🇧🇬 +359', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(hintText: '888 123 456', hintStyle: TextStyle(color: Colors.grey, fontSize: 13), border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (codeSent) ...[
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.sciFiCyan)),
                child: TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Въведи 6-цифрен SMS код (123456)', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 12),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.neonPurple]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    if (!codeSent) {
                      if (phoneController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Моля въведете телефонен номер!')));
                        return;
                      }
                      setModalState(() => codeSent = true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📩 SMS кодът е изпратен успешно: 123456')));
                    } else {
                      Navigator.pop(context);
                      _navigateToHome('User_${phoneController.text.trim().substring(0, 3)}');
                    }
                  },
                  child: Text(codeSent ? 'ПОТВЪРДИ И ВЛЕЗ' : 'ИЗПРАТИ SMS КОД', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailAuthTab() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
              child: TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(hintText: 'Имейл или @потребителско име', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none, icon: Icon(Icons.person, size: 16, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFF181B28), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
              child: TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Парола',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  border: InputBorder.none,
                  icon: const Icon(Icons.lock, size: 16, color: Colors.grey),
                  suffixIcon: GestureDetector(
                    onTap: () => setModalState(() => obscurePassword = !obscurePassword),
                    child: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, size: 16, color: AppTheme.sciFiCyan),
                  ),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFAA00FF)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    String input = emailController.text.trim();
                    if (input.isEmpty || passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Моля попълнете всички полета!')));
                      return;
                    }
                    Navigator.pop(context);
                    _navigateToHome(input.contains('@') ? input.split('@')[0] : input);
                  },
                  child: Text(_isLogin ? 'ВХОД' : 'РЕГИСТРАЦИЯ', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. GOOGLE AUTH MODAL (One-Tap Google Play Games Sign-In)
  void _showGoogleAuthModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF00E676), width: 1),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: const Center(child: Text('G', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 20))),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Вход с Google профил', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Избери акаунт за TipTop Game Engine', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Google Account Tile 1
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _navigateToHome('stanbg96');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF181B2C), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: Color(0xFF00E676), child: Text('S', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('stanbg96', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('stanbg96@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.check_circle, color: Color(0xFF00E676), size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Google Account Tile 2
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _navigateToHome('Gamer_Creator');
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF181B2C), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: AppTheme.sciFiCyan, child: Text('G', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gamer_Creator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('gamer.creator@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.add, color: AppTheme.sciFiCyan, size: 16),
                label: const Text('Добави друг Google акаунт', style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 12)),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. DISCORD / GAMING ID AUTH MODAL
  void _showDiscordAuthModal() {
    final tagController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121422),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Color(0xFF5865F2), width: 1.5),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, left: 20, right: 20, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF5865F2)),
                  child: const Icon(Icons.sports_esports, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discord & Gaming ID Вход', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Свържи твоя геймърски таг директно', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFF181B2C), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white12)),
              child: TextField(
                controller: tagController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Въведи Discord Tag (напр. Neo#1337)', hintStyle: TextStyle(color: Colors.grey, fontSize: 12), border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5865F2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  String tag = tagController.text.trim();
                  if (tag.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Моля въведете Gaming ID или Discord Tag!')));
                    return;
                  }
                  Navigator.pop(context);
                  _navigateToHome(tag.replaceAll('#', '_'));
                },
                child: const Text('СВЪРЖИ И ВЛЕЗ С DISCORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
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
              // Skip / Guest Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateToHome('Гост_Създател'),
                  child: const Text(
                    'Skip / Guest >',
                    style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Center Logo & Title
              Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(colors: [AppTheme.laserPink, AppTheme.sciFiCyan]),
                      boxShadow: [
                        BoxShadow(color: AppTheme.laserPink.withValues(alpha: 0.5), blurRadius: 25, spreadRadius: 2),
                      ],
                    ),
                    child: const Icon(Icons.gamepad, size: 48, color: Colors.black),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isLogin ? 'Log in to Game Engine' : 'Sign up for Game Engine',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Create 3D games with AI, share & play with friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 28),

                  // 1. Phone / Email / Username Button
                  _buildAuthButton(
                    icon: Icons.person_outline,
                    text: 'Use Phone / Email / Username',
                    glowColor: AppTheme.laserPink,
                    onTap: _showPhoneEmailAuthModal,
                  ),
                  const SizedBox(height: 12),

                  // 2. Google Button
                  _buildAuthButton(
                    icon: Icons.g_mobiledata,
                    text: 'Continue with Google',
                    glowColor: const Color(0xFF00E676),
                    onTap: _showGoogleAuthModal,
                  ),
                  const SizedBox(height: 12),

                  // 3. Discord / Gaming ID Button
                  _buildAuthButton(
                    icon: Icons.sports_esports_outlined,
                    text: 'Continue with Discord / Gaming ID',
                    glowColor: const Color(0xFF5865F2),
                    onTap: _showDiscordAuthModal,
                  ),
                ],
              ),

              // Bottom Switcher
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
                        style: const TextStyle(color: AppTheme.laserPink, fontWeight: FontWeight.bold, fontSize: 13),
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

  Widget _buildAuthButton({
    required IconData icon,
    required String text,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF141624),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: glowColor.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(color: glowColor.withValues(alpha: 0.1), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: glowColor, size: 22),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 22),
          ],
        ),
      ),
    );
  }
}
