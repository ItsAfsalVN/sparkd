import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:sparkd/core/presentation/widgets/app_bottom_navigation_bar_item.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/earning_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/gigs_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/home_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/orders_screen.dart';
import 'package:sparkd/features/spark/presentation/screens/tabs/profile_screen.dart';

class SparkDashboardScreen extends StatefulWidget {
  const SparkDashboardScreen({super.key});

  @override
  State<SparkDashboardScreen> createState() => _SparkDashboardScreenState();
}

class _SparkDashboardScreenState extends State<SparkDashboardScreen> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<AppBottomNavigationBarItem> _items = [
    AppBottomNavigationBarItem(
      label: 'Home',
      iconPath: 'assets/icons/spark/home.svg',
      screen: const HomeScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Orders',
      iconPath: 'assets/icons/spark/orders.svg',
      screen: const OrdersScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Gigs',
      iconPath: 'assets/icons/spark/megaphone.svg',
      screen: const GigsScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Earnings',
      iconPath: 'assets/icons/spark/wallet.svg',
      screen: const EarningScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Profile',
      iconPath: 'assets/icons/spark/person.svg',
      screen: const ProfileScreen(),
    ),
  ];

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = _items.map((item) => item.screen).toList();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
      ),

      bottomNavigationBar: AppBottomNavigationBar(
        items: _items,
        onItemTapped: _onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
