enum VisibilityType {
  public,
  private,
  followers;

  static VisibilityType parse(String value) {
    return VisibilityType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => VisibilityType.public,
    );
  }

  String toJson() => name;
}

extension VisibilityTypeExtension on VisibilityType {
  String get displayName {
    switch (this) {
      case VisibilityType.public:
        return '전체 공개';
      case VisibilityType.followers:
        return '친구 공개';
      case VisibilityType.private:
        return '비공개';
      default:
        return '';
    }
  }
}
