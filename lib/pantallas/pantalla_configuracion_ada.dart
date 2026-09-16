import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/eventos_clinicos.dart';
import '../dominio/referencias_ada.dart';
import '../modelos/paciente_clinico.dart';

class PantallaConfiguracionAda extends StatefulWidget {
  final PacienteClinico paciente;
  const PantallaConfiguracionAda({super.key, required this.paciente});
  @override
  State<PantallaConfiguracionAda> createState() =>
      _PantallaConfiguracionAdaState();
}

class _PantallaConfiguracionAdaState extends State<PantallaConfiguracionAda> {
  final _ric = TextEditingController(),
      _fsi = TextEditingController(),
      _objetivo = TextEditingController();
  ContextoReferencia? _contexto;
  bool _guardando = false;
  String? _mensaje;
  String _id = EventosClinicos.nuevoId();
  DateTime _fecha = DateTime.now();
  List<Map<String, Object?>> _solicitudes = [];
  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _ric.dispose();
    _fsi.dispose();
    _objetivo.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final filas = await (await DatabaseHelper().eventos)
          .solicitudesConfiguracion(widget.paciente);
      if (mounted) setState(() => _solicitudes = filas);
    } catch (_) {
      if (mounted) {
        setState(
          () => _mensaje = 'No se pudo cargar el historial de solicitudes.',
        );
      }
    }
  }

  double? _numero(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    final valor = double.tryParse(c.text.trim().replaceAll(',', '.'));
    if (valor == null || !valor.isFinite || valor <= 0) {
      throw const FormatException();
    }
    return valor;
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    if (_contexto == null) {
      setState(() => _mensaje = 'Selecciona el contexto antes de guardar.');
      return;
    }
    double? ric, fsi, objetivo;
    try {
      ric = _numero(_ric);
      fsi = _numero(_fsi);
      objetivo = _numero(_objetivo);
    } on FormatException {
      setState(
        () => _mensaje =
            'Usa valores positivos o deja vacío lo que no esté prescrito.',
      );
      return;
    }
    setState(() {
      _guardando = true;
      _mensaje = null;
    });
    try {
      await (await DatabaseHelper().eventos).guardarSolicitudConfiguracion(
        id: _id,
        paciente: widget.paciente,
        contexto: _contexto!,
        fecha: _fecha,
        ric: ric,
        fsi: fsi,
        objetivo: objetivo,
      );
      if (!mounted) return;
      setState(() {
        _mensaje =
            'Solicitud guardada localmente para revisión. No autoriza cálculos ni se envía automáticamente a un médico.';
        _id = EventosClinicos.nuevoId();
        _fecha = DateTime.now();
        _ric.clear();
        _fsi.clear();
        _objetivo.clear();
        _contexto = null;
      });
      await _cargar();
    } catch (_) {
      if (mounted) {
        setState(
          () => _mensaje =
              'No se pudo guardar la solicitud. Revisa la sesión e intenta de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final institucional =
        widget.paciente.ambito == AmbitoPaciente.institucional;
    final opciones = [
      if (institucional)
        ContextoReferencia.hospitalNoCritico
      else
        ContextoReferencia.adultoAmbulatorio,
      ContextoReferencia.individualizar,
    ];
    final referencia = _contexto == null
        ? null
        : ReferenciasAda.para(_contexto!);
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar con referencias ADA 2026')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Metas de referencia y parámetros prescritos',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Selecciona el contexto. Las metas de una guía no sustituyen la pauta individual ni definen por sí solas una dosis.',
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ContextoReferencia>(
            key: ValueKey(_id),
            initialValue: _contexto,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Contexto clínico'),
            items: opciones
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(ReferenciasAda.para(c).nombre),
                  ),
                )
                .toList(),
            onChanged: _guardando ? null : (c) => setState(() => _contexto = c),
          ),
          if (referencia != null) ...[
            const SizedBox(height: 16),
            Text(referencia.descripcion),
            const SizedBox(height: 8),
            Text(referencia.alcance),
            const SizedBox(height: 8),
            SelectableText('Fuente ADA 2026: ${referencia.fuente}'),
          ],
          const SizedBox(height: 20),
          const Text(
            'Hipoglucemia: nivel 1 entre 54 y menos de 70 mg/dL; nivel 2 por debajo de 54 mg/dL. El nivel 3 depende de necesitar ayuda y no se determina solo por una cifra.',
          ),
          const SelectableText('Fuente: https://doi.org/10.2337/dc26-S006'),
          const SizedBox(height: 20),
          const Text(
            'Parámetros de una pauta existente (opcionales). Déjalos vacíos si no los tienes; no se calculan a partir de la meta ADA.',
          ),
          for (final campo in [
            (_ric, 'I:C prescrito (g/UI)'),
            (_fsi, 'FSI prescrito (mg/dL/UI)'),
            (_objetivo, 'Objetivo de corrección prescrito (mg/dL)'),
          ])
            TextField(
              key: ValueKey(campo.$2),
              controller: campo.$1,
              enabled: !_guardando,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: campo.$2),
            ),
          const SizedBox(height: 16),
          const Text(
            'Insulina activa, ejercicio, incremento del dispositivo y redondeo requieren reglas individualizadas. No se asignan descuentos ni valores automáticos.',
          ),
          const SelectableText(
            'Referencias: https://doi.org/10.2337/dc26-S009 y https://doi.org/10.2337/dc26-S005',
          ),
          const SizedBox(height: 16),
          if (_mensaje != null)
            Text(_mensaje!, key: const ValueKey('estado_solicitud')),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            child: Text(_guardando ? 'Guardando…' : 'Guardar para revisión'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Solicitudes pendientes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (_solicitudes.isEmpty) const Text('No hay solicitudes guardadas.'),
          for (final s in _solicitudes)
            ListTile(
              title: Text(
                ReferenciasAda.para(
                  ContextoReferencia.values.byName(s['contexto'] as String),
                ).nombre,
              ),
              subtitle: Text(
                '${s['fecha']} · Pendiente de revisión\n${_resumen(s)}',
              ),
            ),
        ],
      ),
    );
  }

  String _resumen(Map<String, Object?> s) {
    final p =
        jsonDecode(s['parametros_propuestos_json'] as String)
            as Map<String, dynamic>;
    return 'I:C: ${p['ric'] ?? 'pendiente'} · FSI: ${p['fsi'] ?? 'pendiente'} · Objetivo: ${p['objetivo'] ?? 'pendiente'}';
  }
}
