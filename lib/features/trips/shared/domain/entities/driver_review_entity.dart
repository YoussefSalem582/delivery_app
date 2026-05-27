import 'package:equatable/equatable.dart';

class DriverReviewEntity extends Equatable {
  const DriverReviewEntity({
    required this.id,
    required this.driverId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String driverId;
  final String authorName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory DriverReviewEntity.fromJson(Map<String, dynamic> json) {
    return DriverReviewEntity(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      authorName: json['authorName'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, driverId, authorName, rating, comment, createdAt];
}

class DriverRatingSummary extends Equatable {
  const DriverRatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  factory DriverRatingSummary.fromReviews(List<DriverReviewEntity> reviews) {
    if (reviews.isEmpty) {
      return const DriverRatingSummary(
        averageRating: 0,
        totalReviews: 0,
        distribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    var sum = 0;
    for (final review in reviews) {
      final stars = review.rating.clamp(1, 5);
      distribution[stars] = (distribution[stars] ?? 0) + 1;
      sum += stars;
    }

    return DriverRatingSummary(
      averageRating: sum / reviews.length,
      totalReviews: reviews.length,
      distribution: distribution,
    );
  }

  double fractionForStars(int stars) {
    if (totalReviews == 0) return 0;
    return (distribution[stars] ?? 0) / totalReviews;
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, distribution];
}
