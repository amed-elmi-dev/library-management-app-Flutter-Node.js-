import "book.dart";

class Reservation {
  final String id;
  final Book? book;
  final String bookId;
  final String status;
  final DateTime? createdAt;

  Reservation({
    required this.id,
    required this.book,
    required this.bookId,
    required this.status,
    required this.createdAt,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    final bookValue = json["book"];
    final bookId = bookValue is Map<String, dynamic>
        ? (bookValue["_id"] ?? bookValue["id"] ?? "").toString()
        : (bookValue ?? "").toString();

    return Reservation(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      book: bookValue is Map<String, dynamic> ? Book.fromJson(bookValue) : null,
      bookId: bookId,
      status: (json["status"] ?? "").toString(),
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bookId": bookId,
      "status": status,
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}
