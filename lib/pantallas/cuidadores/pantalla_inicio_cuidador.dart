import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../pantalla_login.dart';
import '../pantallas_cuestionarios.dart';
import 'pantalla_detalle_familiar.dart';
import 'tab_reportes_cuidador.dart';

class PantallaInicioCuidador extends StatefulWidget {
  final String nombreCuidador;

  const PantallaInicioCuidador({super.key, required this.nombreCuidador});

  @override
  State<PantallaInicioCuidador> createState() => _PantallaInicioCuidadorState();
}

class _PantallaInicioCuidadorState extends State<PantallaInicioCuidador> {
  int _indiceActual = 0;
  String _saludo = '';
  List<Map<String, dynamic>> _pacientes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _determinarSaludo();
    _cargarPacientes();
  }

  void _determinarSaludo() {
    final hora = DateTime.now().hour;
    if (hora >= 6 && hora < 12) {
      _saludo = 'Buenos días';
    } else if (hora >= 12 && hora < 19) {
      _saludo = 'Buenas tardes';
    } else {
      _saludo = 'Buenas noches';
    }
  }

  Future<void> _cargarPacientes() async {
    final db = DatabaseHelper();
    final userId = await db.obtenerSesionActiva();

    if (userId != null) {
      final data = await db.obtenerPacientesPorCuidador(userId);
      if (mounted) {
        setState(() {
          _pacientes = data;
          _cargando = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _cerrarSesion() async {
    final db = DatabaseHelper();
    await db.cerrarSesion();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PantallaLogin()),
          (Route<dynamic> route) => false,
    );
  }

  void _agregarFamiliar() {
    if (_pacientes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Has alcanzado el límite máximo de 5 familiares.')),
            ],
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PantallaCuestionarioCuidador()),
      ).then((_) => _cargarPacientes());
    }
  }

  void _cambiarTab(int index) {
    setState(() {
      _indiceActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _indiceActual == 0
          ? _construirVistaFamiliares()
          : const TabReportesCuidador(),
      floatingActionButton: _indiceActual == 0
          ? FloatingActionButton.extended(
        onPressed: _agregarFamiliar,
        backgroundColor: const Color(0xFF00D1FF),
        icon: const Icon(Icons.person_add_alt_1, color: Color(0xFF1C63BB)),
        label: const Text('Añadir Familiar', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
      )
          : null,

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          child: BottomNavigationBar(
            currentIndex: _indiceActual,
            onTap: _cambiarTab,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1C63BB),
            unselectedItemColor: const Color(0xFF888888),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_shared),
                label: 'Historiales',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirVistaFamiliares() {
    if (_cargando) {
      return const Center(child: CircularProgressAnimation());
    }

    return Column(
      children: [
        _construirHeader(),
        Expanded(
          child: _pacientes.isEmpty
              ? _construirEstadoVacio()
              : _construirListaPacientes(),
        ),
      ],
    );
  }

  Widget _construirHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF1C63BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_saludo,',
                      style: const TextStyle(fontSize: 18, color: Colors.white70),
                    ),
                    Text(
                      widget.nombreCuidador,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: _cerrarSesion,
                  tooltip: 'Cerrar Sesión',
                ),
              )
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.family_restroom, color: Color(0xFF00D1FF)),
                const SizedBox(width: 10),
                Text(
                  'Familiares a cargo: ${_pacientes.length} / 5',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Aún no tienes familiares a tu cargo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Presiona el botón "Añadir Familiar" para registrar el perfil clínico de tu paciente y comenzar a monitorearlo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirListaPacientes() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _pacientes.length,
      itemBuilder: (context, index) {
        final paciente = _pacientes[index];

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaDetalleFamiliar(
                    paciente: paciente,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F8),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00D1FF), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        paciente['nombre'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paciente['nombre'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C63BB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            paciente['parentesco'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB)),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${paciente['tipo_diabetes']} • ${paciente['edad']} años',
                          style: const TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressAnimation extends StatelessWidget {
  const CircularProgressAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C63BB)),
      ),
    );
  }
}