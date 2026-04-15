import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import 'pantalla_login.dart';
import '../database/database_helper.dart';
import 'enfermeros/pantalla_inicio_enfermero.dart';
import 'paciente/pantalla_inicio_paciente.dart';

class PantallaCarga extends StatefulWidget {
  const PantallaCarga({super.key});

  @override
  State<PantallaCarga> createState() => _PantallaCargaState();
}

class _PantallaCargaState extends State<PantallaCarga> {
  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      final usuario = await db.obtenerUsuarioPorId(usuarioId);
      if (usuario != null && mounted) {
        final rol = usuario['rol'] as String;
        if (rol == 'Enfermero') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const PantallaInicioEnfermero()));
        } else if (rol == 'Paciente') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => PantallaInicioPaciente(nombrePaciente: usuario['nombre'])));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const PantallaLogin()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaLogin()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaLogin()));
    }
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
            SvgPicture.asset('assets/logo1.svg', width: 120,colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 44, color: Colors.white),
                children: [
                  TextSpan(text: 'Insul ', style: TextStyle(fontWeight: FontWeight.w400)),
                  TextSpan(text: 'App', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Monitoreo, cuidado y salud\nen tus manos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFE8E8E8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Color(0xFF00D1FF),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}