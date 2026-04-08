import 'package:flutter/material.dart';
import 'dart:async';
import 'pantalla_login.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> with TickerProviderStateMixin {
  late AnimationController _controladorLatido;
  late Animation<double> _animacionEscala;
  late AnimationController _controladorOpacidad;
  late Animation<double> _animacionOpacidad;

  @override
  void initState() {
    super.initState();

    _controladorLatido = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animacionEscala = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controladorLatido, curve: Curves.easeInOut),
    );

    _controladorOpacidad = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _animacionOpacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorOpacidad, curve: Curves.easeIn),
    );

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaLogin()),
      );
    });
  }

  @override
  void dispose() {
    _controladorLatido.dispose();
    _controladorOpacidad.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF074E9E),
              Color(0xFF256CC8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animacionEscala,
              child: Image.asset('assets/logo.png', width: 120),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _animacionOpacidad,
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontSize: 44, color: Colors.white),
                      children: [
                        TextSpan(text: 'Insul ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'App', style: TextStyle(fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Monitoreo, cuidado y salud\nen tus manos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE8E8E8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}