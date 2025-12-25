class Categories {
  final String idCategories;
  final String name;

  Categories({required this.idCategories, required this.name});

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(idCategories: json['idCategories'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'idCategories': idCategories, 'name': name};
  }
}
