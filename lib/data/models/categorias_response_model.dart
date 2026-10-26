/// Modelo de respuesta con las categorías disponibles y su límite configurado.
class CategoriasResponseModel {
  final List<String> categorias;
  final double limitePorCategoria;

  const CategoriasResponseModel({
    required this.categorias,
    required this.limitePorCategoria,
  });

  factory CategoriasResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoriasResponseModel(
      categorias: (json['categorias'] as List<dynamic>)
          .map((c) => c.toString())
          .toList(),
      limitePorCategoria: (json['limite_por_categoria'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categorias': categorias,
      'limite_por_categoria': limitePorCategoria,
    };
  }
}
