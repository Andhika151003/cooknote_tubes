class Recipes {
  final String idRecipes;
  final String user_Id;
  final String title;
  final String categories_Id;
  final String bahan;
  final String langkah;
  final String image_url;
  final DateTime created_at;
  final DateTime uploaded_at;

  Recipes({
    required this.idRecipes,
    required this.user_Id,
    required this.title,
    required this.categories_Id,
    required this.bahan,
    required this.langkah,
    required this.image_url,
    required this.created_at,
    required this.uploaded_at,
  });

  factory Recipes.fromJson(Map<String, dynamic> json) {
    return Recipes(
      idRecipes: json['id_Recipes'],
      user_Id: json['user_Id'],
      title: json['title'],
      categories_Id: json['categories_Id'],
      bahan: json['bahan'],
      langkah: json['langkah'],
      image_url: json['image_url'],
      created_at: json['created_at'],
      uploaded_at: json['uploaded_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_Recipes': idRecipes,
      'user_Id': user_Id,
      'title': title,
      'categories_Id': categories_Id,
      'bahan': bahan,
      'langkah': langkah,
      'image_url': image_url,
      'created_at': created_at,
      'uploaded_at': uploaded_at,
    };
  }
}
