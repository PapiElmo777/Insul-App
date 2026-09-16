import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pantallas/pantalla_carga.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
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