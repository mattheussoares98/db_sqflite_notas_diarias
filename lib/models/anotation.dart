class Anotation {
  int? id;
  String title;
  String description;
  String date;

  Anotation({
    required this.title,
    required this.description,
    required this.date,
    this.id,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'description': description,
      'date': date,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
