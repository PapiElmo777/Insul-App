import 'package:flutter/material.dart';
import 'package:insulapp/database/gestores/gestor_pacientes.dart';
import 'package:insulapp/database/gestores/gestor_usuarios.dart';
import 'package:insulapp/pantallas/paciente/pantalla_inicio_paciente.dart';

class ControladorRegistroPaciente extends ChangeNotifier {
  final PageController pageController = PageController();
  int pasoActual = 0;
  final int totalPasos = 6;
  bool aceptoTerminos = false;

  String? sexo;
  final TextEditingController edadCtrl = TextEditingController();
  String? tiempoDx;
  String? tipoDiabetes;
  final TextEditingController alergiasCtrl = TextEditingController();
  final TextEditingController hospitalizacionesCtrl = TextEditingController();
  final TextEditingController pesoCtrl = TextEditingController();
  final TextEditingController alturaCtrl = TextEditingController();

  final FocusNode pesoFocus = FocusNode();
  final FocusNode alturaFocus = FocusNode();

  double imc = 0.0;

  final TextEditingController hipoCtrl = TextEditingController(text: '70');
  final TextEditingController hiperCtrl = TextEditingController(text: '180');
  final TextEditingController rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController rangoMaxCtrl = TextEditingController(text: '130');
  final TextEditingController fsiCtrl = TextEditingController(text: '50');
  final TextEditingController ricCtrl = TextEditingController(text: '15');

  String? metodoInsulina;
  String? tipoInsulinaInyeccion;

  final TextEditingController insulinaBasalMarcaCtrl = TextEditingController();
  final TextEditingController insulinaBasalDosisCtrl = TextEditingController();
  final TextEditingController insulinaRapidaMarcaCtrl = TextEditingController();
  final TextEditingController insulinaRapidaPatronCtrl = TextEditingController();
  final TextEditingController bombaUnidadesCtrl = TextEditingController();
  final TextEditingController bombaFrecuenciaCtrl = TextEditingController();

  final TextEditingController medOralNombreCtrl = TextEditingController();
  final TextEditingController medOralDosisCtrl = TextEditingController();

  final TextEditingController otroMedNombreCtrl = TextEditingController();
  final TextEditingController otroMedGramajeCtrl = TextEditingController();
  final TextEditingController otroMedPropositoCtrl = TextEditingController();
  final TextEditingController otroMedFrecuenciaCtrl = TextEditingController();

  List<Map<String, String>> otrosMedicamentos = [];
  bool mostrarFormularioOtroMed = false;
  int? indiceEditando;

  String? frecuenciaMonitoreo;
  final TextEditingController otroMonitoreoCtrl = TextEditingController();

  String? actividadFisica;
  final TextEditingController emergenciaNombreCtrl = TextEditingController();
  final TextEditingController emergenciaParentescoCtrl = TextEditingController();
  final TextEditingController emergenciaTelefonoCtrl = TextEditingController();
  final TextEditingController medicoNombreCtrl = TextEditingController();

  final List<String> opcionesTiempoDx = ['Menos de 1 año', '1 a 5 años', '5 a 10 años', 'Más de 10 años'];
  final List<String> opcionesTipoDiabetes = ['Tipo 1', 'Tipo 2', 'Gestacional', 'LADA / Otro'];
  final List<String> opcionesMonitoreo = [
    'Ayunas y antes de comidas',
    'Al despertar y antes de dormir',
    'Antes y después de comer',
    'Solo si hay síntomas',
    'Monitoreo continuo (Sensor)',
    'Otro protocolo'
  ];
  final List<String> opcionesActividad = [
    'Sedentario',
    'Ligero (1-2 días/sem)',
    'Moderado (3-5 días/sem)',
    'Intenso (6-7 días/sem)',
    'Atleta de alto rendimiento'
  ];

  ControladorRegistroPaciente() {
    pesoFocus.addListener(() {
      if (!pesoFocus.hasFocus) calcularIMC();
    });
    alturaFocus.addListener(() {
      if (!alturaFocus.hasFocus) calcularIMC();
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    edadCtrl.dispose();
    alergiasCtrl.dispose();
    hospitalizacionesCtrl.dispose();
    pesoCtrl.dispose();
    alturaCtrl.dispose();
    pesoFocus.dispose();
    alturaFocus.dispose();

    hipoCtrl.dispose();
    hiperCtrl.dispose();
    rangoMinCtrl.dispose();
    rangoMaxCtrl.dispose();
    fsiCtrl.dispose();
    ricCtrl.dispose();
    insulinaBasalMarcaCtrl.dispose();
    insulinaBasalDosisCtrl.dispose();
    insulinaRapidaMarcaCtrl.dispose();
    insulinaRapidaPatronCtrl.dispose();
    bombaUnidadesCtrl.dispose();
    bombaFrecuenciaCtrl.dispose();
    medOralNombreCtrl.dispose();
    medOralDosisCtrl.dispose();
    otroMedNombreCtrl.dispose();
    otroMedGramajeCtrl.dispose();
    otroMedPropositoCtrl.dispose();
    otroMedFrecuenciaCtrl.dispose();
    otroMonitoreoCtrl.dispose();
    emergenciaNombreCtrl.dispose();
    emergenciaParentescoCtrl.dispose();
    emergenciaTelefonoCtrl.dispose();
    medicoNombreCtrl.dispose();
    super.dispose();
  }

  void actualizarAceptoTerminos(bool val) {
    aceptoTerminos = val;
    notifyListeners();
  }

  void actualizarSexo(String val) {
    sexo = val;
    notifyListeners();
  }

  void actualizarTiempoDx(String? val) {
    tiempoDx = val;
    notifyListeners();
  }

  void actualizarTipoDiabetes(String? val) {
    tipoDiabetes = val;
    notifyListeners();
  }

  void actualizarMetodoInsulina(String? val) {
    metodoInsulina = val;
    notifyListeners();
  }

  void actualizarTipoInsulinaInyeccion(String? val) {
    tipoInsulinaInyeccion = val;
    notifyListeners();
  }

  void actualizarFrecuenciaMonitoreo(String? val) {
    frecuenciaMonitoreo = val;
    notifyListeners();
  }

  void actualizarActividadFisica(String? val) {
    actividadFisica = val;
    notifyListeners();
  }

  void refrescarUI() {
    notifyListeners();
  }

  void calcularIMC() {
    if (pesoCtrl.text.isNotEmpty && alturaCtrl.text.isNotEmpty) {
      double? peso = double.tryParse(pesoCtrl.text);
      double? alturaCm = double.tryParse(alturaCtrl.text);

      if (peso != null && alturaCm != null && alturaCm > 0) {
        double alturaMetros = alturaCm / 100;
        imc = peso / (alturaMetros * alturaMetros);
        notifyListeners();
      }
    } else {
      imc = 0.0;
      notifyListeners();
    }
  }

  void guardarMedicamento(BuildContext context) {
    if (otroMedNombreCtrl.text.isNotEmpty && otroMedGramajeCtrl.text.isNotEmpty) {
      if (indiceEditando != null) {
        otrosMedicamentos[indiceEditando!] = {
          'nombre': otroMedNombreCtrl.text,
          'gramaje': otroMedGramajeCtrl.text,
          'proposito': otroMedPropositoCtrl.text,
          'frecuencia': otroMedFrecuenciaCtrl.text,
        };
      } else {
        otrosMedicamentos.add({
          'nombre': otroMedNombreCtrl.text,
          'gramaje': otroMedGramajeCtrl.text,
          'proposito': otroMedPropositoCtrl.text,
          'frecuencia': otroMedFrecuenciaCtrl.text,
        });
      }
      limpiarYOCultarFormulario();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre y el gramaje son obligatorios.')),
      );
    }
  }

  void editarMedicamento(int index) {
    final med = otrosMedicamentos[index];
    otroMedNombreCtrl.text = med['nombre'] ?? '';
    otroMedGramajeCtrl.text = med['gramaje'] ?? '';
    otroMedPropositoCtrl.text = med['proposito'] ?? '';
    otroMedFrecuenciaCtrl.text = med['frecuencia'] ?? '';

    indiceEditando = index;
    mostrarFormularioOtroMed = true;
    notifyListeners();
  }

  void eliminarMedicamento(int index) {
    otrosMedicamentos.removeAt(index);
    notifyListeners();
  }

  void iniciarAnadirMedicamento() {
    mostrarFormularioOtroMed = true;
    indiceEditando = null;
    notifyListeners();
  }

  void limpiarYOCultarFormulario() {
    otroMedNombreCtrl.clear();
    otroMedGramajeCtrl.clear();
    otroMedPropositoCtrl.clear();
    otroMedFrecuenciaCtrl.clear();
    indiceEditando = null;
    mostrarFormularioOtroMed = false;
    notifyListeners();
  }

  void siguientePaso() {
    if (pasoActual < totalPasos - 1) {
      pasoActual++;
      notifyListeners();
      pageController.animateToPage(
        pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void pasoAnterior(BuildContext context) {
    if (pasoActual > 0) {
      pasoActual--;
      notifyListeners();
      pageController.animateToPage(
        pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> guardarDatosPacienteYFinalizar(BuildContext context, {bool irAIdentificacion = false}) async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();
    String nombreUsuario = 'Paciente';

    if (metodoInsulina != 'Inyecciones') {
      insulinaBasalMarcaCtrl.clear();
      insulinaBasalDosisCtrl.clear();
      insulinaRapidaMarcaCtrl.clear();
      insulinaRapidaPatronCtrl.clear();
    } else {
      if (tipoInsulinaInyeccion == 'Basal') {
        insulinaRapidaMarcaCtrl.clear();
        insulinaRapidaPatronCtrl.clear();
      } else if (tipoInsulinaInyeccion == 'Bolo') {
        insulinaBasalMarcaCtrl.clear();
        insulinaBasalDosisCtrl.clear();
      }
    }

    if (metodoInsulina != 'Bomba') {
      bombaUnidadesCtrl.clear();
      bombaFrecuenciaCtrl.clear();
    }

    try {
      if (usuarioId != null) {
        final pacienteData = {
          'usuario_id': usuarioId,
          'sexo': sexo ?? '',
          'edad': int.tryParse(edadCtrl.text) ?? 0,
          'tiempo_dx': tiempoDx ?? '',
          'tipo_diabetes': tipoDiabetes ?? '',
          'alergias': alergiasCtrl.text,
          'hospitalizaciones': hospitalizacionesCtrl.text.isEmpty ? 'Ninguna' : hospitalizacionesCtrl.text,
          'peso': double.tryParse(pesoCtrl.text) ?? 0.0,
          'altura': double.tryParse(alturaCtrl.text) ?? 0.0,
          'imc': imc,
          'limite_hipo': double.tryParse(hipoCtrl.text) ?? 70.0,
          'limite_hiper': double.tryParse(hiperCtrl.text) ?? 180.0,
          'rango_min': double.tryParse(rangoMinCtrl.text) ?? 80.0,
          'rango_max': double.tryParse(rangoMaxCtrl.text) ?? 130.0,
          'metodo_insulina': metodoInsulina ?? '',
          'insulina_basal_marca': insulinaBasalMarcaCtrl.text,
          'insulina_basal_dosis': insulinaBasalDosisCtrl.text,
          'insulina_rapida_marca': insulinaRapidaMarcaCtrl.text,
          'insulina_rapida_patron': insulinaRapidaPatronCtrl.text,
          'bomba_unidades': bombaUnidadesCtrl.text,
          'bomba_frecuencia': bombaFrecuenciaCtrl.text,
          'med_oral_nombre': medOralNombreCtrl.text,
          'med_oral_dosis': medOralDosisCtrl.text,
          'frecuencia_monitoreo': frecuenciaMonitoreo ?? '',
          'actividad_fisica': actividadFisica ?? '',
          'emergencia_nombre': emergenciaNombreCtrl.text,
          'emergencia_parentesco': emergenciaParentescoCtrl.text,
          'emergencia_telefono': emergenciaTelefonoCtrl.text,
          'medico_nombre': medicoNombreCtrl.text,
        };

        final pacienteId = await GestorPacientes().insertarPaciente(pacienteData);

        for (var med in otrosMedicamentos) {
          await GestorPacientes().insertarOtroMedicamento({
            'paciente_id': pacienteId,
            'nombre': med['nombre'],
            'gramaje': med['gramaje'],
            'proposito': med['proposito'],
            'frecuencia': med['frecuencia'],
          });
        }

        final usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId);
        if (usuario != null) {
          nombreUsuario = usuario['nombre'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error guardando datos del paciente: $e');
    }

    if (!context.mounted) return;

    if (irAIdentificacion) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => PantallaInicioPaciente(
            nombrePaciente: nombreUsuario,
            indiceInicial: 5,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      _mostrarDialogoFinalizacion(context, nombreUsuario);
    }
  }

  void _mostrarDialogoFinalizacion(BuildContext context, String nombrePaciente) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1C63BB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF00D1FF), size: 60),
                const SizedBox(height: 20),
                const Text('¡Registro Finalizado!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text('Tus datos clínicos han sido guardados exitosamente.\n\n¡Bienvenido a Insul App!', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Color(0xFFE8E8E8))),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        dialogContext,
                        MaterialPageRoute(
                          builder: (context) => PantallaInicioPaciente(
                            nombrePaciente: nombrePaciente,
                            indiceInicial: 0,
                          ),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D1FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('Ir al Inicio', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
