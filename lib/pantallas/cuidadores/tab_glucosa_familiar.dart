import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class TabGlucosaFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const TabGlucosaFamiliar({super.key, required this.paciente});

  @override
  State<TabGlucosaFamiliar> createState() => _TabGlucosaFamiliarState();
}

class _TabGlucosaFamiliarState extends State<TabGlucosaFamiliar> {
  final TextEditingController _glucosaCtrl = TextEditingController();
  final TextEditingController _notasCtrl = TextEditingController();
  String _momentoSeleccionado = 'Ayunas';
  List<Map<String, dynamic>> _ultimosRegistros = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final db = DatabaseHelper();
    final data = await db.obtenerRegistrosGlucosaCuidador(widget.paciente['id']);
    setState(() {
      _ultimosRegistros = data;
      _cargando = false;
    });
  }

  void _guardarGlucosa() async {
    if (_glucosaCtrl.text.isEmpty) return;

    final db = DatabaseHelper();
    await db.insertarRegistroGlucosaCuidador({
      'paciente_cuidador_id': widget.paciente['id'],
      'valor': double.parse(_glucosaCtrl.text),
      'momento': _momentoSeleccionado,
      'notas': _notasCtrl.text,
      'fecha': DateTime.now().toString(),
    });

    _glucosaCtrl.clear();
    _notasCtrl.clear();
    if (!mounted) return;
    Navigator.pop(context);
    _cargarRegistros();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirResumen(),
          const SizedBox(height: 25),
          const Text('Acciones Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),

          _botonAgregarGlucosa(),

          const SizedBox(height: 25),
          const Text('Últimas lecturas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          _construirListaLecturas(),
        ],
      ),
    );
  }

  Widget _construirResumen() {
    double promedio = 0;
    String ultima = '--';
    if (_ultimosRegistros.isNotEmpty) {
      ultima = _ultimosRegistros.first['valor'].toString();
      promedio = _ultimosRegistros.map((e) => e['valor'] as double).reduce((a, b) => a + b) / _ultimosRegistros.length;
    }

    return Row(
      children: [
        Expanded(child: _tarjetaInfo('Última', ultima, 'mg/dL', Icons.timer_outlined, const Color(0xFF1C63BB))),
        const SizedBox(width: 15),
        Expanded(child: _tarjetaInfo('Promedio', promedio > 0 ? promedio.toStringAsFixed(0) : '--', 'mg/dL', Icons.analytics_outlined, const Color(0xFF4CAF50))),
      ],
    );
  }

  Widget _tarjetaInfo(String titulo, String valor, String unidad, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          const SizedBox(height: 10),
          Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(valor, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(width: 4),
              Text(unidad, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _botonAgregarGlucosa() {
    return InkWell(
      onTap: _mostrarModalRegistro,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C63BB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: const [
            Icon(Icons.add_circle_outline, color: Colors.white),
            SizedBox(width: 15),
            Text('Registrar azúcar de hoy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  void _mostrarModalRegistro() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: MediaQuery.of(context).viewInsets.bottom + 25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nuevo Registro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Registra los niveles de ${widget.paciente['nombre']}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            TextField(
              controller: _glucosaCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Valor (mg/dL)',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            _crearSelectorMomento(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardarGlucosa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C63BB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Guardar Registro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _crearSelectorMomento() {
    final momentos = ['Ayunas', 'Antes de comer', 'Después de comer', 'Antes de dormir'];
    return Wrap(
      spacing: 10,
      children: momentos.map((m) => ChoiceChip(
        label: Text(m),
        selected: _momentoSeleccionado == m,
        onSelected: (val) => setState(() => _momentoSeleccionado = m),
        selectedColor: const Color(0xFF00D1FF).withOpacity(0.3),
      )).toList(),
    );
  }

  Widget _construirListaLecturas() {
    if (_ultimosRegistros.isEmpty) return const Text('Sin registros aún.', style: TextStyle(color: Colors.grey));

    return Column(
      children: _ultimosRegistros.take(3).map((r) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
              child: Text(r['valor'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1C63BB))),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['momento'], style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(r['fecha'].toString().substring(0, 16), style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            )
          ],
        ),
      )).toList(),
    );
  }
}