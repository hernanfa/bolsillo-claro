/// Modelo de resumen por categoría.
class ResumenCategoriaModel {
  final String categoria;
  final double total;
  final int cantidad;
  final double disponible;

  const ResumenCategoriaModel({
    required this.categoria,
    required this.total,
    required this.cantidad,
    required this.disponible,
  });

  factory ResumenCategoriaModel.fromJson(Map<String, dynamic> json) {
    return ResumenCategoriaModel(
      categoria: json['categoria'] as String,
      total: (json['total'] as num).toDouble(),
      cantidad: json['cantidad'] as int,
      disponible: (json['disponible'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'total': total,
      'cantidad': cantidad,
      'disponible': disponible,
    };
  }
}

/// Modelo de resumen general de gastos calculado por el backend.
class ResumenGastosModel {
  final double totalGeneral;
  final List<ResumenCategoriaModel> categorias;

  const ResumenGastosModel({
    required this.totalGeneral,
    required this.categorias,
  });

  factory ResumenGastosModel.fromJson(Map<String, dynamic> json) {
    return ResumenGastosModel(
      totalGeneral: (json['total_general'] as num).toDouble(),
      categorias: (json['categorias'] as List<dynamic>)
          .map((c) => ResumenCategoriaModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_general': totalGeneral,
      'categorias': categorias.map((c) => c.toJson()).toList(),
    };
  }
}
