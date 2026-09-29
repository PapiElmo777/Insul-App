import 'package:flutter/material.dart';
import '../../../../database/gestores/gestor_cuidadores.dart';
import '../../../../database/gestores/gestor_usuarios.dart';

class ControladorRegistroCuidador extends ChangeNotifier {
  final PageController pageController = PageController();
  int pasoActual = 0;
  final int totalPasos = 7;
  bool aceptoTerminos = false;

  String? tipoPaciente;
  final TextEditingController parentescoCtrl = TextEditingController();
  final TextEditingController nombrePacienteCtrl = TextEditingController();

  String? sexoPaciente;
  final TextEditingController edadPacienteCtrl = TextEditingController();
  String? tiempoDxPaciente;
  String? tipoDiabetesPaciente;
  final TextEditingController alergiasPacienteCtrl = TextEditingController();
  final TextEditingController hospitalizacionesCtrl = TextEditingController();
  final TextEditingController pesoPacienteCtrl = TextEditingController();
  final TextEditingController alturaPacienteCtrl = TextEditingController();

  final FocusNode pesoFocus = FocusNode();
  final FocusNode alturaFocus = FocusNode();

  double imcPaciente = 0.0;

  final TextEditingController hipoCtrl = TextEditingController(text: '70');
  final TextEditingController hiperCtrl = TextEditingController(text: '180');
  final TextEditingController rangoMinCtrl = TextEditingController(text: '80');
  final TextEditingController rangoMaxCtrl = TextEditingController(text: '130');
  final TextEditingController fsiCtrl = TextEditingController(text: '50');
  final TextEditingController ricCtrl = TextEditingController(text: '15');

  String? metodoInsulinaPaciente;
  String? tipoInsulinaInyeccionPaciente;

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
  String? frecuenciaMonitoreoPaciente;
  final TextEditingController otroMonitoreoCtrl = TextEditingController();

  final TextEditingController medicoNombreCtrl = TextEditingController();
  String? riesgoCaidas;
  String? estadoCognitivo;
  String? autonomiaMenor;
  final TextEditingController contactoEscolarCtrl = TextEditingController();

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
  final List<String> opcionesRiesgoCaidas = ['Sí usa', 'No usa'];
  final List<String> opcionesEstadoCognitivo = ['Sí', 'A veces', 'No'];

  ControladorRegistroCuidador() {
    pesoFocus.addListener(() {
      if (!pesoFocus.hasFocus) _calcularIMCPaciente();
    });
    alturaFocus.addListener(() {
      if (!alturaFocus.hasFocus) _calcularIMCPaciente();
    });
    
    parentescoCtrl.addListener(notifyListeners);
    nombrePacienteCtrl.addListener(notifyListeners);
    edadPacienteCtrl.addListener(notifyListeners);
    pesoPacienteCtrl.addListener(notifyListeners);
    alturaPacienteCtrl.addListener(notifyListeners);
    hipoCtrl.addListener(notifyListeners);
    hiperCtrl.addListener(notifyListeners);
    rangoMinCtrl.addListener(notifyListeners);
    rangoMaxCtrl.addListener(notifyListeners);
    otroMedNombreCtrl.addListener(notifyListeners);
    otroMedGramajeCtrl.addListener(notifyListeners);
    otroMonitoreoCtrl.addListener(notifyListeners);
    medicoNombreCtrl.addListener(notifyListeners);
    contactoEscolarCtrl.addListener(notifyListeners);
  }

  @override
  void dispose() {
    pageController.dispose();
    parentescoCtrl.dispose();
    nombrePacienteCtrl.dispose();
    edadPacienteCtrl.dispose();
    alergiasPacienteCtrl.dispose();
    hospitalizacionesCtrl.dispose();
    pesoPacienteCtrl.dispose();
    alturaPacienteCtrl.dispose();
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
    medicoNombreCtrl.dispose();
    contactoEscolarCtrl.dispose();
    super.dispose();
  }

  void _calcularIMCPaciente() {
    if (pesoPacienteCtrl.text.isNotEmpty && alturaPacienteCtrl.text.isNotEmpty) {
      double? peso = double.tryParse(pesoPacienteCtrl.text);
      double? alturaCm = double.tryParse(alturaPacienteCtrl.text);

      if (peso != null && alturaCm != null && alturaCm > 0) {
        double alturaMetros = alturaCm / 100;
        imcPaciente = peso / (alturaMetros * alturaMetros);
      }
    } else {
      imcPaciente = 0.0;
    }
    notifyListeners();
  }

  void setAceptoTerminos(bool val) {
    aceptoTerminos = val;
    notifyListeners();
  }

  void setTipoPaciente(String val) {
    tipoPaciente = val;
    notifyListeners();
  }

  void setSexoPaciente(String val) {
    sexoPaciente = val;
    notifyListeners();
  }

  void setTiempoDxPaciente(String? val) {
    tiempoDxPaciente = val;
    notifyListeners();
  }

  void setTipoDiabetesPaciente(String? val) {
    tipoDiabetesPaciente = val;
    notifyListeners();
  }

  void setMetodoInsulinaPaciente(String val) {
    metodoInsulinaPaciente = val;
    notifyListeners();
  }

  void setTipoInsulinaInyeccionPaciente(String val) {
    tipoInsulinaInyeccionPaciente = val;
    notifyListeners();
  }

  void setRiesgoCaidas(String? val) {
    riesgoCaidas = val;
    notifyListeners();
  }

  void setEstadoCognitivo(String? val) {
    estadoCognitivo = val;
    notifyListeners();
  }

  void setAutonomiaMenor(String val) {
    autonomiaMenor = val;
    notifyListeners();
  }

  void setFrecuenciaMonitoreo(String? val) {
    frecuenciaMonitoreoPaciente = val;
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

  void mostrarFormularioNuevo() {
    mostrarFormularioOtroMed = true;
    indiceEditando = null;
    notifyListeners();
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

  void siguientePaso() {
    if (pasoActual < totalPasos - 1) {
      pasoActual++;
      pageController.animateToPage(
        pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  void pasoAnterior(BuildContext context) {
    if (pasoActual > 0) {
      pasoActual--;
      pageController.animateToPage(
        pasoActual,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  Future<String> guardarDatosBD() async {
    final usuarioId = await GestorUsuario().obtenerSesionActiva();
    String nombreCuidador = 'Cuidador';

    if (metodoInsulinaPaciente != 'Inyecciones') {
      insulinaBasalMarcaCtrl.clear();
      insulinaBasalDosisCtrl.clear();
      insulinaRapidaMarcaCtrl.clear();
      insulinaRapidaPatronCtrl.clear();
    } else {
      if (tipoInsulinaInyeccionPaciente == 'Basal') {
        insulinaRapidaMarcaCtrl.clear();
        insulinaRapidaPatronCtrl.clear();
      } else if (tipoInsulinaInyeccionPaciente == 'Bolo') {
        insulinaBasalMarcaCtrl.clear();
        insulinaBasalDosisCtrl.clear();
      }
    }

    if (metodoInsulinaPaciente != 'Bomba') {
      bombaUnidadesCtrl.clear();
      bombaFrecuenciaCtrl.clear();
    }

    try {
      if (usuarioId != null) {
        final pacienteData = {
          'cuidador_id': usuarioId,
          'tipo_paciente': tipoPaciente ?? '',
          'parentesco': parentescoCtrl.text,
          'nombre': nombrePacienteCtrl.text,
          'sexo': sexoPaciente ?? '',
          'edad': int.tryParse(edadPacienteCtrl.text) ?? 0,
          'tiempo_dx': tiempoDxPaciente ?? '',
          'tipo_diabetes': tipoDiabetesPaciente ?? '',
          'alergias': alergiasPacienteCtrl.text,
          'hospitalizaciones': hospitalizacionesCtrl.text.isEmpty ? 'Ninguna' : hospitalizacionesCtrl.text,
          'peso': double.tryParse(pesoPacienteCtrl.text) ?? 0.0,
          'altura': double.tryParse(alturaPacienteCtrl.text) ?? 0.0,
          'imc': imcPaciente,
          'limite_hipo': double.tryParse(hipoCtrl.text) ?? 70.0,
          'limite_hiper': double.tryParse(hiperCtrl.text) ?? 180.0,
          'rango_min': double.tryParse(rangoMinCtrl.text) ?? 80.0,
          'rango_max': double.tryParse(rangoMaxCtrl.text) ?? 130.0,
          'metodo_insulina': metodoInsulinaPaciente ?? '',
          'insulina_basal_marca': insulinaBasalMarcaCtrl.text,
          'insulina_basal_dosis': insulinaBasalDosisCtrl.text,
          'insulina_rapida_marca': insulinaRapidaMarcaCtrl.text,
          'insulina_rapida_patron': insulinaRapidaPatronCtrl.text,
          'bomba_unidades': bombaUnidadesCtrl.text,
          'bomba_frecuencia': bombaFrecuenciaCtrl.text,
          'med_oral_nombre': medOralNombreCtrl.text,
          'med_oral_dosis': medOralDosisCtrl.text,
          'frecuencia_monitoreo': frecuenciaMonitoreoPaciente ?? '',
          'medico_nombre': medicoNombreCtrl.text,
          'riesgo_caidas': riesgoCaidas ?? '',
          'estado_cognitivo': estadoCognitivo ?? '',
          'autonomia_menor': autonomiaMenor ?? '',
          'contacto_escolar': contactoEscolarCtrl.text,
        };

        final pacienteId = await GestorCuidadores().insertarPacienteCuidador(pacienteData);

        for (var med in otrosMedicamentos) {
          await GestorCuidadores().insertarOtroMedicamentoCuidador({
            'paciente_cuidador_id': pacienteId,
            'nombre': med['nombre'],
            'gramaje': med['gramaje'],
            'proposito': med['proposito'],
            'frecuencia': med['frecuencia'],
          });
        }

        final usuario = await GestorUsuario().obtenerUsuarioPorId(usuarioId);
        if (usuario != null) {
          nombreCuidador = usuario['nombre'] as String;
        }
      }
    } catch (e) {
      debugPrint('Error guardando cuidador: $e');
    }

    return nombreCuidador;
  }
}
