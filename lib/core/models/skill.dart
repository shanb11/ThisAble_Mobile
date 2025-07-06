class Skill {
  final int id;
  final String name;
  final String category;
  final String icon;
  final String? description;
  final int categoryId;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    this.description,
    required this.categoryId,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'description': description,
      'category_id': categoryId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Skill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Skill(id: $id, name: $name, category: $category)';
}
