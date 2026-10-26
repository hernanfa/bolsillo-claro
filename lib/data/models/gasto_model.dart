/// Modelo representativo de un gasto individual.
class GastoModel {
  final int id;
  final String descripcion;
  final double monto;
  final String categoria;
  final String? fecha;

  const GastoModel({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.categoria,
    this.fecha,
  });

  factory GastoModel.fromJson(Map<String, dynamic> json) {
    return GastoModel(
      id: json['id'] as int,
      descripcion: json['descripcion'] as String,
      monto: (json['monto'] as num).toDouble(),
      categoria: json['categoria'] as String,
      fecha: json['fecha'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'categoria': categoria,
      if (fecha != null) 'fecha': fecha,
    };
  }

  GastoModel copyWith({
    int? id,
    String? descripcion,
    double? monto,
    String? categoria,
    String? fecha,
  }) {
    return GastoModel(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GastoModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          descripcion == other.descripcion &&
          monto == other.monto &&
          categoria == other.categoria &&
          fecha == other.fecha;

  @override
  int get hashCode =>
      id.hashCode ^
      descripcion.hashCode ^
      monto.hashCode ^
      categoria.hashCode ^
      fecha.hashCode;

  @override
  String toString() =>
      'GastoModel(id: $id, descripcion: $descripcion, monto: $monto, categoria: $categoria, fecha: $fecha)';
}
