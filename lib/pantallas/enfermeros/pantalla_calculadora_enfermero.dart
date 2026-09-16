import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/database_helper.dart';
import '../../database/eventos_clinicos.dart';
import '../../modelos/parametros_dosis.dart';
import '../../dominio/motor_dosis.dart';
import '../pantalla_configuracion_ada.dart';
import '../../modelos/paciente_clinico.dart';

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
  late TextEditingController _glucosaCtrl;
  late TextEditingController _carbosCtrl;
  late TextEditingController _metaCtrl;
  late TextEditingController _fsiCtrl;
  late TextEditingController _ricCtrl;

  double _dosisCorreccion = 0.0;
  double _dosisComida = 0.0;
  double _dosisTotal = 0.0;
  bool _guardando = false;
  ParametrosDosis? _parametros;
  String _estadoConfiguracion = MotorDosis.faltaConfiguracion;
  String? _calculoId;
  DateTime? _fechaCalculo;
  Map<String, Object?> _detalle = {};

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
  void initState() {
    super.initState();
    _glucosaCtrl = TextEditingController();
    _carbosCtrl = TextEditingController();
    _metaCtrl = TextEditingController();
    _fsiCtrl = TextEditingController();
    _ricCtrl = TextEditingController();
    _cargarParametros();
  }

  Future<void> _cargarParametros() async {
    try {
      final p = await (await DatabaseHelper().eventos).parametrosVigentes(
        PacienteClinico(AmbitoPaciente.institucional, widget.paciente['id']));
      if (!mounted) return;
      setState(() {
        _parametros = p; _calculoId = null;
        _metaCtrl.text = p?.objetivo.toString() ?? '';
        _fsiCtrl.text = p?.fsi.toString() ?? '';
        _ricCtrl.text = p?.ric.toString() ?? '';
        _estadoConfiguracion = p == null ? MotorDosis.faltaConfiguracion : 'Configuración autorizada · versión ${p.version}';
      });
    } catch (_) {
      if (mounted) setState(() { _parametros = null; _calculoId = null; _estadoConfiguracion = 'No se pudo verificar la configuración clínica. Reintenta la carga.'; });
    }
  }

  @override
  void dispose() {
    _glucosaCtrl.dispose();
    _carbosCtrl.dispose();
    _metaCtrl.dispose();
    _fsiCtrl.dispose();
    _ricCtrl.dispose();
    super.dispose();
  }

  Future<void> _calcularDosis() async {
    final entradas = (_glucosaCtrl.text, _carbosCtrl.text);
    setState(() => _calculoId = null);
    try {
      final vigente = await (await DatabaseHelper().eventos).parametrosVigentes(
        PacienteClinico(AmbitoPaciente.institucional, widget.paciente['id']));
      if (!mounted || entradas != (_glucosaCtrl.text, _carbosCtrl.text)) return;
      if (vigente == null) throw const CalculoNoDisponible(MotorDosis.faltaConfiguracion);
      if (vigente.id != _parametros?.id) throw const CalculoNoDisponible('La configuración cambió. Recarga los parámetros antes de calcular.');
      final glucosa = double.tryParse(_glucosaCtrl.text);
      final carbos = double.tryParse(_carbosCtrl.text);
      final r = MotorDosis.calcular(parametros: _parametros, glucosa: glucosa,
        carbohidratos: carbos, actividad: 'Sedentario', ahora: DateTime.now());
      setState(() {
        _dosisCorreccion = r.correccion; _dosisComida = r.comida; _dosisTotal = r.dosis;
        _calculoId = EventosClinicos.nuevoId(); _fechaCalculo = DateTime.now();
        _detalle = {'glucosa': glucosa, 'carbohidratos': carbos, 'actividad': 'Sedentario'};
        _estadoConfiguracion = 'Configuración autorizada · versión ${_parametros!.version}';
      });
    } on CalculoNoDisponible catch (e) {
      if (mounted) setState(() { _calculoId = null; _estadoConfiguracion = e.mensaje; });
    } catch (_) {
      if (mounted) setState(() { _calculoId = null; _estadoConfiguracion = 'No se pudo verificar la configuración clínica. Reintenta la carga.'; });
    }
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
    if (_guardando || _calculoId == null) return;
    double glucosa = double.tryParse(_glucosaCtrl.text) ?? 0.0;
    final unidades = _dosisTotal;
    final id = _calculoId!;
    final parametrosId = _parametros!.id;
    final detalle = Map<String, Object?>.from(_detalle);
    final fecha = _fechaCalculo!;
    setState(() => _guardando = true);
    try {
      await (await DatabaseHelper().eventos).guardarCalculo(
        id: id, parametrosId: parametrosId, paciente: PacienteClinico(AmbitoPaciente.institucional, widget.paciente['id']),
        glucosa: glucosa, dosis: unidades, entradas: detalle, momento: 'Hospital', fecha: fecha,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cálculo guardado. No registra una administración.')));
      if (_calculoId == id) Navigator.pop(context, true);
    } on CalculoNoDisponible catch (e) {
      if (mounted) setState(() { _calculoId = null; _estadoConfiguracion = e.mensaje; });
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo guardar el cálculo. Intenta de nuevo.')));
    } finally {
      if (mounted) setState(() => _guardando = false);
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

            Text(_estadoConfiguracion),
            TextButton.icon(onPressed: _cargarParametros, icon: const Icon(Icons.refresh), label: const Text('Recargar parámetros')),
            TextButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaConfiguracionAda(paciente: PacienteClinico(AmbitoPaciente.institucional, widget.paciente['id'])))), icon: const Icon(Icons.settings), label: const Text('Configurar con referencias ADA 2026')),
            // Parametros Clinicos
            const Text('Parámetros clínicos autorizados', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            if (_calculoId != null) Container(
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
                      Text('${_dosisTotal.toStringAsFixed(1)} UI', style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 26, fontWeight: FontWeight.bold)),
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
                onPressed: _guardando || _calculoId == null ? null : _guardarRegistro,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text('Guardar cálculo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
      readOnly: true,
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