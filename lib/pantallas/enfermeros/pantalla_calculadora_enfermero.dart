import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/database_helper.dart';

class PantallaCalculadoraEnfermero extends StatefulWidget {
  final Map<String, dynamic> paciente;

  const PantallaCalculadoraEnfermero({
    super.key,
    required this.paciente,
  });

  @override
  State<PantallaCalculadoraEnfermero> createState() => _PantallaCalculadoraEnfermeroState();
}

class _PantallaCalculadoraEnfermeroState extends State<PantallaCalculadoraEnfermero> {
  final TextEditingController _glucosaCtrl = TextEditingController();
  final TextEditingController _carbosCtrl = TextEditingController();
  final TextEditingController _metaCtrl = TextEditingController(text: '100');
  final TextEditingController _fsiCtrl = TextEditingController(text: '50');
  final TextEditingController _ricCtrl = TextEditingController(text: '15');

  double _dosisCorreccion = 0.0;
  double _dosisComida = 0.0;
  double _dosisTotal = 0.0;

  final List<Map<String, dynamic>> _alimentosHospital = [
    {'nombre': 'Gelatina regular (120g)', 'carbos': 17.0},
    {'nombre': 'Jugo de Manzana (200ml)', 'carbos': 24.0},
    {'nombre': 'Pan Tostado (1 rebanada)', 'carbos': 12.0},
    {'nombre': 'Arroz Blanco Cocido (1/2 taza)', 'carbos': 22.0},
    {'nombre': 'Puré de Papa (1/2 taza)', 'carbos': 15.0},
    {'nombre': 'Manzana Cocida (1 pieza)', 'carbos': 19.0},
    {'nombre': 'Galletas Marías (5 piezas)', 'carbos': 21.0},
    {'nombre': 'Sopa de Pasta (1 taza)', 'carbos': 25.0},
    {'nombre': 'Leche Entera (240ml)', 'carbos': 12.0},
    {'nombre': 'Avena Cocida (1/2 taza)', 'carbos': 14.0},
  ];

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _carbosCtrl.dispose();
    _metaCtrl.dispose();
    _fsiCtrl.dispose();
    _ricCtrl.dispose();
    super.dispose();
  }

  void _calcularDosis() {
    double glucosa = double.tryParse(_glucosaCtrl.text) ?? 0.0;
    double carbos = double.tryParse(_carbosCtrl.text) ?? 0.0;
    double meta = double.tryParse(_metaCtrl.text) ?? 100.0;
    double fsi = double.tryParse(_fsiCtrl.text) ?? 50.0;
    double ric = double.tryParse(_ricCtrl.text) ?? 15.0;

    if (fsi <= 0) fsi = 1;
    if (ric <= 0) ric = 1;

    double correccion = 0.0;
    if (glucosa > meta) {
      correccion = (glucosa - meta) / fsi;
    }

    double comida = carbos / ric;

    setState(() {
      _dosisCorreccion = correccion < 0 ? 0 : correccion;
      _dosisComida = comida < 0 ? 0 : comida;
      _dosisTotal = _dosisCorreccion + _dosisComida;
    });
  }

  void _mostrarCatalogoHospital() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catálogo de Dietas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _alimentosHospital.length,
                  itemBuilder: (context, index) {
                    final alim = _alimentosHospital[index];
                    return ListTile(
                      leading: const Icon(Icons.local_dining, color: Color(0xFFE65100)),
                      title: Text(alim['nombre'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text('${alim['carbos']}g', style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                      onTap: () {
                        double actual = double.tryParse(_carbosCtrl.text) ?? 0.0;
                        setState(() {
                          _carbosCtrl.text = (actual + alim['carbos']).toString();
                          _calcularDosis();
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _guardarRegistro() async {
    double glucosa = double.tryParse(_glucosaCtrl.text) ?? 0.0;
    int unidades = _dosisTotal.round();
    if (glucosa <= 0 || glucosa > 600) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un valor de glucosa realista (1-600 mg/dL)'), backgroundColor: Color(0xFFD32F2F)),
      );
      return;
    }

    if (unidades <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La dosis calculada es 0. No hay insulina por registrar.'), backgroundColor: Color(0xFFE65100)),
      );
      return;
    }

    final db = DatabaseHelper();
    final String fechaActual = DateTime.now().toIso8601String();

    await db.insertarGlucosaEnfermero({
      'paciente_id': widget.paciente['id'],
      'valor': glucosa.toInt(),
      'fecha': fechaActual
    });

    await db.insertarInsulinaEnfermero({
      'paciente_id': widget.paciente['id'],
      'unidades': unidades,
      'fecha': fechaActual
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado exitosamente'), backgroundColor: Color(0xFF2E7D32)),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C63BB),
        elevation: 0,
        title: const Text('Calculadora de Dosis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFE8F0FB), shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Color(0xFF1C63BB)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.paciente['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Cama: ${widget.paciente['ubicacion']} | DM ${widget.paciente['tipoDiabetes']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Parametros Clinicos
            const Text('Parámetros Médicos Indicados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _crearCampoNumerico('Meta (mg/dL)', _metaCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _crearCampoNumerico('FSI', _fsiCtrl)),
                const SizedBox(width: 10),
                Expanded(child: _crearCampoNumerico('RIC (g/UI)', _ricCtrl)),
              ],
            ),
            const SizedBox(height: 20),

            // Datos del momento
            const Text('Datos del Turno', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _crearCampoNumericoLargo('Glucosa Actual (mg/dL)', _glucosaCtrl, Icons.bloodtype, const Color(0xFFD32F2F)),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _crearCampoNumericoLargo('Carbohidratos (g)', _carbosCtrl, Icons.restaurant, const Color(0xFFE65100))),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE65100))),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFFE65100)),
                    onPressed: _mostrarCatalogoHospital,
                    tooltip: 'Catálogo de Dietas',
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            // Resultados
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0D3F7A), Color(0xFF1C63BB)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF1C63BB).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dosis Corrección:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('${_dosisCorreccion.toStringAsFixed(1)} UI', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dosis Comida:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                      Text('${_dosisComida.toStringAsFixed(1)} UI', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white30, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL SUGERIDO:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${_dosisTotal.round()} UI', style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _guardarRegistro,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Registrar en Expediente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _crearCampoNumerico(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (val) => _calcularDosis(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1C63BB))),
      ),
    );
  }

  Widget _crearCampoNumericoLargo(String hint, TextEditingController controller, IconData icono, Color colorIcono) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (val) => _calcularDosis(),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        prefixIcon: Icon(icono, color: colorIcono),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: colorIcono, width: 2)),
      ),
    );
  }
}