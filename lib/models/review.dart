class Review {
  final int? id;
  final int productId;
  final String clientId;
  final int rating;
  final String? comment;

  Review({
    this.id,
    required this.productId,
    required this.clientId,
    required this.rating,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        productId: json['productId'],
        clientId: json['clientId'] ?? '',
        rating: json['rating'] ?? 0,
        comment: json['comment'],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'productId': productId,
        'clientId': clientId,
        'rating': rating,
        if (comment != null) 'comment': comment,
      };
}
