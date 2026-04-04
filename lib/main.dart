import 'package:flutter/material.dart';
import 'pantallas/pantalla_carga.dart';

void main() {
  runApp(const Aplicacion());
}

class Aplicacion extends StatelessWidget {
  const Aplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Insul App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF074E9E)),
        useMaterial3: true,
      ),
      home: const PantallaCarga(),
    );
  }
}