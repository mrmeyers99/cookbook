
class ParsedIngredient {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String unitLong;
  final String unitShort;
  final String image;
  final String original;
  final String originalName;
  final String aisle;

  ParsedIngredient(this.id, this.name, this.amount, this.unit, this.unitLong,
      this.unitShort, this.image, this.original, this.originalName, this.aisle);

  static ParsedIngredient fromMap(Map<String, dynamic> map) {
    return ParsedIngredient(
      map['id'],
      map['name'],
      map['amount'],
      map['unit'],
      map['unitLong'],
      map['unitShort'],
      map['image'],
      map['original'],
      map['originalName'],
      map['aisle'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ParsedIngredient &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              amount == other.amount &&
              unit == other.unit &&
              unitLong == other.unitLong &&
              unitShort == other.unitShort &&
              image == other.image &&
              original == other.original &&
              originalName == other.originalName &&
              aisle == other.aisle;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      amount.hashCode ^
      unit.hashCode ^
      unitLong.hashCode ^
      unitShort.hashCode ^
      image.hashCode ^
      original.hashCode ^
      originalName.hashCode ^
      aisle.hashCode;

  @override
  String toString() {
    return 'ParsedIngredient{id: $id, name: $name, amount: $amount, unit: $unit, unitLong: $unitLong, unitShort: $unitShort, image: $image, original: $original, originalName: $originalName, aisle: $aisle}';
  }
}
