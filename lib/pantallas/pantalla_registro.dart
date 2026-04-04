import 'package:flutter/material.dart';
import 'pantallas_cuestionarios.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  String ladaSeleccionada = '+52';
  String? rolSeleccionado;

  final List<Map<String, String>> paises = [
    {'bandera': '🇲🇽', 'lada': '+52'},
    {'bandera': '🇺🇸', 'lada': '+1'},
    {'bandera': '🇨🇴', 'lada': '+57'},
    {'bandera': '🇦🇷', 'lada': '+54'},
  ];

  final List<String> roles = ['Enfermero', 'Paciente', 'Cuidador'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C63BB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 80),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 32, color: Colors.white),
                        children: [
                          TextSpan(text: 'Insul ', style: TextStyle(fontWeight: FontWeight.w400)),
                          TextSpan(text: 'App', style: TextStyle(fontWeight: FontWeight.bold)),
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
              const SizedBox(height: 20),
              _crearCampoTexto(titulo: 'Nombre completo', hint: 'Ej. Juan Pablo'),
              const SizedBox(height: 15),
              _crearCampoTexto(titulo: 'Apellidos', hint: 'Ej. Jiménez'),
              const SizedBox(height: 15),
              _crearCampoTexto(titulo: 'Correo electronico', hint: 'ejemplito@ejemplo.com'),
              const SizedBox(height: 15),
              _crearCampoTexto(titulo: 'Contraseña', hint: 'Contraseña', ocultaTexto: true),
              const SizedBox(height: 15),
              const Text(
                'Telefono',
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
                    const Expanded(
                      child: TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15),
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
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (rolSeleccionado == 'Enfermero') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCuestionarioEnfermero()));
                    } else if (rolSeleccionado == 'Paciente') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCuestionarioPaciente()));
                    } else if (rolSeleccionado == 'Cuidador') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaCuestionarioCuidador()));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF008CCF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25), side: const BorderSide(color: Color(0xFFD2D2D2), width: 1.5)),
                  ),
                  child: const Text('Continuar con el registro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      ),
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, bool ocultaTexto = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: ocultaTexto,
          decoration: InputDecoration(
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