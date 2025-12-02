import 'package:flutter/material.dart';
import 'package:sparkd/core/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:sparkd/core/presentation/widgets/app_bottom_navigation_bar_item.dart';
import 'package:sparkd/features/sme/presentation/screens/tabs/discover_screen.dart';
import 'package:sparkd/features/sme/presentation/screens/tabs/home_screen.dart';
import 'package:sparkd/features/sme/presentation/screens/tabs/inbox_screen.dart';
import 'package:sparkd/features/sme/presentation/screens/tabs/order_screen.dart';
import 'package:sparkd/features/sme/presentation/screens/tabs/profile_screen.dart';

class SmeDashboard extends StatefulWidget {
  const SmeDashboard({super.key});

  @override
  State<SmeDashboard> createState() => _SmeDashboardState();
}

class _SmeDashboardState extends State<SmeDashboard> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<AppBottomNavigationBarItem> _items = [
    AppBottomNavigationBarItem(
      label: 'Home',
      iconPath: 'assets/icons/sme/home.svg',
      screen: const SmeHomeScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Orders',
      iconPath: 'assets/icons/sme/orders.svg',
      screen: const SmeOrdersScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Discover',
      iconPath: 'assets/icons/sme/compass.svg',
      screen: const SmeDiscoverScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Inbox',
      iconPath: 'assets/icons/sme/inbox.svg',
      screen: const SmeInboxScreen(),
    ),
    AppBottomNavigationBarItem(
      label: 'Profile',
      iconPath: 'assets/icons/sme/person.svg',
      screen: const SmeProfileScreen(),
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
