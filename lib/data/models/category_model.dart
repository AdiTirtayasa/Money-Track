class CategoryModel{
  final int? id;
  final String name;
  final String type;
  final String icon;
  final String color;
  final bool isDefault;

CategoryModel({
  this.id,
  required this.name,
  required this.type,
  required this.icon,
  required this.color,
  this.isDefault = false
});

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'type': type,
    'icon': icon,
    'color': color,
    'isDefault': isDefault ? 1 : 0,
  };
}

factory CategoryModel.fromMap(Map<String, dynamic> map) {
  return CategoryModel(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    icon: map['icon'],
    color: map['color'],
    isDefault: map['isDefault'] == 1,
  );
}

CategoryModel copyWith({
  int? id,
  String? name,
  String? type,
  String? icon,
  String? color,
  bool? isDefault,
}) {
  return CategoryModel(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isDefault: isDefault ?? this.isDefault,
  );
}
}
