import 'package:dhukuti/providers/user_provider.dart';
import 'package:dhukuti/screens/admin/admin_dashboard.dart';
import 'package:dhukuti/screens/home/home_tab.dart';
import 'package:dhukuti/screens/portfolio/portfolio_tab.dart';
import 'package:dhukuti/screens/profile/profile_tab.dart';
import 'package:dhukuti/screens/trade/trade_tab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isAdmin = userProvider.isAdmin;

    final List<Widget> pages = [
      isAdmin ? const AdminDashboard() : const HomeTab(),
      const PortfolioTab(),
      const TradeTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin && _currentIndex == 0 ? "Admin Dashboard" :
          _currentIndex == 0 ? "Dashboard" : 
          _currentIndex == 1 ? "Portfolio" :
          _currentIndex == 2 ? "Trade" : "Profile"
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Portfolio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: "Trade",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
