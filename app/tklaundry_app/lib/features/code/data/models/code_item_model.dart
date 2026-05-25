class CodeItemModel {
  const CodeItemModel({
    required this.codeId,
    required this.codeName,
    required this.grade,
    this.pCodeId,
  });

  factory CodeItemModel.fromJson(Map<String, dynamic> json) {
    return CodeItemModel(
      codeId: (json['codeId'] as String).trim(),
      codeName: json['codeName'] as String,
      grade: json['grade'] as int? ?? 0,
      pCodeId: json['pCodeId'] as String?,
    );
  }

  final String codeId;
  final String codeName;
  final int grade;
  final String? pCodeId;

  String get displayName {
    final indent = '  ' * grade;
    return '$indent$codeName';
  }
}
