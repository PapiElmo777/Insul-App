import 'package:flutter/material.dart';
import 'pantalla_registro.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> with SingleTickerProviderStateMixin {
  late AnimationController _controladorPrincipal;
  late Animation<double> _animacionOpacidadHeader;
  late Animation<Offset> _animacionSlideCampos;
  late Animation<Offset> _animacionSlideBoton;
  late Animation<Offset> _animacionSlideFooter;

  @override
  void initState() {
    super.initState();

    _controladorPrincipal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animacionOpacidadHeader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _animacionSlideCampos = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );

    _animacionSlideBoton = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic)),
    );

    _animacionSlideFooter = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic)),
    );

    _controladorPrincipal.forward();
  }

  @override
  void dispose() {
    _controladorPrincipal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _animacionOpacidadHeader,
                  child: Column(
                    children: [
                      Image.asset('assets/logo.png', width: 100),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(fontSize: 40, color: Colors.white),
                          children: [
                            TextSpan(text: 'Insul ', style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'App', style: TextStyle(fontWeight: FontWeight.w400)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Inicia sesión en tu cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                SlideTransition(
                  position: _animacionSlideCampos,
                  child: Column(
                    children: [
                      _crearCampoTexto(hint: 'Correo Electrónico', ocultaTexto: false, icono: Icons.email_outlined),
                      const SizedBox(height: 20),
                      _crearCampoTexto(hint: 'Contraseña', ocultaTexto: true, icono: Icons.lock_outline),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SlideTransition(
                  position: _animacionSlideBoton,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF008CCF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                SlideTransition(
                  position: _animacionSlideFooter,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {},
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PantallaRegistro()),
                          );
                        },
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: '¿No tienes Cuenta? ', style: TextStyle(color: Colors.white)),
                              TextSpan(text: 'Regístrate', style: TextStyle(color: Color(0xFF00D1FF))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _crearCampoTexto({required String hint, required bool ocultaTexto, required IconData icono}) {
    return TextField(
      obscureText: ocultaTexto,
      decoration: InputDecoration(
        prefixIcon: Icon(icono, color: const Color(0xFF1C63BB)),
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF848282),
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
        ),
      ),
    );
  }
}