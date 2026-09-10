enum AmbitoPaciente { personal, familiar, institucional }

/// Los identificadores de las tres tablas de pacientes no son intercambiables.
class PacienteClinico {
  final AmbitoPaciente ambito;
  final int id;
  const PacienteClinico(this.ambito, this.id);

  String get tablaLecturas => switch (ambito) {
    AmbitoPaciente.personal => 'registros_glucosa',
    AmbitoPaciente.familiar => 'registros_glucosa_cuidador',
    AmbitoPaciente.institucional => 'glucosa_enfermero',
  };
  String get columnaPaciente => ambito == AmbitoPaciente.familiar
      ? 'paciente_cuidador_id'
      : 'paciente_id';
}
