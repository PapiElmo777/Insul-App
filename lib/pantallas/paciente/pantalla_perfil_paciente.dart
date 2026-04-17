import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../database/database_helper.dart';
import '../pantalla_login.dart';

class TabPerfilPaciente extends StatefulWidget {
  final String nombrePaciente;
  final VoidCallback onActualizarDashboard; // Avisa al inicio que recargue las gráficas

  const TabPerfilPaciente({
    super.key,
    required this.nombrePaciente,
    required this.onActualizarDashboard,
  });

  @override
  State<TabPerfilPaciente> createState() => _TabPerfilPacienteState();
}

class _TabPerfilPacienteState extends State<TabPerfilPaciente> {
  bool _cargando = true;
  File? _imagenPerfil;

  // Perfil Clínico
  String _tipoDiabetes = '';
  String _alergias = '';
  double _peso = 0.0;
  double _altura = 0.0;
  double _imc = 0.0;

  // Parámetros
  int limiteHipo = 70;
  int limiteHiper = 180;
  int rangoMin = 80;
  int rangoMax = 130;

  // Seguridad
  String _emergenciaNombre = '';
  String _emergenciaParentesco = '';
  String _emergenciaTelefono = '';
  String _medicoNombre = '';

  @override
  void initState() {
    super.initState();
    _cargarDatosPerfil();
  }

  Future<void> _cargarDatosPerfil() async {
    final db = DatabaseHelper();
    final usuarioId = await db.obtenerSesionActiva();

    if (usuarioId != null) {
      final usuario = await db.obtenerUsuarioPorId(usuarioId);
      final paciente = await db.obtenerPacientePorUsuario(usuarioId);

      if (usuario != null && paciente != null) {
        if (usuario['foto_perfil'] != null && usuario['foto_perfil'].toString().isNotEmpty) {
          _imagenPerfil = File(usuario['foto_perfil']);
        }

        _tipoDiabetes = paciente['tipo_diabetes'] ?? 'No especificado';
        _alergias = paciente['alergias'] ?? 'Ninguna';
        _peso = (paciente['peso'] as num?)?.toDouble() ?? 0.0;
        _altura = (paciente['altura'] as num?)?.toDouble() ?? 0.0;
        _imc = (paciente['imc'] as num?)?.toDouble() ?? 0.0;

        limiteHipo = (paciente['limite_hipo'] as num?)?.toInt() ?? 70;
        limiteHiper = (paciente['limite_hiper'] as num?)?.toInt() ?? 180;
        rangoMin = (paciente['rango_min'] as num?)?.toInt() ?? 80;
        rangoMax = (paciente['rango_max'] as num?)?.toInt() ?? 130;

        _emergenciaNombre = paciente['emergencia_nombre'] ?? '';
        _emergenciaParentesco = paciente['emergencia_parentesco'] ?? '';
        _emergenciaTelefono = paciente['emergencia_telefono'] ?? '';
        _medicoNombre = paciente['medico_nombre'] ?? '';
      }
    }

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  Future<void> _seleccionarImagen(ImageSource origen) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagenSeleccionada = await picker.pickImage(source: origen);
      if (imagenSeleccionada != null) {
        final db = DatabaseHelper();
        final usuarioId = await db.obtenerSesionActiva();
        if (usuarioId != null) {
          await db.actualizarFotoPerfil(usuarioId, imagenSeleccionada.path);
        }
        setState(() {
          _imagenPerfil = File(imagenSeleccionada.path);
        });
        widget.onActualizarDashboard(); // Para que la foto cambie en la pestaña de inicio también
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccionar foto de perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1C63BB)),
                title: const Text('Elegir de la Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1C63BB)),
                title: const Text('Tomar una Foto'),
                onTap: () {
                  Navigator.pop(context);
                  _seleccionarImagen(ImageSource.camera);
                },
              ),
              if (_imagenPerfil != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Eliminar foto actual', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    final db = DatabaseHelper();
                    final usuarioId = await db.obtenerSesionActiva();
                    if (usuarioId != null) await db.actualizarFotoPerfil(usuarioId, '');
                    Navigator.pop(context);
                    setState(() => _imagenPerfil = null);
                    widget.onActualizarDashboard();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarPerfilClinico() {
    final TextEditingController tipoDiabetesCtrl = TextEditingController(text: _tipoDiabetes);
    final TextEditingController alergiasCtrl = TextEditingController(text: _alergias);
    final TextEditingController pesoCtrl = TextEditingController(text: _peso > 0 ? _peso.toString() : '');
    final TextEditingController alturaCtrl = TextEditingController(text: _altura > 0 ? _altura.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil Clínico', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Tipo de Diabetes', tipoDiabetesCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Alergias Conocidas', alergiasCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Peso (kg)', pesoCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Altura (cm)', alturaCtrl, esNumero: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                double nuevoPeso = double.tryParse(pesoCtrl.text) ?? _peso;
                double nuevaAltura = double.tryParse(alturaCtrl.text) ?? _altura;
                double nuevoImc = 0.0;

                if (nuevoPeso > 0 && nuevaAltura > 0) {
                  double alturaMetros = nuevaAltura / 100;
                  nuevoImc = nuevoPeso / (alturaMetros * alturaMetros);
                }

                final db = DatabaseHelper();
                final usuarioId = await db.obtenerSesionActiva();

                if (usuarioId != null) {
                  await db.actualizarPaciente(usuarioId, {
                    'tipo_diabetes': tipoDiabetesCtrl.text,
                    'alergias': alergiasCtrl.text,
                    'peso': nuevoPeso,
                    'altura': nuevaAltura,
                    'imc': nuevoImc,
                  });
                }

                setState(() {
                  _tipoDiabetes = tipoDiabetesCtrl.text.isEmpty ? 'No especificado' : tipoDiabetesCtrl.text;
                  _alergias = alergiasCtrl.text.isEmpty ? 'Ninguna' : alergiasCtrl.text;
                  _peso = nuevoPeso;
                  _altura = nuevaAltura;
                  _imc = nuevoImc;
                });

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarParametros() {
    final TextEditingController hipoCtrl = TextEditingController(text: limiteHipo.toString());
    final TextEditingController hiperCtrl = TextEditingController(text: limiteHiper.toString());
    final TextEditingController rMinCtrl = TextEditingController(text: rangoMin.toString());
    final TextEditingController rMaxCtrl = TextEditingController(text: rangoMax.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Parámetros', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Límite Hipoglucemia (mg/dL)', hipoCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Límite Hiperglucemia (mg/dL)', hiperCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Rango Mínimo Normal', rMinCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Rango Máximo Normal', rMaxCtrl, esNumero: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                int nHipo = int.tryParse(hipoCtrl.text) ?? limiteHipo;
                int nHiper = int.tryParse(hiperCtrl.text) ?? limiteHiper;
                int nRMin = int.tryParse(rMinCtrl.text) ?? rangoMin;
                int nRMax = int.tryParse(rMaxCtrl.text) ?? rangoMax;

                final db = DatabaseHelper();
                final usuarioId = await db.obtenerSesionActiva();

                if (usuarioId != null) {
                  await db.actualizarPaciente(usuarioId, {
                    'limite_hipo': nHipo,
                    'limite_hiper': nHiper,
                    'rango_min': nRMin,
                    'rango_max': nRMax,
                  });
                }

                setState(() {
                  limiteHipo = nHipo;
                  limiteHiper = nHiper;
                  rangoMin = nRMin;
                  rangoMax = nRMax;
                });

                widget.onActualizarDashboard(); // Recalcula los TIR y gráficas del inicio
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarSeguridad() {
    final TextEditingController emNombreCtrl = TextEditingController(text: _emergenciaNombre);
    final TextEditingController emParentescoCtrl = TextEditingController(text: _emergenciaParentesco);
    final TextEditingController emTelefonoCtrl = TextEditingController(text: _emergenciaTelefono);
    final TextEditingController medicoCtrl = TextEditingController(text: _medicoNombre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Seguridad', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Nombre Contacto', emNombreCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Parentesco', emParentescoCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Teléfono Contacto', emTelefonoCtrl, esNumero: true),
                const SizedBox(height: 10),
                _crearCampoEdicion('Médico Tratante', medicoCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton(
              onPressed: () async {
                final db = DatabaseHelper();
                final usuarioId = await db.obtenerSesionActiva();

                if (usuarioId != null) {
                  await db.actualizarPaciente(usuarioId, {
                    'emergencia_nombre': emNombreCtrl.text,
                    'emergencia_parentesco': emParentescoCtrl.text,
                    'emergencia_telefono': emTelefonoCtrl.text,
                    'medico_nombre': medicoCtrl.text,
                  });
                }

                setState(() {
                  _emergenciaNombre = emNombreCtrl.text;
                  _emergenciaParentesco = emParentescoCtrl.text;
                  _emergenciaTelefono = emTelefonoCtrl.text;
                  _medicoNombre = medicoCtrl.text;
                });

                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampoEdicion(String label, TextEditingController controlador, {bool esNumero = false}) {
    return TextField(
      controller: controlador,
      keyboardType: esNumero ? TextInputType.number : TextInputType.text,
      inputFormatters: esNumero ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi Perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 30),

          // 1. FOTO DE PERFIL
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: const Color(0xFF1C63BB), width: 3),
                    image: _imagenPerfil != null
                        ? DecorationImage(image: FileImage(_imagenPerfil!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imagenPerfil == null ? const Icon(Icons.person, color: Colors.white, size: 60) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _mostrarOpcionesImagen,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: Color(0xFF00D1FF), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(child: Text(widget.nombrePaciente, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
          const SizedBox(height: 30),

          // 2. PERFIL CLÍNICO
          _crearSeccionPerfil(
              titulo: 'Perfil Clínico',
              icono: Icons.health_and_safety,
              onEdit: _mostrarDialogoEditarPerfilClinico,
              hijos: [
                _crearDatoPerfil(Icons.medical_information, 'Tipo de Diabetes', _tipoDiabetes),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                _crearDatoPerfil(Icons.warning_amber_rounded, 'Alergias', _alergias),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                Row(
                  children: [
                    Expanded(child: _crearDatoPerfil(Icons.monitor_weight, 'Peso', '$_peso kg')),
                    Expanded(child: _crearDatoPerfil(Icons.height, 'Altura', '$_altura cm')),
                  ],
                ),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                _crearDatoPerfil(Icons.calculate, 'IMC', _imc.toStringAsFixed(1)),
              ]
          ),
          const SizedBox(height: 20),

          // 3. PARÁMETROS DE CONTROL
          _crearSeccionPerfil(
              titulo: 'Parámetros de Control',
              icono: Icons.tune,
              onEdit: _mostrarDialogoEditarParametros,
              hijos: [
                _crearDatoPerfil(Icons.arrow_downward, 'Límite Hipoglucemia', '< $limiteHipo mg/dL'),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                _crearDatoPerfil(Icons.arrow_upward, 'Límite Hiperglucemia', '> $limiteHiper mg/dL'),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                _crearDatoPerfil(Icons.check_circle_outline, 'Rango Objetivo', '$rangoMin - $rangoMax mg/dL'),
              ]
          ),
          const SizedBox(height: 20),

          // 4. SEGURIDAD
          _crearSeccionPerfil(
              titulo: 'Seguridad',
              icono: Icons.security,
              onEdit: _mostrarDialogoEditarSeguridad,
              hijos: [
                _crearDatoPerfil(Icons.emergency, 'Contacto de Emergencia', '$_emergenciaNombre ($_emergenciaParentesco)\nTel: $_emergenciaTelefono'),
                const Divider(height: 15, color: Color(0xFFD2D2D2)),
                _crearDatoPerfil(Icons.local_hospital, 'Médico Tratante', _medicoNombre),
              ]
          ),
          const SizedBox(height: 40),

          // 5. CERRAR SESIÓN
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                final db = DatabaseHelper();
                await db.cerrarSesion();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaLogin()),
                        (Route<dynamic> route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4A4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _crearSeccionPerfil({required String titulo, required IconData icono, required VoidCallback onEdit, required List<Widget> hijos}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icono, color: const Color(0xFF1C63BB)),
                  const SizedBox(width: 10),
                  Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF0C80EB)),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...hijos,
        ],
      ),
    );
  }

  Widget _crearDatoPerfil(IconData icono, String titulo, String valor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
          child: Icon(icono, color: const Color(0xFF1C63BB), size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(valor.isEmpty ? '--' : valor, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}