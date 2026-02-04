import "book.dart";
import "book_copy.dart";

class Borrow {
  final String id;
  final Book? book;
  final String bookId;
  final BookCopy? copy;
  final String copyId;
  final DateTime? borrowedAt;
  final DateTime? dueAt;
  final DateTime? returnedAt;
  final String status;

  Borrow({
    required this.id,
    required this.book,
    required this.bookId,
    required this.copy,
    required this.copyId,
    required this.borrowedAt,
    required this.dueAt,
    required this.returnedAt,
    required this.status,
  });

  factory Borrow.fromJson(Map<String, dynamic> json) {
    final bookValue = json["book"];
    final copyValue = json["copy"];

    final bookId = bookValue is Map<String, dynamic>
        ? (bookValue["_id"] ?? bookValue["id"] ?? "").toString()
        : (bookValue ?? "").toString();

    final copyId = copyValue is Map<String, dynamic>
        ? (copyValue["_id"] ?? copyValue["id"] ?? "").toString()
        : (copyValue ?? "").toString();

    return Borrow(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      book: bookValue is Map<String, dynamic> ? Book.fromJson(bookValue) : null,
      bookId: bookId,
      copy:
          copyValue is Map<String, dynamic> ? BookCopy.fromJson(copyValue) : null,
      copyId: copyId,
      borrowedAt: json["borrowedAt"] != null
          ? DateTime.tryParse(json["borrowedAt"].toString())
          : null,
      dueAt: json["dueAt"] != null
          ? DateTime.tryParse(json["dueAt"].toString())
          : null,
      returnedAt: json["returnedAt"] != null
          ? DateTime.tryParse(json["returnedAt"].toString())
          : null,
      status: (json["status"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bookId": bookId,
      "copyId": copyId,
      "borrowedAt": borrowedAt?.toIso8601String(),
      "dueAt": dueAt?.toIso8601String(),
      "returnedAt": returnedAt?.toIso8601String(),
      "status": status,
    };
  }
}
