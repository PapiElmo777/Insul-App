import 'package:flutter/material.dart';

class PantallaCuestionarioEnfermero extends StatelessWidget {
  const PantallaCuestionarioEnfermero({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Cuestionario Enfermero')), body: const Center(child: Text('Preguntas para Enfermeros'))); }
}

class PantallaCuestionarioPaciente extends StatelessWidget {
  const PantallaCuestionarioPaciente({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Cuestionario Paciente')), body: const Center(child: Text('Preguntas para Pacientes'))); }
}

class PantallaCuestionarioCuidador extends StatelessWidget {
  const PantallaCuestionarioCuidador({super.key});
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Cuestionario Cuidador')), body: const Center(child: Text('Preguntas para Cuidadores'))); }
}