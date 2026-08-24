import 'package:flutter/material.dart';
import 'package:tiptop_game_engine/core/theme/app_theme.dart';
import 'package:tiptop_game_engine/features/feed/presentation/pages/feed_screen.dart';
import 'package:tiptop_game_engine/features/mushroom_studio/presentation/pages/mushroom_studio_screen.dart';
import 'package:tiptop_game_engine/features/brain_ai/presentation/pages/brain_ai_screen.dart';
import 'package:tiptop_game_engine/features/chat_multiplayer/presentation/inbox_screen.dart';
import 'package:tiptop_game_engine/features/profile/presentation/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedScreen(),
    const Center(child: Text("👥 Приятели (Игри & Активност)", style: TextStyle(color: AppTheme.sciFiCyan, fontSize: 16))),
    const MushroomStudioScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      // Floating Brain Button (ПРЕМЕСТЕН ГОРЕ ВДЯСНО)
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 4.0),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: AppTheme.laserPink.withValues(alpha: 0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.laserPink, width: 1.5),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BrainAiScreen()),
            );
          },
          child: const Text("🧠", style: TextStyle(fontSize: 18)),
        ),
      ),
      
      body: _pages[_currentIndex],
      
      // Bottom TikTok Navigation Bar с лазерно розови Sci-Fi ефекти
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.laserPink.withValues(alpha: 0.3), width: 1)),
          color: Colors.black,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppTheme.laserPink,
          unselectedItemColor: Colors.grey,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              activeIcon: Icon(Icons.home_filled, color: AppTheme.laserPink),
              label: 'Начало',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_outlined),
              activeIcon: Icon(Icons.people_alt, color: AppTheme.sciFiCyan),
              label: 'Приятели',
            ),
            
            // 🍄 Лазерно светещ бутон за създаване
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.laserPink, AppTheme.neonPurple],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.laserPink.withValues(alpha: 0.7),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text("🍄", style: TextStyle(fontSize: 18)),
              ),
              label: 'Създай',
            ),
            
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble, color: AppTheme.laserPink),
              label: 'Входящи',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppTheme.sciFiCyan),
              label: 'Профил',
            ),
          ],
        ),
      ),
    );
  }
}
