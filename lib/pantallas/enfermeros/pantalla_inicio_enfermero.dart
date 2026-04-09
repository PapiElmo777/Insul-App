import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pantalla_agregar_paciente.dart';

class PantallaInicioEnfermero extends StatefulWidget {
  final String nombreEnfermero; // aqui va el name de la BD

  const PantallaInicioEnfermero({
    super.key,
    this.nombreEnfermero = 'Alfredo',//temporal
  });

  @override
  State<PantallaInicioEnfermero> createState() => _PantallaInicioEnfermeroState();
}

class _PantallaInicioEnfermeroState extends State<PantallaInicioEnfermero> {
  int _indiceNavegacionActual = 0;
  String _fechaFormateada = '';
  List<Map<String, dynamic>> _listaPacientes = [];

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 30.0, 25.0, 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Enf. ${widget.nombreEnfermero}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2F2F2F),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _fechaFormateada,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                      image: const DecorationImage(
                        image: AssetImage('assets/enfermero_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
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
                    icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.white),
                    label: const Text(
                      'Agregar Paciente',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C80EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Color(0xFFD2D2D2), width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: _listaPacientes.isEmpty
                  ? const Center(
                child: Text(
                  'No tienes pacientes asignados.\nToca "Agregar Paciente" para comenzar.',
                  textAlign: TextAlign.center,
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
                    child: _TarjetaPaciente(
                      nombre: paciente['nombre'],
                      glucosa: paciente['glucosa'],
                      estadoGlucosa: paciente['estadoGlucosa'],
                      proximaDosis: paciente['proximaDosis'],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
                    if (_indiceNavegacionActual == 0)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4A4A),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.show_chart, size: 28, color: _indiceNavegacionActual == 1 ? Colors.black : const Color(0xFF888888)),
                label: 'Actividad',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart, size: 28, color: _indiceNavegacionActual == 2 ? Colors.black : const Color(0xFF888888)),
                label: 'Estadísticas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.access_time, size: 28, color: _indiceNavegacionActual == 3 ? Colors.black : const Color(0xFF888888)),
                label: 'Historial',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border, size: 28, color: _indiceNavegacionActual == 4 ? Colors.black : const Color(0xFF888888)),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline, size: 28, color: _indiceNavegacionActual == 5 ? Colors.black : const Color(0xFF888888)),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaPaciente extends StatelessWidget {
  final String nombre;
  final int glucosa;
  final String estadoGlucosa;
  final String? proximaDosis;

  const _TarjetaPaciente({
    required this.nombre,
    required this.glucosa,
    required this.estadoGlucosa,
    this.proximaDosis,
  });

  @override
  Widget build(BuildContext context) {
    Color colorIndicador;
    if (estadoGlucosa == 'normal') {
      colorIndicador = const Color(0xFF06CA23);
    } else if (estadoGlucosa == 'alerta') {
      colorIndicador = const Color(0xFFD9E00C);
    } else {
      colorIndicador = const Color(0xFFE00925);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF008CCF), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person, color: Color(0xFF008CCF), size: 30),
            ),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ultima glucosa',
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
                      glucosa == 0 ? '-- mg/dL' : '$glucosa mg/dL',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (proximaDosis != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.colorize, color: Colors.black, size: 20),
                const SizedBox(height: 4),
                const Text(
                  'Proxima dosis',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  proximaDosis!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}