class BookCopy {
  final String id;
  final String bookId;
  final int copyNumber;
  final String status;

  BookCopy({
    required this.id,
    required this.bookId,
    required this.copyNumber,
    required this.status,
  });

  factory BookCopy.fromJson(Map<String, dynamic> json) {
    final bookValue = json["book"];
    final bookId = bookValue is Map<String, dynamic>
        ? (bookValue["_id"] ?? bookValue["id"] ?? "").toString()
        : (bookValue ?? "").toString();

    return BookCopy(
      id: (json["_id"] ?? json["id"] ?? "").toString(),
      bookId: bookId,
      copyNumber: (json["copyNumber"] ?? 0) as int,
      status: (json["status"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bookId": bookId,
      "copyNumber": copyNumber,
      "status": status,
    };
  }
}
