import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';

class GigModel extends GigEntity {
  const GigModel({
    super.id,
    required super.title,
    required super.description,
    required super.categoryId,
    required super.tags,
    required super.price,
    required super.deliveryTimeInDays,
    required super.maxRevisions,
    required super.requirements,
    super.thumbnailImage,
    super.portfolioImages = const [],
    super.demoVideo,
    super.creatorId,
    super.createdAt,
    super.updatedAt,
    super.isActive = true,
    super.rating = 0.0,
    super.totalReviews = 0,
    super.totalEarnings = 0,
    super.totalViews = 0,
    super.ordersInProgress = 0,
  });

  factory GigModel.fromJson(Map<String, dynamic> json) {
    return GigModel(
      id: json['id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      tags: List<String>.from(json['tags'] ?? []),
      price: (json['price'] as num).toDouble(),
      deliveryTimeInDays: json['deliveryTimeInDays'] as int,
      maxRevisions: json['maxRevisions'] as int,
      requirements:
          (json['requirements'] as List<dynamic>?)
              ?.map((e) => RequirementEntity.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      thumbnailImage: json['thumbnailImage'] as String?,
      portfolioImages: List<String>.from(json['portfolioImages'] ?? []),
      demoVideo: json['demoVideo'] as String?,
      creatorId: json['creatorId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalViews: json['totalViews'] as int? ?? 0,
      ordersInProgress: json['ordersInProgress'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'tags': tags,
      'price': price,
      'deliveryTimeInDays': deliveryTimeInDays,
      'maxRevisions': maxRevisions,
      'requirements': requirements.map((e) => e.toMap()).toList(),
      'thumbnailImage': thumbnailImage,
      'portfolioImages': portfolioImages,
      'demoVideo': demoVideo,
      'creatorId': creatorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'rating': rating,
      'totalReviews': totalReviews,
      'totalEarnings': totalEarnings,
      'totalViews': totalViews,
      'ordersInProgress': ordersInProgress,
    };
  }

  factory GigModel.fromEntity(GigEntity entity) {
    return GigModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      categoryId: entity.categoryId,
      tags: entity.tags,
      price: entity.price,
      deliveryTimeInDays: entity.deliveryTimeInDays,
      maxRevisions: entity.maxRevisions,
      requirements: entity.requirements,
      thumbnailImage: entity.thumbnailImage,
      portfolioImages: entity.portfolioImages,
      demoVideo: entity.demoVideo,
      creatorId: entity.creatorId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
      rating: entity.rating,
      totalReviews: entity.totalReviews,
      totalEarnings: entity.totalEarnings,
      totalViews: entity.totalViews,
      ordersInProgress: entity.ordersInProgress,
    );
  }

  GigEntity toEntity() {
    return GigEntity(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      tags: tags,
      price: price,
      deliveryTimeInDays: deliveryTimeInDays,
      maxRevisions: maxRevisions,
      requirements: requirements,
      thumbnailImage: thumbnailImage,
      portfolioImages: portfolioImages,
      demoVideo: demoVideo,
      creatorId: creatorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
      rating: rating,
      totalReviews: totalReviews,
      totalEarnings: totalEarnings,
      totalViews: totalViews,
      ordersInProgress: ordersInProgress,
    );
  }

  @override
  GigModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    List<String>? tags,
    double? price,
    int? deliveryTimeInDays,
    int? maxRevisions,
    List<String>? deliverables,
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
    return GigModel(
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
