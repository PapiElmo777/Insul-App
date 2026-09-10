import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/eventos_clinicos.dart';
import '../modelos/paciente_clinico.dart';

/// Registra un hecho declarado por la persona; no recomienda una dosis.
Future<bool> mostrarRegistroAdministracion(
  BuildContext context,
  PacienteClinico paciente,
) async =>
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoAdministracion(paciente: paciente),
    ) ??
    false;

class _DialogoAdministracion extends StatefulWidget {
  final PacienteClinico paciente;
  const _DialogoAdministracion({required this.paciente});
  @override
  State<_DialogoAdministracion> createState() => _DialogoAdministracionState();
}

class _DialogoAdministracionState extends State<_DialogoAdministracion> {
  final _dosis = TextEditingController();
  final _insulina = TextEditingController();
  final _notas = TextEditingController();
  final _id = EventosClinicos.nuevoId();
  final _fecha = DateTime.now();
  String _momento = 'Otro';
  bool _confirmada = false, _guardando = false;
  String? _error;

  @override
  void dispose() {
    _dosis.dispose();
    _insulina.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final dosis = double.tryParse(_dosis.text.replaceAll(',', '.'));
    if (!_confirmada ||
        dosis == null ||
        !dosis.isFinite ||
        dosis <= 0 ||
        _insulina.text.trim().isEmpty) {
      setState(
        () => _error =
            'Indica la insulina y las unidades aplicadas, y confirma la administración.',
      );
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await (await DatabaseHelper().eventos).confirmarAdministracion(
        id: _id,
        paciente: widget.paciente,
        confirmada: _confirmada,
        medicamento: _insulina.text,
        dosisTexto: '$dosis UI',
        cantidad: dosis,
        unidad: 'UI',
        fecha: _fecha,
        momento: _momento,
        notas: _notas.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _error = 'No se pudo guardar. Revisa la sesión e intenta de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_guardando,
    child: AlertDialog(
      title: const Text('Registrar administración de insulina'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Registra únicamente la insulina que ya se aplicó. Guardar un cálculo no confirma una aplicación.',
            ),
            TextField(
              key: const ValueKey('insulina_aplicada'),
              controller: _insulina,
              enabled: !_guardando,
              decoration: const InputDecoration(
                labelText: 'Insulina utilizada',
              ),
            ),
            TextField(
              key: const ValueKey('unidades_aplicadas'),
              controller: _dosis,
              enabled: !_guardando,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Unidades aplicadas (UI)',
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: _momento,
              items: [
                'Desayuno',
                'Almuerzo',
                'Cena',
                'Merienda',
                'Madrugada',
                'Otro',
              ].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: _guardando
                  ? null
                  : (m) => setState(() => _momento = m!),
              decoration: const InputDecoration(labelText: 'Momento'),
            ),
            TextField(
              controller: _notas,
              enabled: !_guardando,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _confirmada,
              onChanged: _guardando
                  ? null
                  : (v) => setState(() => _confirmada = v ?? false),
              title: const Text('Confirmo que esta dosis ya fue administrada'),
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: Text(_guardando ? 'Guardando…' : 'Guardar administración'),
        ),
      ],
    ),
  );
}
