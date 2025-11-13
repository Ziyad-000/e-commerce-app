class CategoryModel {
  final String id;
  final String name;
  final int CategoryNumber;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.CategoryNumber,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'name': name});
    result.addAll({'CategoryNumber': CategoryNumber});
    result.addAll({'imageUrl': imageUrl});

    return result;
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      CategoryNumber: map['CategoryNumber']?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
