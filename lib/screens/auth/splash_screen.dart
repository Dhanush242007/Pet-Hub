import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/pethub_logo.dart';
import 'login_screen.dart';
import 'role_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    if (AuthService().isLoggedIn) {
      await goToDashboard(context);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF7A59), Color(0xFFFFB05C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 24,
                      offset: Offset(0, 10))
                ],
              ),
              child: const PetHubLogo(size: 140),
            ),
            const SizedBox(height: 24),
            const Text('PetHub',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1)),
            const SizedBox(height: 6),
            const Text('Smart Pet Registration & Care',
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 36),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}