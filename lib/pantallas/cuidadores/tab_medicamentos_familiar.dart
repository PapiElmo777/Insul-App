import 'package:flutter/material.dart';
import '../../../database/database_helper.dart';

class TabMedicamentosFamiliar extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const TabMedicamentosFamiliar({super.key, required this.paciente});

  @override
  State<TabMedicamentosFamiliar> createState() => _TabMedicamentosFamiliarState();
}

class _TabMedicamentosFamiliarState extends State<TabMedicamentosFamiliar> {
  List<Map<String, dynamic>> _medicamentos = [];
  bool _cargando = true;

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _gramajeCtrl = TextEditingController();
  final TextEditingController _propositoCtrl = TextEditingController();
  final TextEditingController _frecuenciaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarMedicamentos();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _gramajeCtrl.dispose();
    _propositoCtrl.dispose();
    _frecuenciaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarMedicamentos() async {
    final db = DatabaseHelper();
    final data = await db.obtenerMedicamentosDePacienteCuidador(widget.paciente['id']);
    setState(() {
      _medicamentos = data;
      _cargando = false;
    });
  }

  void _guardarMedicamento() async {
    if (_nombreCtrl.text.isEmpty || _gramajeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el gramaje son obligatorios.')),
      );
      return;
    }

    final db = DatabaseHelper();
    await db.insertarOtroMedicamentoCuidador({
      'paciente_cuidador_id': widget.paciente['id'],
      'nombre': _nombreCtrl.text,
      'gramaje': _gramajeCtrl.text,
      'proposito': _propositoCtrl.text,
      'frecuencia': _frecuenciaCtrl.text,
    });

    _nombreCtrl.clear();
    _gramajeCtrl.clear();
    _propositoCtrl.clear();
    _frecuenciaCtrl.clear();

    if (!mounted) return;
    Navigator.pop(context);
    _cargarMedicamentos();
  }

  void _eliminarMedicamento(int id) async {
    final db = DatabaseHelper();
    await db.eliminarMedicamentoCuidador(id);
    _cargarMedicamentos();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _medicamentos.isEmpty
          ? _construirEstadoVacio()
          : _construirListaMedicamentos(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalAgregar,
        backgroundColor: const Color(0xFF00D1FF),
        icon: const Icon(Icons.add, color: Color(0xFF1C63BB)),
        label: const Text('Añadir Medicamento', style: TextStyle(color: Color(0xFF1C63BB), fontWeight: FontWeight.bold)),
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
            Icon(Icons.medication_liquid_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            const Text(
              'Sin medicamentos registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Añade las pastillas, suplementos o tratamientos adicionales que toma ${widget.paciente['nombre']}.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirListaMedicamentos() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 80),
      itemCount: _medicamentos.length,
      itemBuilder: (context, index) {
        final med = _medicamentos[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.medication, color: Color(0xFF1C63BB), size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${med['nombre']} ${med['gramaje']}mg',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      med['frecuencia'] ?? 'Sin frecuencia especificada',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1C63BB), fontWeight: FontWeight.w500),
                    ),
                    if (med['proposito'] != null && med['proposito'].toString().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Para: ${med['proposito']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ]
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
                onPressed: () => _eliminarMedicamento(med['id']),
                tooltip: 'Eliminar medicamento',
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarModalAgregar() {
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Añadir Medicamento', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text('Para ${widget.paciente['nombre']}', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _crearCampoTexto(titulo: 'Nombre', hint: 'Ej. Losartán', controlador: _nombreCtrl, esNumero: false),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: _crearCampoTexto(titulo: 'Gramaje', hint: 'Ej. 50', controlador: _gramajeCtrl, esNumero: true),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _crearCampoTexto(titulo: '¿Para qué es?', hint: 'Ej. Presión arterial', controlador: _propositoCtrl, esNumero: false),
              const SizedBox(height: 15),
              _crearCampoTexto(titulo: 'Frecuencia', hint: 'Ej. 1 pastilla cada 12 horas', controlador: _frecuenciaCtrl, esNumero: false),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardarMedicamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C63BB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('Guardar Medicamento', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _crearCampoTexto({required String titulo, required String hint, required TextEditingController controlador, required bool esNumero}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 5),
        TextField(
          controller: controlador,
          keyboardType: esNumero ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}