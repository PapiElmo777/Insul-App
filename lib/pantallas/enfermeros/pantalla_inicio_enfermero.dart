import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../servicios/reporte_enfermero_service.dart';
import 'pantalla_agregar_paciente.dart';
import 'pantalla_detalle_paciente.dart';

class PantallaInicioEnfermero extends StatefulWidget {
  final String nombreEnfermero;

  const PantallaInicioEnfermero({
    super.key,
    this.nombreEnfermero = 'Alfredo',
  });

  @override
  State<PantallaInicioEnfermero> createState() => _PantallaInicioEnfermeroState();
}

class _PantallaInicioEnfermeroState extends State<PantallaInicioEnfermero> {
  int _indiceNavegacionActual = 0;
  String _fechaFormateada = '';
  List<Map<String, dynamic>> _listaPacientes = [];
  List<Map<String, dynamic>> _reportesGenerados = [];
  File? _imagenPerfil;
  final TextEditingController _busquedaCtrl = TextEditingController();

  late String _nombreEnfermeroLocal;
  String cedulaEnfermero = '12345678';
  String areaEnfermero = 'Medicina Interna';
  String hospitalEnfermero = 'Hospital Ángeles';
  String correoEnfermero = 'alfredo.enfermero@insulapp.com';
  String telefonoEnfermero = '+52 123 456 7890';

  @override
  void initState() {
    super.initState();
    _nombreEnfermeroLocal = widget.nombreEnfermero;
    _inicializarFecha();
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
    _actualizarFecha();
  }

  void _actualizarFecha() {
    final DateTime ahora = DateTime.now();
    final DateFormat formateador = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES');
    String fecha = formateador.format(ahora);
    if (fecha.isNotEmpty) {
      fecha = fecha[0].toUpperCase() + fecha.substring(1);
    }

    setState(() {
      _fechaFormateada = fecha;
    });
  }

  Future<void> _seleccionarImagen(ImageSource origen) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? imagenSeleccionada = await picker.pickImage(source: origen);
      if (imagenSeleccionada != null) {
        setState(() {
          _imagenPerfil = File(imagenSeleccionada.path);
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  void _mostrarOpcionesImagen() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccionar foto de perfil',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _imagenPerfil = null;
                    });
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarPerfilEnfermero() {
    final TextEditingController nombreCtrl = TextEditingController(text: _nombreEnfermeroLocal);
    final TextEditingController correoCtrl = TextEditingController(text: correoEnfermero);
    final TextEditingController telefonoCtrl = TextEditingController(text: telefonoEnfermero);
    final TextEditingController cedulaCtrl = TextEditingController(text: cedulaEnfermero);
    final TextEditingController hospitalCtrl = TextEditingController(text: hospitalEnfermero);
    final TextEditingController areaCtrl = TextEditingController(text: areaEnfermero);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Nombre Completo', nombreCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Correo Electrónico', correoCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Teléfono', telefonoCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Cédula Profesional', cedulaCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Institución Médica', hospitalCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Área', areaCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _nombreEnfermeroLocal = nombreCtrl.text;
                  correoEnfermero = correoCtrl.text;
                  telefonoEnfermero = telefonoCtrl.text;
                  cedulaEnfermero = cedulaCtrl.text;
                  hospitalEnfermero = hospitalCtrl.text;
                  areaEnfermero = areaCtrl.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampoEdicion(String label, TextEditingController controlador) {
    return TextField(
      controller: controlador,
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

  Future<String?> preguntarTurno(BuildContext context) async {
    String? turnoSeleccionado = 'Matutino';

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Generar Reporte de Turno', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selecciona el turno que deseas finalizar:'),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: turnoSeleccionado,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  items: ['Matutino', 'Vespertino', 'Nocturno']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setStateDialog(() {
                      turnoSeleccionado = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, turnoSeleccionado),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0C80EB)),
                child: const Text('Generar PDF', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _indiceNavegacionActual == 0
            ? _construirTabHome()
            : _indiceNavegacionActual == 1
            ? _construirTabDirectorioPacientes()
            : _indiceNavegacionActual == 2
            ? _construirTabReporte()
            : _indiceNavegacionActual == 3
            ? _construirTabPerfil()
            : const Center(child: Text("Error de navegación", style: TextStyle(color: Colors.grey))),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _indiceNavegacionActual,
            onTap: (index) {
              setState(() {
                _indiceNavegacionActual = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.black,
            unselectedItemColor: const Color(0xFF888888),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home_outlined, size: 28, color: _indiceNavegacionActual == 0 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 0) _puntoRojo(),
                  ],
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bar_chart, size: 28, color: _indiceNavegacionActual == 1 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 1) _puntoRojo(),
                  ],
                ),
                label: 'Pacientes',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 28, color: _indiceNavegacionActual == 2 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 2) _puntoRojo(),
                  ],
                ),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 28, color: _indiceNavegacionActual == 3 ? Colors.black : const Color(0xFF888888)),
                    if (_indiceNavegacionActual == 3) _puntoRojo(),
                  ],
                ),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _puntoRojo() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        color: Color(0xFFFF4A4A),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _construirLeyendaColores() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _itemLeyenda(const Color(0xFFFF6B6B), 'Hipo'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF06CA23), 'Normal'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFD9E00C), 'Precaución'),
            const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFFFB347), 'Hiper'),
            const SizedBox(width: 15),
            _itemLeyenda(Colors.grey, 'Sin Dato'),
          ],
        ),
      ),
    );
  }

  Widget _itemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          texto,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _construirTabHome() {
    int totalPacientes = _listaPacientes.length;
    int pacientesEstables = 0;
    int pacientesPrioridad = 0;

    for (var p in _listaPacientes) {
      int val = p['glucosa'] ?? 0;
      int hipo = p['hipoLimit'] ?? 70;
      int hiper = p['hiperLimit'] ?? 180;
      int rMin = p['rangoMin'] ?? 80;
      int rMax = p['rangoMax'] ?? 130;

      if (val != 0) {
        if (val >= rMin && val <= rMax) {
          pacientesEstables++;
        } else if (val < hipo || val > hiper) {
          pacientesPrioridad++;
        }
      }
    }

    List<Map<String, dynamic>> pacientesFiltrados = _listaPacientes.where((p) {
      String termino = _busquedaCtrl.text.toLowerCase();
      String nombre = (p['nombre'] ?? '').toLowerCase();
      String ubicacion = (p['ubicacion'] ?? '').toLowerCase();
      return nombre.contains(termino) || ubicacion.contains(termino);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 30.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1C63BB),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Enf. $_nombreEnfermeroLocal',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _fechaFormateada,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _indiceNavegacionActual = 3;
                      });
                    },
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 2),
                        image: _imagenPerfil != null
                            ? DecorationImage(image: FileImage(_imagenPerfil!), fit: BoxFit.cover)
                            : const DecorationImage(
                          image: AssetImage('assets/enfermero_placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: _imagenPerfil == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(25.0),
          child: Row(
            children: [
              Expanded(child: _crearTarjetaDashboard('Total', totalPacientes.toString(), Icons.people, const Color(0xFF1C63BB))),
              const SizedBox(width: 10),
              Expanded(child: _crearTarjetaDashboard('Estables', pacientesEstables.toString(), Icons.check_circle, const Color(0xFF06CA23))),
              const SizedBox(width: 10),
              Expanded(child: _crearTarjetaDashboard('Atención', pacientesPrioridad.toString(), Icons.warning, const Color(0xFFFF4A4A))),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Pacientes',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final nuevoPaciente = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaAgregarPaciente()),
                  );

                  if (nuevoPaciente != null) {
                    setState(() {
                      _listaPacientes.add(nuevoPaciente);
                    });
                  }
                },
                icon: const Icon(Icons.add, size: 20, color: Colors.white),
                label: const Text(
                  'Añadir',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C80EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                ),
              ),
            ],
          ),
        ),

        _construirLeyendaColores(),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
            ),
            child: TextField(
              controller: _busquedaCtrl,
              onChanged: (val) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar paciente o cama...',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Color(0xFF1C63BB)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        Expanded(
          child: pacientesFiltrados.isEmpty
              ? Center(
            child: Text(
              _listaPacientes.isEmpty
                  ? 'No tienes pacientes asignados.\nToca "Añadir" para comenzar.'
                  : 'No se encontraron pacientes.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
            itemCount: pacientesFiltrados.length,
            itemBuilder: (context, index) {
              final paciente = pacientesFiltrados[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: _TarjetaPaciente(
                  paciente: paciente,
                  onTap: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetallePaciente(paciente: paciente, nombreEnfermero: _nombreEnfermeroLocal)));
                    if (res == 'eliminar') {
                      setState(() {
                        _listaPacientes.remove(paciente);
                      });
                    } else {
                      setState(() {});
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _crearTarjetaDashboard(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 28),
          const SizedBox(height: 8),
          Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(titulo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _construirTabDirectorioPacientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 10.0),
          child: Text(
            'Directorio de Pacientes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black),
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: _listaPacientes.isEmpty
              ? const Center(
            child: Text(
              'No hay pacientes en el directorio.',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            itemCount: _listaPacientes.length,
            itemBuilder: (context, index) {
              final paciente = _listaPacientes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: _TarjetaPacienteDetallada(
                  paciente: paciente,
                  onTap: () async {
                    final res = await Navigator.push(context, MaterialPageRoute(builder: (context) => PantallaDetallePaciente(paciente: paciente, nombreEnfermero: _nombreEnfermeroLocal)));
                    if (res == 'eliminar') {
                      setState(() {
                        _listaPacientes.remove(paciente);
                      });
                    } else {
                      setState(() {});
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _construirTabReporte() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Finalización de Turno', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 10),
          const Text('Genera el reporte clínico consolidado de todos tus pacientes en formato PDF para la entrega de turno.', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 40),

          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                const Icon(Icons.picture_as_pdf, size: 80, color: Color(0xFF1C63BB)),
                const SizedBox(height: 20),
                const Text('Reporte Consolidado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text('Pacientes activos: ${_listaPacientes.length}', style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_listaPacientes.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No hay pacientes para generar el reporte.')));
                        return;
                      }

                      final turno = await preguntarTurno(context);
                      if (turno == null) return;

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );

                      try {
                        final enfermero = DatosEnfermero(
                          nombre: _nombreEnfermeroLocal,
                          cedula: cedulaEnfermero,
                          area: areaEnfermero,
                          hospital: hospitalEnfermero,
                        );

                        final bytes = await ReportePdfService.generarReporteTurno(
                          pacientes: _listaPacientes,
                          enfermero: enfermero,
                          turno: turno,
                        );

                        final String idUnico = DateTime.now().millisecondsSinceEpoch.toString();

                        setState(() {
                          _reportesGenerados = [
                            {
                              'id': idUnico,
                              'fecha': DateTime.now(),
                              'turno': turno,
                              'pacientes': _listaPacientes.length,
                              'bytes': bytes,
                            },
                            ..._reportesGenerados
                          ];
                        });

                        if (!mounted) return;
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VisorPdfPantalla(
                              bytes: bytes,
                              turno: turno,
                              reporteId: idUnico,
                            ),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al generar: $e')));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C63BB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('GENERAR Y VISUALIZAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text('Nota:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          const Text('Este reporte incluye historial de glucosa, administración de insulina y notas clínicas de cada paciente.', style: TextStyle(color: Colors.black54, fontSize: 13)),

          const SizedBox(height: 40),
          const Divider(thickness: 1, color: Color(0xFFD2D2D2)),
          const SizedBox(height: 20),

          const Text('Historial de Reportes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 15),

          if (_reportesGenerados.isEmpty)
            const Text('Aún no se han generado reportes en este turno.', style: TextStyle(color: Colors.grey, fontSize: 14))
          else
            ...List.generate(_reportesGenerados.length, (index) {
              final reporte = _reportesGenerados[index];
              final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(reporte['fecha']);
              return Card(
                key: Key(reporte['id']), // IMPORTANTE: Obliga a redibujar esta tarjeta específicamente
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFFD2D2D2)),
                ),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
                    child: const Icon(Icons.description, color: Color(0xFF1C63BB)),
                  ),
                  title: Text('Turno ${reporte['turno']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Text('$fechaStr\n${reporte['pacientes']} pacientes reportados'),
                  trailing: const Icon(Icons.visibility, color: Color(0xFF0C80EB)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VisorPdfPantalla(
                          bytes: reporte['bytes'],
                          turno: reporte['turno'],
                          reporteId: reporte['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _construirTabPerfil() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi Perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 30),
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
                        : const DecorationImage(
                      image: AssetImage('assets/enfermero_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D1FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _crearDatoPerfil(Icons.person, 'Nombre Completo', _nombreEnfermeroLocal),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.email, 'Correo Electrónico', correoEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.phone, 'Teléfono', telefonoEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.badge, 'Cédula Profesional', cedulaEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.local_hospital, 'Institución Médica', hospitalEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.medical_services, 'Área', areaEnfermero),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _mostrarDialogoEditarPerfilEnfermero,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C63BB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4A4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearDatoPerfil(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
          child: Icon(icono, color: const Color(0xFF1C63BB)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TarjetaPaciente extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const _TarjetaPaciente({
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int val = paciente['glucosa'] ?? 0;
    int hipo = paciente['hipoLimit'] ?? 70;
    int hiper = paciente['hiperLimit'] ?? 180;
    int rMin = paciente['rangoMin'] ?? 80;
    int rMax = paciente['rangoMax'] ?? 130;

    Color colorIndicador;
    bool esAlerta = false;

    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo) {
      colorIndicador = const Color(0xFFFF6B6B);
      esAlerta = true;
    } else if (val > hiper) {
      colorIndicador = const Color(0xFFFFB347);
      esAlerta = true;
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF06CA23);
    } else {
      colorIndicador = const Color(0xFFD9E00C);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: esAlerta ? colorIndicador : const Color(0xFFD2D2D2),
              width: esAlerta ? 2.5 : 1.5
          ),
          boxShadow: esAlerta
              ? [BoxShadow(color: colorIndicador.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (esAlerta) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20)),
                      Expanded(
                        child: Text(
                          paciente['nombre'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Cama/Ubicación: ${paciente['ubicacion']}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Última glucosa',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorIndicador,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (paciente['proximaDosis'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.colorize, color: Color(0xFF1C63BB), size: 20),
                    const SizedBox(height: 4),
                    const Text(
                      'Próx. dosis',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      paciente['proximaDosis'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1C63BB),
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

class _TarjetaPacienteDetallada extends StatelessWidget {
  final Map<String, dynamic> paciente;
  final VoidCallback onTap;

  const _TarjetaPacienteDetallada({
    required this.paciente,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int val = paciente['glucosa'] ?? 0;
    int hipo = paciente['hipoLimit'] ?? 70;
    int hiper = paciente['hiperLimit'] ?? 180;
    int rMin = paciente['rangoMin'] ?? 80;
    int rMax = paciente['rangoMax'] ?? 130;

    Color colorIndicador;
    if (val == 0) {
      colorIndicador = Colors.grey;
    } else if (val < hipo) {
      colorIndicador = const Color(0xFFFF6B6B);
    } else if (val > hiper) {
      colorIndicador = const Color(0xFFFFB347);
    } else if (val >= rMin && val <= rMax) {
      colorIndicador = const Color(0xFF06CA23);
    } else {
      colorIndicador = const Color(0xFFD9E00C);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paciente['nombre'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black)),
                      Text('Edad: ${paciente['edad']} | Exp: ${paciente['expediente']}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ubicación', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(paciente['ubicacion'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tipo Diabetes', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      Text(paciente['tipoDiabetes'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: colorIndicador, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Último registro:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(paciente['glucosa'] == 0 ? '-- mg/dL' : '${paciente['glucosa']} mg/dL', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black)),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.colorize, size: 16, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(paciente['proximaDosis'] ?? 'Pendiente', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                    ],
                  )
                ],
              ),
            ),

            if (paciente['alergias'] != null && paciente['alergias'] != 'Ninguna') ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4A4A), size: 16),
                  const SizedBox(width: 5),
                  Expanded(child: Text('Alergias: ${paciente['alergias']}', style: const TextStyle(fontSize: 16, color: Color(0xFFFF4A4A), fontWeight: FontWeight.bold))),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}

class VisorPdfPantalla extends StatelessWidget {
  final Uint8List bytes;
  final String turno;
  final String reporteId;

  const VisorPdfPantalla({
    super.key,
    required this.bytes,
    required this.turno,
    required this.reporteId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        title: Text('Reporte de Turno $turno', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PdfPreview(
        key: Key(reporteId),
        build: (format) async => bytes,
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'Reporte_Turno_${turno}_$reporteId.pdf',
      ),
    );
  }
}