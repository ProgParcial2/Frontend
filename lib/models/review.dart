class Review {
  final int id;
  final String productName;
  final int rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.productName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        productName: json['productName'] ?? '',
        rating: json['rating'],
        comment: json['comment'] ?? '',
        date: DateTime.parse(json['date']),
      );
}
