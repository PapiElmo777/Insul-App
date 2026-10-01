import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controlador_dashboard_enfermero.dart';
import '../../pantalla_login.dart';

class TabPerfilEnfermero extends StatelessWidget {
  final ControladorDashboardEnfermero controlador;

  const TabPerfilEnfermero({super.key, required this.controlador});

  void _mostrarOpcionesImagen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccionar foto de perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF1C63BB)),
                title: const Text('Elegir de la Galería'),
                onTap: () { Navigator.pop(ctx); controlador.seleccionarImagen(ImageSource.gallery); },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1C63BB)),
                title: const Text('Tomar una Foto'),
                onTap: () { Navigator.pop(ctx); controlador.seleccionarImagen(ImageSource.camera); },
              ),
              if (controlador.imagenPerfil != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Color(0xFFD32F2F)),
                  title: const Text('Eliminar foto actual', style: TextStyle(color: Color(0xFFD32F2F))),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await controlador.eliminarImagenPerfil();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoEditarPerfilEnfermero(BuildContext context) {
    final TextEditingController nombreCtrl = TextEditingController(text: controlador.nombreEnfermeroLocal);
    final TextEditingController correoCtrl = TextEditingController(text: controlador.correoEnfermero);
    final TextEditingController telefonoCtrl = TextEditingController(text: controlador.telefonoEnfermero);
    final TextEditingController cedulaCtrl = TextEditingController(text: controlador.cedulaEnfermero);
    final TextEditingController hospitalCtrl = TextEditingController(text: controlador.hospitalEnfermero);
    final TextEditingController areaCtrl = TextEditingController(text: controlador.areaEnfermero);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C63BB))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _crearCampoEdicion('Nombre Completo', nombreCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Correo Electrónico', correoCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Teléfono', telefonoCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Cédula Profesional', cedulaCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Institución Médica', hospitalCtrl),
                const SizedBox(height: 10),
                _crearCampoEdicion('Área', areaCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await controlador.actualizarPerfilEnfermero(
                  nombreCtrl.text,
                  correoCtrl.text,
                  telefonoCtrl.text,
                  cedulaCtrl.text,
                  hospitalCtrl.text,
                  areaCtrl.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF008CCF)),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _crearCampoEdicion(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF008CCF), width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mi Perfil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black)),
          const SizedBox(height: 30),
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: const Color(0xFF1C63BB), width: 3),
                    image: controlador.imagenPerfil != null
                        ? DecorationImage(image: FileImage(controlador.imagenPerfil!), fit: BoxFit.cover)
                        : const DecorationImage(
                      image: AssetImage('assets/enfermero_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: controlador.imagenPerfil == null ? const Icon(Icons.person, color: Colors.white, size: 60) : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _mostrarOpcionesImagen(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00D1FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          _crearDatoPerfil(Icons.person, 'Nombre Completo', controlador.nombreEnfermeroLocal),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.email, 'Correo Electrónico', controlador.correoEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.phone, 'Teléfono', controlador.telefonoEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.badge, 'Cédula Profesional', controlador.cedulaEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.local_hospital, 'Institución Médica', controlador.hospitalEnfermero),
          const Divider(height: 20, color: Color(0xFFD2D2D2)),
          _crearDatoPerfil(Icons.medical_services, 'Área', controlador.areaEnfermero),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _mostrarDialogoEditarPerfilEnfermero(context),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C63BB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
                await controlador.cerrarSesion();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const PantallaLogin()),
                        (Route<dynamic> route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearDatoPerfil(IconData icono, String titulo, String valor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFFE8F4F8), shape: BoxShape.circle),
          child: Icon(icono, color: const Color(0xFF1C63BB)),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
