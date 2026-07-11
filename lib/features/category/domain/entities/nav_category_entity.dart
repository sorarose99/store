class MainCategoryEntity {
  final String id;
  final String slug;
  final String name;

  const MainCategoryEntity({
    required this.id,
    required this.slug,
    required this.name,
  });
}

class SubCategoryEntity {
  final String id;
  final String slug;
  final String name;
  final String imageAsset;

  const SubCategoryEntity({
    required this.id,
    required this.slug,
    required this.name,
    required this.imageAsset,
  });
}
