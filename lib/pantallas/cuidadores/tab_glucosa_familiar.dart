import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/database_helper.dart';

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

  final int limiteHipo = 70;
  final int limiteHiper = 180;
  final int rangoMin = 80;
  final int rangoMax = 130;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    try {
      final db = DatabaseHelper();
      final data = await db.obtenerRegistrosGlucosaCuidador(widget.paciente['id']);
      if (mounted) {
        setState(() {
          _registrosGlucosa = data;
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
    final fechaStr = _registrosGlucosa.first['fecha'].toString();
    try {
      final fecha = DateTime.parse(fechaStr);
      return DateFormat("d/M/yyyy 'a las' HH:mm", 'es_ES').format(fecha);
    } catch (e) {
      return fechaStr.substring(0, 16);
    }
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

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator(color: Color(0xFF1C63BB)));

    final ultimaG = _obtenerUltimaGlucosa();
    final estadoG = _obtenerEstadoGlucosa(ultimaG);

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
                // Ultima Lectura
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
                          Icon(Icons.show_chart_rounded, color: Colors.grey.shade500, size: 24),
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
                const SizedBox(height: 5),

                // TIR y Promedio
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD2D2D2), width: 2), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            const Text('Tiempo en nivel normal (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F)), textAlign: TextAlign.center,),
                            const SizedBox(height: 2),
                            Text(
                              _registrosGlucosa.isEmpty ? '--%' : '${_calcularTIR()}%',
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                            ),
                            GestureDetector(
                              onTap: _registrosGlucosa.isEmpty ? null : _mostrarDialogoTIR,
                              child: Text(
                                'Ver mas',
                                style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: _registrosGlucosa.isEmpty ? Colors.transparent : const Color(0xFF888888), decoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFD2D2D2), width: 2), borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            const Text('Promedio\n', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF2F2F2F)), textAlign: TextAlign.center),
                            const SizedBox(height: 2),
                            Text(
                              _registrosGlucosa.isEmpty ? '--' : _calcularPromedioGlucosa().toString(),
                              style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 38, height: 1.2, color: Color(0xFF01689C)),
                            ),
                            const Text('Histórico total', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF888888))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Acciones Rapidas
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
                                if (valor > 0) {
                                  final db = DatabaseHelper();
                                  await db.insertarRegistroGlucosaCuidador({
                                    'paciente_cuidador_id': widget.paciente['id'],
                                    'valor': valor,
                                    'momento': momentoSeleccionado,
                                    'notas': notasCtrl.text,
                                    'fecha': DateTime.now().toString(),
                                  });

                                  _cargarRegistros();

                                  if (mounted) {
                                    Navigator.pop(context);
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
    int total = _registrosGlucosa.length;
    int cHipo = 0, cBajo = 0, cNormal = 0, cElevado = 0, cHiper = 0;

    if (total > 0) {
      for (var r in _registrosGlucosa) {
        int val = (r['valor'] as num).toInt();
        if (val < limiteHipo) cHipo++;
        else if (val < rangoMin) cBajo++;
        else if (val <= rangoMax) cNormal++;
        else if (val <= limiteHiper) cElevado++;
        else cHiper++;
      }
    }

    int pctHipo = total > 0 ? ((cHipo / total) * 100).round() : 0;
    int pctBajo = total > 0 ? ((cBajo / total) * 100).round() : 0;
    int pctNormal = total > 0 ? ((cNormal / total) * 100).round() : 0;
    int pctElevado = total > 0 ? ((cElevado / total) * 100).round() : 0;
    int pctHiper = total > 0 ? ((cHiper / total) * 100).round() : 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiempo en Rango (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F2F2F))),
                    IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('El TIR es el porcentaje del tiempo que la glucosa de ${widget.paciente['nombre']} está en cada nivel.', style: const TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 25),
                SizedBox(
                  height: 320,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Padding(padding: const EdgeInsets.only(top: 8), child: _etiquetaTir('Hiperglucemia', '$pctHiper%', const Color(0xFFD32F2F))),
                            _etiquetaTir('Elevado', '$pctElevado%', const Color(0xFFE65100)),
                            _etiquetaTir('En Rango', '$pctNormal%', const Color(0xFF2E7D32), esMeta: true),
                            _etiquetaTir('Bajo', '$pctBajo%', const Color(0xFFE65100)),
                            Padding(padding: const EdgeInsets.only(bottom: 8), child: _etiquetaTir('Hipoglucemia', '$pctHipo%', const Color(0xFFD32F2F))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      ClipPath(
                        clipper: _DropClipper(),
                        child: Container(
                          width: 145, height: 320, color: Colors.white,
                          child: Column(
                            children: [
                              Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.bottomCenter, padding: const EdgeInsets.only(bottom: 2), child: Text('>$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('${rangoMax + 1}-$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 110, width: double.infinity, color: const Color(0xFF2E7D32), alignment: Alignment.center, child: Text('Objetivo\n$rangoMin-$rangoMax\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white, height: 1.2))),
                              Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('$limiteHipo-${rangoMin - 1}\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                              Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('<$limiteHipo mg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _etiquetaTir(String titulo, String porcentaje, Color color, {bool esMeta = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(porcentaje, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
        if (esMeta)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('META', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 9),
              ],
            ),
          ),
      ],
    );
  }
}

class _DropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    double r = w / 2;
    double cy = h - r;
    path.moveTo(w / 2, 0);
    path.quadraticBezierTo(w, cy - (r * 1.2), w, cy);
    path.arcToPoint(Offset(0, cy), radius: Radius.circular(r), clockwise: true);
    path.quadraticBezierTo(0, cy - (r * 1.2), w / 2, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}