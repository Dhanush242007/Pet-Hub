import 'package:flutter/material.dart';

import '../screens/user/lost_found_screen.dart';
import '../screens/user/my_pets_screen.dart';
import '../screens/user/register_pet_screen.dart';

/// current: 0 = Home, 1 = My Pets, 2 = Add Pet, 3 = Lost & Found
class UserBottomNav extends StatelessWidget {
  final int current;
  final VoidCallback? onReturn;

  const UserBottomNav({super.key, required this.current, this.onReturn});

  Future<void> _go(BuildContext context, int i) async {
    if (i == current) return;
    final nav = Navigator.of(context);

    if (i == 0) {
      nav.popUntil((route) => route.isFirst);
      return;
    }

    final Widget screen = i == 1
        ? const MyPetsScreen()
        : i == 2
            ? const RegisterPetScreen()
            : const LostFoundScreen();

    if (i == 2 || current == 0) {
      await nav.push(MaterialPageRoute(builder: (_) => screen));
      onReturn?.call();
    } else {
      nav.pushReplacement(MaterialPageRoute(builder: (_) => screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: current,
      backgroundColor: Colors.white,
      onDestinationSelected: (i) => _go(context, i),
      destinations: const [
        NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home'),
        NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'My Pets'),
        NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Add Pet'),
        NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Lost & Found'),
      ],
    );
  }
}