import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PantallaInicioPaciente extends StatefulWidget {
  final String nombrePaciente;

  const PantallaInicioPaciente({
    super.key,
    this.nombrePaciente = 'Cesar',
  });

  @override
  State<PantallaInicioPaciente> createState() => _PantallaInicioPacienteState();
}

class _PantallaInicioPacienteState extends State<PantallaInicioPaciente> {
  int _indiceNavegacionActual = 0;
  String _fechaFormateada = '';

  // DATOS TEMPORALES
  final int ultimaGlucosa = 102;
  final String tiempoUltimaLectura = '9/3/2026 a las 11:29';
  final int promedioGlucosa = 97;
  final int tirPorcentaje = 90;

  @override
  void initState() {
    super.initState();
    _inicializarFecha();
  }

  Future<void> _inicializarFecha() async {
    await initializeDateFormatting('es_ES', null);
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

  String _obtenerSaludo() {
    var hora = DateTime.now().hour;
    if (hora < 12) {
      return 'Buenos días';
    } else if (hora < 19) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _indiceNavegacionActual == 0
            ? _construirDashboard()
            : _construirPlaceholderTabs(),
      ),
      bottomNavigationBar: _construirBottomNavigation(),
    );
  }

  Widget _construirDashboard() {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_obtenerSaludo()},\n${widget.nombrePaciente}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fechaFormateada,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: Color(0xFFE8E8E8),
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
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Última Lectura',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                            color: Color(0xFF3F3F3F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            ultimaGlucosa.toString(),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 64,
                              height: 1.0,
                              color: Color(0xFF01689C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'mg/dL',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: Color(0xFF848282),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFCBFB97),
                              border: Border.all(color: const Color(0xFF2B940B), width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Normal',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF2B940B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF888888), width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'En ayunas',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tiempoUltimaLectura,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Color(0xFFC5C5C5),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Ver todos registros',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF888888),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'TIR (Rango)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$tirPorcentaje%',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 48,
                                height: 1.2,
                                color: Color(0xFF01689C),
                              ),
                            ),
                            const Text(
                              'Últimos 30 días',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Promedio General
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Promedio',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF2F2F2F),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              promedioGlucosa.toString(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 48,
                                height: 1.2,
                                color: Color(0xFF01689C),
                              ),
                            ),
                            const Text(
                              'Histórico total',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _construirPlaceholderTabs() {
    return Center(
      child: Text(
        'Pestaña en construcción',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 18),
      ),
    );
  }

  Widget _construirBottomNavigation() {
    return Container(
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
          selectedItemColor: const Color(0xFF2F2F2F),
          unselectedItemColor: const Color(0xFF888888),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_filled, size: 28, color: _indiceNavegacionActual == 0 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 0) _puntoRojo(),
                ],
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.show_chart_rounded, size: 28, color: _indiceNavegacionActual == 1 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 1) _puntoRojo(),
                ],
              ),
              label: 'Estadísticas',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_filled, size: 28, color: _indiceNavegacionActual == 2 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 2) _puntoRojo(),
                ],
              ),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 28, color: _indiceNavegacionActual == 3 ? const Color(0xFF2F2F2F) : const Color(0xFF888888)),
                  if (_indiceNavegacionActual == 3) _puntoRojo(),
                ],
              ),
              label: 'Perfil',
            ),
          ],
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
}