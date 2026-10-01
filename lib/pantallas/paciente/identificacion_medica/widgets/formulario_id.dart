import 'package:flutter/material.dart';
import '../controlador_id_medica.dart';

class FormularioId extends StatelessWidget {
  final ControladorIdMedica controlador;

  const FormularioId({super.key, required this.controlador});

  @override
  Widget build(BuildContext context) {

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF1C63BB),
          expandedHeight: 140.0,
          floating: true, snap: true, pinned: false, automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
          flexibleSpace: FlexibleSpaceBar(
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Identificación Médica', style: TextStyle(fontFamily: 'Montserrat', fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                    SizedBox(height: 5),
                    Text('Completa tu información clínica para emergencias.', style: TextStyle(color: Color(0xFFE8E8E8), fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE65100))),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFFE65100)),
                      SizedBox(width: 10),
                      Expanded(child: Text('Esta información será vital en caso de una emergencia médica. Los medicamentos se sincronizarán automáticamente con tu pestaña de "Mis Medicamentos".', style: TextStyle(color: Color(0xFFE65100), fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                const Text('Salud General', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),

                const Text('Tipo Sanguíneo', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFD2D2D2))),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controlador.tipoSanguineoSeleccionado,
                      isExpanded: true,
                      icon: const Icon(Icons.water_drop, color: Color(0xFFD32F2F)),
                      items: controlador.tiposSanguineos.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500)))).toList(),
                      onChanged: (val) => controlador.setTipoSanguineo(val!),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                _crearCampoFormulario('Alergias (Medicamentos o alimentos)', controlador.alergiasCtrl, Icons.warning_amber_rounded),
                const SizedBox(height: 15),
                _crearCampoFormulario('Enfermedades Crónicas (Ej. Hipertensión)', controlador.enfCronicasCtrl, Icons.coronavirus_outlined),

                const SizedBox(height: 25),
                const Text('Historial Clínico', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),
                _crearCampoFormulario('Hospitalizaciones Recientes (Motivo)', controlador.hospCtrl, Icons.local_hospital_outlined, maxLines: 2),
                const SizedBox(height: 15),
                _crearCampoFormulario('Cirugías Previas', controlador.cirugiasCtrl, Icons.content_cut, maxLines: 2),

                const SizedBox(height: 25),
                const Text('Contacto y Seguimiento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
                const SizedBox(height: 15),
                _crearCampoFormulario('Nombre del Médico Tratante', controlador.medicoCtrl, Icons.person_outline),
                const SizedBox(height: 15),
                _crearCampoFormulario('Clínica u Hospital de Atención', controlador.clinicaCtrl, Icons.business_outlined),
                const SizedBox(height: 15),
                _crearCampoFormulario('Contacto de Emergencia (Nombre)', controlador.emergenciaNombreCtrl, Icons.contact_emergency_outlined),
                const SizedBox(height: 15),
                _crearCampoFormulario('Teléfono de Emergencia', controlador.emergenciaTelCtrl, Icons.phone_outlined, isPhone: true),

                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => controlador.guardarFormulario(),
                    icon: const Icon(Icons.save_alt, color: Colors.white),
                    label: const Text('Generar Identificación Médica', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _crearCampoFormulario(String label, TextEditingController controller, IconData icon, {bool isPhone = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1C63BB)),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFD2D2D2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF1C63BB), width: 2)),
      ),
    );
  }
}
