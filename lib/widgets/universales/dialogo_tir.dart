import 'package:flutter/material.dart';

void mostrarDialogoTIRUniversal(
    BuildContext context, {
      required List<Map<String, dynamic>> registros,
      required int limiteHipo,
      required int limiteHiper,
      required int rangoMin,
      required int rangoMax,
    }) {
  int total = registros.length;
  int cHipo = 0, cBajo = 0, cNormal = 0, cElevado = 0, cHiper = 0;

  if (total > 0) {
    for (var r in registros) {
      int val = (r['valor'] as num).toInt();
      if (val < limiteHipo) cHipo++;
      else if (val < rangoMin) cBajo++;
      else if (val <= rangoMax) cNormal++;
      else if (val <= limiteHiper) cElevado++;
      else cHiper++;
    }
  }

  int pctHipo = total > 0 ? ((cHipo / total) * 100).round() : 0;
  int pctBajo = total > 0 ? ((cBajo / total) * 100).round() : 0;
  int pctNormal = total > 0 ? ((cNormal / total) * 100).round() : 0;
  int pctElevado = total > 0 ? ((cElevado / total) * 100).round() : 0;
  int pctHiper = total > 0 ? ((cHiper / total) * 100).round() : 0;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tiempo en Rango (TIR)', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF2F2F2F))),
                  IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('El TIR es el porcentaje del tiempo que tu glucosa está en cada nivel (dentro y fuera de rango).', style: TextStyle(fontFamily: 'Roboto', fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
              const SizedBox(height: 25),
              SizedBox(
                height: 320,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(padding: const EdgeInsets.only(top: 8), child: _etiquetaTir('Hiperglucemia', '$pctHiper%', const Color(0xFFD32F2F))),
                          _etiquetaTir('Elevado', '$pctElevado%', const Color(0xFFE65100)),
                          _etiquetaTir('En Rango', '$pctNormal%', const Color(0xFF2E7D32), esMeta: true),
                          _etiquetaTir('Bajo', '$pctBajo%', const Color(0xFFE65100)),
                          Padding(padding: const EdgeInsets.only(bottom: 8), child: _etiquetaTir('Hipoglucemia', '$pctHipo%', const Color(0xFFD32F2F))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    ClipPath(
                      clipper: _DropClipper(),
                      child: Container(
                        width: 145, height: 320, color: Colors.white,
                        child: Column(
                          children: [
                            Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.bottomCenter, padding: const EdgeInsets.only(bottom: 2), child: Text('>$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                            Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('${rangoMax + 1}-$limiteHiper\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                            Container(height: 110, width: double.infinity, color: const Color(0xFF2E7D32), alignment: Alignment.center, child: Text('Objetivo\n$rangoMin-$rangoMax\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white, height: 1.2))),
                            Container(height: 55, width: double.infinity, color: const Color(0xFFE65100), alignment: Alignment.center, child: Text('$limiteHipo-${rangoMin - 1}\nmg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white, height: 1.1))),
                            Container(height: 50, width: double.infinity, color: const Color(0xFFD32F2F), alignment: Alignment.topCenter, padding: const EdgeInsets.only(top: 4), child: Text('<$limiteHipo mg/dL', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },
  );
}

Widget _etiquetaTir(String titulo, String porcentaje, Color color, {bool esMeta = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(titulo, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      Text(porcentaje, style: TextStyle(fontSize: 22, color: color, fontWeight: FontWeight.bold)),
      if (esMeta)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('META', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 9),
            ],
          ),
        ),
    ],
  );
}

class _DropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double w = size.width;
    double h = size.height;
    double r = w / 2;
    double cy = h - r;
    path.moveTo(w / 2, 0);
    path.quadraticBezierTo(w, cy - (r * 1.2), w, cy);
    path.arcToPoint(Offset(0, cy), radius: Radius.circular(r), clockwise: true);
    path.quadraticBezierTo(0, cy - (r * 1.2), w / 2, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
