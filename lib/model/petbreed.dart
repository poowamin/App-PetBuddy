class PetbreedField {
  static const String createdAt = 'time';
}

class Petbreed {
  final String breeding;

  Petbreed({
    required this.breeding,
  });

  static Petbreed fromJson(Map<String, dynamic> json) => Petbreed(
        breeding: json['breeding'],
      );

  Map<String, dynamic> toJson() => {
        'breeding': breeding,
      };
}
