class Book {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  final String coverUrl;
  final String isbn;
  final DateTime? publishedDate;
  final int totalCopies;
  final int availableCopies;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.coverUrl,
    required this.isbn,
    required this.publishedDate,
    required this.totalCopies,
    required this.availableCopies,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? "") ?? 0;
    }

    return Book(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      title: (json["title"] ?? "").toString(),
      author: (json["author"] ?? "").toString(),
      category: (json["category"] ?? "").toString(),
      description: (json["description"] ?? "").toString(),
      coverUrl: (json["coverUrl"] ?? "").toString(),
      isbn: (json["isbn"] ?? "").toString(),
      publishedDate: json["publishedDate"] != null
          ? DateTime.tryParse(json["publishedDate"].toString())
          : null,
      totalCopies: parseInt(json["totalCopies"]),
      availableCopies: parseInt(json["availableCopies"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "category": category,
      "description": description,
      "coverUrl": coverUrl,
      "isbn": isbn,
      "publishedDate": publishedDate?.toIso8601String(),
      "totalCopies": totalCopies,
      "availableCopies": availableCopies,
    };
  }
}
