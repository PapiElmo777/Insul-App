import 'package:flutter/material.dart';
import 'package:insulapp/database/gestores/gestor_cuidadores.dart';
import 'package:insulapp/database/gestores/gestor_pacientes.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../database/database_helper.dart';
import '../../widgets/universales/grafica_glucosa_universal.dart';
import '../../widgets/universales/tarjetas_tir_promedio.dart';
import '../../widgets/universales/dialogo_tir.dart';

class TabGlucosaFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;
  final Function(int) onCambiarTab;

  const TabGlucosaFamiliar({super.key, required this.paciente, required this.onCambiarTab});

  @override
  State<TabGlucosaFamiliar> createState() => _TabGlucosaFamiliarState();
}

class _TabGlucosaFamiliarState extends State<TabGlucosaFamiliar> {
  List<Map<String, dynamic>> _registrosGlucosa = [];
  bool _cargando = true;

  late int limiteHipo;
  late int limiteHiper;
  late int rangoMin;
  late int rangoMax;

  int? _indiceSeleccionadoGrafica;

  @override
  void initState() {
    super.initState();
    _inicializarLimites();
    _cargarRegistros();
  }

  void _inicializarLimites() {
    limiteHipo = (widget.paciente['limite_hipo'] as num?)?.toInt() ?? 70;
    limiteHiper = (widget.paciente['limite_hiper'] as num?)?.toInt() ?? 180;
    rangoMin = (widget.paciente['rango_min'] as num?)?.toInt() ?? 80;
    rangoMax = (widget.paciente['rango_max'] as num?)?.toInt() ?? 130;
  }

  Future<void> _cargarRegistros() async {
    try {
      final data = await GestorCuidadores().obtenerRegistrosGlucosaCuidador(widget.paciente['id']);
      final registrosReales = data.where((r) => (r['valor'] as num) > 0).toList();

      if (mounted) {
        setState(() {
          _registrosGlucosa = registrosReales.map((r) => {
            ...r,
            'valor': (r['valor'] as num).toInt(),
            'fecha': DateTime.tryParse(r['fecha'].toString()) ?? DateTime.now(),
          }).toList();
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint("Error cargando glucosa: $e");
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  int _obtenerUltimaGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    return (_registrosGlucosa.first['valor'] as num).toInt();
  }

  String _obtenerTiempoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    final fechaObj = _registrosGlucosa.first['fecha'];
    if (fechaObj is DateTime) {
      return DateFormat("dd/MM/yyyy 'a las' HH:mm").format(fechaObj);
    }
    return '--';
  }

  String _obtenerMomentoUltimaLectura() {
    if (_registrosGlucosa.isEmpty) return '--';
    return _registrosGlucosa.first['momento'];
  }

  String _obtenerEstadoGlucosa(int valor) {
    if (valor < limiteHipo) return 'Hipoglucemia';
    if (valor >= limiteHipo && valor < rangoMin) return 'Bajo';
    if (valor >= rangoMin && valor <= rangoMax) return 'Normal';
    if (valor > rangoMax && valor <= limiteHiper) return 'Elevado';
    return 'Hiperglucemia';
  }

  Color _obtenerColorEstado(String estado) {
    if (estado == 'Hipoglucemia') return const Color(0xFFD32F2F);
    if (estado == 'Bajo') return const Color(0xFFE65100);
    if (estado == 'Normal') return const Color(0xFF2E7D32);
    if (estado == 'Elevado') return const Color(0xFFE65100);
    return const Color(0xFFD32F2F);
  }

  int _calcularPromedioGlucosa() {
    if (_registrosGlucosa.isEmpty) return 0;
    double suma = 0;
    for (var r in _registrosGlucosa) {
      suma += (r['valor'] as num).toDouble();
    }
    return (suma / _registrosGlucosa.length).round();
  }

  int _calcularTIR() {
    if (_registrosGlucosa.isEmpty) return 0;
    int enRango = 0;
    for (var r in _registrosGlucosa) {
      int val = (r['valor'] as num).toInt();
      if (val >= rangoMin && val <= rangoMax) {
        enRango++;
      }
    }
    return ((enRango / _registrosGlucosa.length) * 100).round();
  }

  void _mostrarDialogoProtocoloADA(String estado) {
    String titulo = estado == 'Hipoglucemia' ? '⚠️ Medida Correctiva (ADA): Hipoglucemia' : '⚠️ Medida Correctiva (ADA): Hiperglucemia';
    String texto = estado == 'Hipoglucemia'
        ? 'Aplica la regla 15-15:\n\n1. Dale 15g de carbohidratos de acción rápida (ej. ½ vaso de jugo, 1 cda. de miel).\n2. Espera 15 min y vuelve a medir su glucosa.\n3. Si sigue menor a 70 mg/dL, repite.\n4. Al normalizarse, dale un snack o comida.'
        : 'Sigue estas recomendaciones:\n\n1. Dale abundante agua.\n2. Aplica su dosis de corrección de insulina según lo indicado por el médico.\n3. Si la glucosa es mayor a 240 mg/dL, verifica si hay cetonas en orina.\n4. Consulte a su médico.';

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(titulo, style: TextStyle(color: estado == 'Hipoglucemia' ? const Color(0xFFD32F2F) : const Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 16)),
            content: Text(texto, style: const TextStyle(fontSize: 14, height: 1.4)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
              )
            ],
          );
        }
    );
  }

  void _mostrarDetallesPunto(Map<String, dynamic> registro) {
    String estado = _obtenerEstadoGlucosa(registro['valor']);
    Color colorEstado = _obtenerColorEstado(estado);
    DateTime fechaObj = registro['fecha'] is DateTime ? registro['fecha'] : DateTime.parse(registro['fecha'].toString());
    String fecha = DateFormat("EEEE, d 'de' MMMM yyyy", 'es_ES').format(fechaObj);
    String hora = DateFormat("HH:mm a", 'es_ES').format(fechaObj);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Detalle de Lectura', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 20)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: colorEstado),
                    ),
                    child: Text(estado, style: TextStyle(color: colorEstado, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${registro['valor']}', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 48, color: colorEstado, height: 1.0)),
                  const SizedBox(width: 5),
                  const Text('mg/dL', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fecha', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(fecha[0].toUpperCase() + fecha.substring(1), style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF1C63BB), size: 20),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(hora, style: const TextStyle(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              if (registro['notas'] != null && registro['notas'].toString().isNotEmpty) ...[
                const Divider(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, color: Color(0xFF1C63BB), size: 20),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Notas del paciente', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(registro['notas'], style: const TextStyle(fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              if (estado == 'Hipoglucemia' || estado == 'Hiperglucemia') ...[
                const SizedBox(height: 20),
                _construirMedidaCorrectivaADA(estado),
              ],

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).whenComplete(() {
      setState(() {
        _indiceSeleccionadoGrafica = null;
      });
    });
  }

  Widget _construirMedidaCorrectivaADA(String estado) {
    if (estado != 'Hipoglucemia' && estado != 'Hiperglucemia') return const SizedBox.shrink();

    Color color = estado == 'Hipoglucemia' ? const Color(0xFFD32F2F) : const Color(0xFFE65100);
    String titulo = estado == 'Hipoglucemia' ? '⚠️ Medida Correctiva (ADA): Hipoglucemia' : '⚠️ Medida Correctiva (ADA): Hiperglucemia';
    String texto = estado == 'Hipoglucemia'
        ? 'Aplica la regla 15-15:\n\n1. Dale 15g de carbohidratos de acción rápida (ej. ½ vaso de jugo, 1 cda. de miel).\n2. Espera 15 min y vuelve a medir su glucosa.\n3. Si sigue menor a 70 mg/dL, repite.\n4. Al normalizarse, dale un snack o comida.'
        : 'Sigue estas recomendaciones:\n\n1. Dale abundante agua.\n2. Aplica su dosis de corrección de insulina según lo indicado por el médico.\n3. Si la glucosa es mayor a 240 mg/dL, verifica si hay cetonas en orina.\n4. Consulte a su médico.';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 8),
          Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.4)),
          const SizedBox(height: 12),
          const Text('Fuente: American Diabetes Association (ADA)', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)));

    final ultimaG = _obtenerUltimaGlucosa();
    final estadoG = _obtenerEstadoGlucosa(ultimaG);
    List<Map<String, dynamic>> registrosGrafica = _registrosGlucosa.reversed.toList();

    Color colorFondo;
    Color colorTexto = Colors.white;
    Color colorBorde;

    if (estadoG == 'Hipoglucemia' || estadoG == 'Hiperglucemia') {
      colorFondo = const Color(0xFFFFEBEE);
      colorTexto = const Color(0xFFD32F2F);
      colorBorde = const Color(0xFFD32F2F);
    } else if (estadoG == 'Bajo' || estadoG == 'Elevado') {
      colorFondo = const Color(0xFFFFF3E0);
      colorTexto = const Color(0xFFE65100);
      colorBorde = const Color(0xFFE65100);
    } else {
      colorFondo = const Color(0xFFE8F5E9);
      colorTexto = const Color(0xFF2E7D32);
      colorBorde = const Color(0xFF2E7D32);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirHeaderFamiliar(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta Última Lectura
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD2D2D2), width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Última Lectura',
                            style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF3F3F3F)),
                          ),
                          GestureDetector(
                            onTap: () => widget.onCambiarTab(3),
                            child: Row(
                              children: const [
                                Text('Ver historial', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold, fontSize: 13)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, color: Color(0xFF1C63BB), size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _registrosGlucosa.isEmpty ? '--' : ultimaG.toString(),
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 52, height: 1.0, color: Color(0xFF01689C)),
                          ),
                          const SizedBox(width: 6),
                          const Text('mg/dL', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 20, color: Color(0xFF848282))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_registrosGlucosa.isNotEmpty)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: colorFondo, border: Border.all(color: colorBorde, width: 1.5), borderRadius: BorderRadius.circular(20)),
                              child: Text(estadoG, style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: colorTexto)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFF888888), width: 1.5), borderRadius: BorderRadius.circular(20)),
                              child: Text(_obtenerMomentoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF888888))),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Text(_obtenerTiempoUltimaLectura(), style: const TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFFC5C5C5))),
                    ],
                  ),
                ),

                _construirLeyendaColores(),
                const SizedBox(height: 10),
                const Text('Evolución de Glucosa', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3F3F3F))),
                const SizedBox(height: 10),
                GraficaGlucosaUniversal(
                  registros: registrosGrafica,
                  limiteHipo: limiteHipo,
                  limiteHiper: limiteHiper,
                  rangoMin: rangoMin,
                  rangoMax: rangoMax,
                  indiceSeleccionado: _indiceSeleccionadoGrafica,
                  onTapPunto: (index) {
                    setState(() { _indiceSeleccionadoGrafica = index; });
                    int indiceReal = (registrosGrafica.length - 1) - index;
                    _mostrarDetallesPunto(_registrosGlucosa[indiceReal]);
                  },
                ),
                const SizedBox(height: 20),

                TarjetasTirPromedio(
                  porcentajeTir: _calcularTIR(),
                  promedio: _calcularPromedioGlucosa(),
                  tieneRegistros: _registrosGlucosa.isNotEmpty,
                  onVerTir: _mostrarDialogoTIR,
                ),
                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD2D2D2), width: 1.5), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Acciones Rápidas', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 24, color: Color(0xFF2F2F2F))),
                      const SizedBox(height: 15),
                      const Divider(color: Color(0xFFE8E8E8), thickness: 1.5, height: 1),
                      _crearAccionRapida(Icons.edit_document, 'Registrar Lectura de Glucosa', _mostrarModalRegistro),
                      _crearAccionRapida(Icons.medication, 'Registrar Medicamento', () => widget.onCambiarTab(2)),
                      _crearAccionRapida(Icons.calculate, 'Calcular Dosis de Insulina', () => widget.onCambiarTab(1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirHeaderFamiliar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 15, right: 20, bottom: 25),
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
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Perfil de ${widget.paciente['nombre']}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edad: ${widget.paciente['edad']} años | Estatura: ${widget.paciente['altura']} cm | Peso: ${widget.paciente['peso']} kg',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D1FF).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF00D1FF).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite, color: Color(0xFF00D1FF), size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Parentesco: ${widget.paciente['parentesco']}',
                        style: const TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirLeyendaColores() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _itemLeyenda(const Color(0xFFD32F2F), 'Hipo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Bajo'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFF2E7D32), 'Normal'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFE65100), 'Elevado'), const SizedBox(width: 15),
            _itemLeyenda(const Color(0xFFD32F2F), 'Hiper'),
          ],
        ),
      ),
    );
  }

  Widget _itemLeyenda(Color color, String texto) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _crearAccionRapida(IconData icono, String texto, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Row(
          children: [
            Icon(icono, color: const Color(0xFF1C63BB), size: 26),
            const SizedBox(width: 15),
            Expanded(child: Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF2F2F2F)))),
          ],
        ),
      ),
    );
  }

  void _mostrarModalRegistro() {
    final TextEditingController valorCtrl = TextEditingController();
    final TextEditingController notasCtrl = TextEditingController();
    String momentoSeleccionado = 'Antes de comer';

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setStateSheet) {
                return Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 20, right: 20, top: 20,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                        const SizedBox(height: 20),
                        Text('Niveles de ${widget.paciente['nombre']}', style: const TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, fontSize: 22)),
                        const SizedBox(height: 25),

                        const Align(alignment: Alignment.centerLeft, child: Text('Nivel de Glucosa (mg/dL) *', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: valorCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            hintText: 'ej. 120',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(alignment: Alignment.centerLeft, child: Text('Periodo:', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: momentoSeleccionado,
                              isExpanded: true,
                              items: ['Ayunas', 'Antes de comer', 'Después de comer', 'Antes de dormir', 'Madrugada', 'Otro']
                                  .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (val) => setStateSheet(() => momentoSeleccionado = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Align(alignment: Alignment.centerLeft, child: Text('Notas: (opcional)', style: TextStyle(fontWeight: FontWeight.w600))),
                        const SizedBox(height: 5),
                        TextField(
                          controller: notasCtrl,
                          decoration: InputDecoration(
                            hintText: 'Ej. Se siente mareado...',
                            hintStyle: const TextStyle(fontSize: 13),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (valorCtrl.text.isNotEmpty) {
                                int valor = int.tryParse(valorCtrl.text) ?? 0;

                                if (valor < 20 || valor > 600) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Por favor, ingresa un valor de glucosa realista (20 - 600 mg/dL)', style: TextStyle(fontWeight: FontWeight.bold)),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      )
                                  );
                                  return;
                                }

                                if (valor > 0) {
                                  final notaFinal = notasCtrl.text;
                                  await GestorCuidadores().insertarRegistroGlucosaCuidador({
                                    'paciente_cuidador_id': widget.paciente['id'],
                                    'valor': valor,
                                    'momento': momentoSeleccionado,
                                    'notas': notaFinal,
                                    'fecha': DateTime.now().toIso8601String(),
                                  });

                                  await _cargarRegistros();

                                  if (mounted) {
                                    Navigator.pop(context);
                                    String estadoNuevo = _obtenerEstadoGlucosa(valor);
                                    if (estadoNuevo == 'Hipoglucemia' || estadoNuevo == 'Hiperglucemia') {
                                      _mostrarDialogoProtocoloADA(estadoNuevo);
                                    }
                                  }
                                }
                              }
                            },
                            icon: const Icon(Icons.save_alt, color: Colors.white),
                            label: const Text('Guardar Nueva Lectura', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C80EB),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              }
          );
        }
    );
  }

  void _mostrarDialogoTIR() {
    mostrarDialogoTIRUniversal(
      context,
      registros: _registrosGlucosa,
      limiteHipo: limiteHipo,
      limiteHiper: limiteHiper,
      rangoMin: rangoMin,
      rangoMax: rangoMax,
    );
  }
}
