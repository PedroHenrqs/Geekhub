/// Converte para inteiro positivo; retorna null se ausente ou inválido.
int? asPositiveInt(Object? value) {
  if (value is int) return value > 0 ? value : null;
  if (value is num) {
    final v = value.toInt();
    return v > 0 ? v : null;
  }
  if (value is String) {
    final v = int.tryParse(value.trim());
    return (v != null && v > 0) ? v : null;
  }
  return null;
}

/// Converte para lista de textos não vazios.
List<String> asStringList(Object? value) {
  if (value is List) {
    return value
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  if (value is String && value.trim().isNotEmpty) return [value.trim()];
  return const [];
}

/// A Open Library devolve a descrição como texto ou como {type, value}.
String? parseDescription(Object? raw) {
  String? text;
  if (raw is String) {
    text = raw;
  } else if (raw is Map && raw['value'] is String) {
    text = raw['value'] as String;
  }
  final trimmed = text?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}
