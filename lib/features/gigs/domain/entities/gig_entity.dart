import 'package:equatable/equatable.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';

class GigEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String categoryId;
  final List<String> tags;
  final double price;
  final int deliveryTimeInDays;
  final int maxRevisions;
  final List<RequirementEntity> requirements;
  final String? thumbnailImage;
  final List<String> portfolioImages;
  final String? demoVideo;
  final String? creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final double rating;
  final int totalReviews;
  final double totalEarnings;
  final int totalViews;
  final int ordersInProgress;

  const GigEntity({
    this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.tags,
    required this.price,
    required this.deliveryTimeInDays,
    required this.maxRevisions,
    required this.requirements,
    this.thumbnailImage,
    this.portfolioImages = const [],
    this.demoVideo,
    this.creatorId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalEarnings = 0,
    this.totalViews = 0,
    this.ordersInProgress = 0,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categoryId,
    tags,
    price,
    deliveryTimeInDays,
    maxRevisions,
    requirements,
    thumbnailImage,
    portfolioImages,
    demoVideo,
    creatorId,
    createdAt,
    updatedAt,
    isActive,
    rating,
    totalReviews,
    totalEarnings,
    totalViews,
    ordersInProgress,
  ];

  GigEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    List<String>? tags,
    double? price,
    int? deliveryTimeInDays,
    int? maxRevisions,
    List<RequirementEntity>? requirements,
    String? thumbnailImage,
    List<String>? portfolioImages,
    String? demoVideo,
    String? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    double? rating,
    int? totalReviews,
    double? totalEarnings,
    int? totalViews,
    int? ordersInProgress,
  }) {
    return GigEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      price: price ?? this.price,
      deliveryTimeInDays: deliveryTimeInDays ?? this.deliveryTimeInDays,
      maxRevisions: maxRevisions ?? this.maxRevisions,
      requirements: requirements ?? this.requirements,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      demoVideo: demoVideo ?? this.demoVideo,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalViews: totalViews ?? this.totalViews,
      ordersInProgress: ordersInProgress ?? this.ordersInProgress,
    );
  }
}
