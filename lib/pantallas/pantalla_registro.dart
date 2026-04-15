import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pantallas_cuestionarios.dart';
import '../database/database_helper.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> with SingleTickerProviderStateMixin {
  String ladaSeleccionada = '+52';
  String? rolSeleccionado;
  bool _cargando = false;
  String? _error;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _apellidosCtrl = TextEditingController();
  final TextEditingController _correoCtrl = TextEditingController();
  final TextEditingController _contrasenaCtrl = TextEditingController();
  final TextEditingController _telefonoCtrl = TextEditingController();

  final List<Map<String, String>> paises = [
    {'bandera': '🇲🇽', 'lada': '+52'},
    {'bandera': '🇺🇸', 'lada': '+1'},
    {'bandera': '🇨🇴', 'lada': '+57'},
    {'bandera': '🇦🇷', 'lada': '+54'},
  ];

  final List<String> roles = ['Enfermero', 'Paciente', 'Cuidador'];

  late AnimationController _controladorPrincipal;
  late Animation<double> _animacionOpacidadHeader;
  late Animation<Offset> _animacionSlideCampos1;
  late Animation<Offset> _animacionSlideCampos2;
  late Animation<Offset> _animacionSlideFooter;

  @override
  void initState() {
    super.initState();

    _controladorPrincipal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // FadeIn del Header
    _animacionOpacidadHeader = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );

    _animacionSlideCampos1 = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic)),
    );

    _animacionSlideCampos2 = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic)),
    );

    _animacionSlideFooter = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic)),
    );

    _controladorPrincipal.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _correoCtrl.dispose();
    _contrasenaCtrl.dispose();
    _telefonoCtrl.dispose();
    _controladorPrincipal.dispose();
    super.dispose();
  }

  Future<void> _continuar() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _apellidosCtrl.text.trim().isEmpty ||
        _correoCtrl.text.trim().isEmpty ||
        _contrasenaCtrl.text.isEmpty ||
        _telefonoCtrl.text.trim().isEmpty ||
        rolSeleccionado == null) {
      setState(() => _error = 'Por favor completa todos los campos.');
      return;
    }

    setState(() { _cargando = true; _error = null; });

    final db = DatabaseHelper();

    final usuarioExistente = await db.obtenerUsuarioPorCorreo(_correoCtrl.text.trim().toLowerCase());
    if (usuarioExistente != null) {
      setState(() {
        _cargando = false;
        _error = 'Este correo ya está registrado.';
      });
      return;
    }

    final datosUsuario = {
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correo': _correoCtrl.text.trim().toLowerCase(),
      'contrasena': _contrasenaCtrl.text,
      'telefono': _telefonoCtrl.text.trim(),
      'lada': ladaSeleccionada,
      'rol': rolSeleccionado,
    };

    final usuarioId = await db.insertarUsuario(datosUsuario);
    await db.guardarSesion(usuarioId);

    if (!mounted) return;

    if (rolSeleccionado == 'Enfermero') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaCuestionarioEnfermero()));
    } else if (rolSeleccionado == 'Paciente') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaCuestionarioPaciente()));
    } else if (rolSeleccionado == 'Cuidador') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PantallaCuestionarioCuidador()));
    } else {
      setState(() {
        _cargando = false;
        _error = 'Rol en desarrollo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              FadeTransition(
                opacity: _animacionOpacidadHeader,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          SvgPicture.asset('assets/logo1.svg', width: 80,colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                          const SizedBox(height: 10),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(fontSize: 32, color: Colors.white),
                              children: [
                                TextSpan(text: 'Insul ', style: TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: 'App', style: TextStyle(fontWeight: FontWeight.w400)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Registro de Cuenta',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 15),
                      Text(_error!, style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SlideTransition(
                position: _animacionSlideCampos1,
                child: Column(
                  children: [
                    _crearCampoTexto(titulo: 'Nombre completo', hint: 'Ej. Juan Pablo', icono: Icons.person_outline, controlador: _nombreCtrl),
                    const SizedBox(height: 15),
                    _crearCampoTexto(titulo: 'Apellidos', hint: 'Ej. Jiménez', icono: Icons.person_outline, controlador: _apellidosCtrl),
                    const SizedBox(height: 15),
                    _crearCampoTexto(titulo: 'Correo electrónico', hint: 'ejemplo@correo.com', icono: Icons.email_outlined, controlador: _correoCtrl),
                    const SizedBox(height: 15),
                    _crearCampoTexto(titulo: 'Contraseña', hint: 'Contraseña', ocultaTexto: true, icono: Icons.lock_outline, controlador: _contrasenaCtrl),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              SlideTransition(
                position: _animacionSlideCampos2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teléfono',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: ladaSeleccionada,
                                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                onChanged: (String? nuevoValor) {
                                  setState(() {
                                    ladaSeleccionada = nuevoValor!;
                                  });
                                },
                                items: paises.map<DropdownMenuItem<String>>((Map<String, String> pais) {
                                  return DropdownMenuItem<String>(
                                    value: pais['lada'],
                                    child: Text('${pais['bandera']} ${pais['lada']}', style: const TextStyle(fontSize: 16)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const VerticalDivider(width: 1, thickness: 2, color: Color(0xFFD2D2D2)),
                          Expanded(
                            child: TextField(
                              controller: _telefonoCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                                hintText: '10 dígitos',
                                hintStyle: TextStyle(color: Color(0xFF848282)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        const Text(
                          'Soy un',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: rolSeleccionado,
                                hint: const Text('Selecciona tu rol', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                onChanged: (String? nuevoValor) {
                                  setState(() {
                                    rolSeleccionado = nuevoValor;
                                  });
                                },
                                items: roles.map<DropdownMenuItem<String>>((String valor) {
                                  return DropdownMenuItem<String>(
                                    value: valor,
                                    child: Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SlideTransition(
                position: _animacionSlideFooter,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _cargando ? null : _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF008CCF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5)),
                          elevation: 5,
                        ),
                        child: _cargando
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Continuar con el registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(text: '¿Ya tienes Cuenta? ', style: TextStyle(color: Colors.white)),
                              TextSpan(text: 'Inicia Sesión', style: TextStyle(color: Color(0xFF00D1FF))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, bool ocultaTexto = false, required IconData icono, required TextEditingController controlador}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          obscureText: ocultaTexto,
          decoration: InputDecoration(
            prefixIcon: Icon(icono, color: const Color(0xFF1C63BB)),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF848282)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFD2D2D2), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}