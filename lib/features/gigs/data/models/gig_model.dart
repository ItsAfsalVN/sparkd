import 'package:sparkd/core/utils/delivery_types.dart';
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';

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
    required super.deliverables,
    required super.requirements,
    required super.deliveryType,
    super.thumbnailImage,
    super.portfolioImages = const [],
    super.demoVideo,
    super.creatorId,
    super.createdAt,
    super.updatedAt,
    super.isActive = true,
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
      deliverables: List<String>.from(json['deliverables'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      deliveryType: _parseDeliveryType(json['deliveryType']),
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
      'deliverables': deliverables,
      'requirements': requirements,
      'deliveryType': _deliveryTypeToString(deliveryType),
      'thumbnailImage': thumbnailImage,
      'portfolioImages': portfolioImages,
      'demoVideo': demoVideo,
      'creatorId': creatorId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
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
      deliverables: entity.deliverables,
      requirements: entity.requirements,
      deliveryType: entity.deliveryType,
      thumbnailImage: entity.thumbnailImage,
      portfolioImages: entity.portfolioImages,
      demoVideo: entity.demoVideo,
      creatorId: entity.creatorId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
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
      deliverables: deliverables,
      requirements: requirements,
      deliveryType: deliveryType,
      thumbnailImage: thumbnailImage,
      portfolioImages: portfolioImages,
      demoVideo: demoVideo,
      creatorId: creatorId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }

  static DeliveryTypes _parseDeliveryType(dynamic value) {
    if (value == null) return DeliveryTypes.file;

    switch (value.toString().toLowerCase()) {
      case 'file':
        return DeliveryTypes.file;
      case 'servicecompletion':
      case 'service_completion':
        return DeliveryTypes.serviceCompletion;
      default:
        return DeliveryTypes.file;
    }
  }

  static String _deliveryTypeToString(DeliveryTypes type) {
    switch (type) {
      case DeliveryTypes.file:
        return 'file';
      case DeliveryTypes.serviceCompletion:
        return 'serviceCompletion';
    }
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
    List<String>? requirements,
    DeliveryTypes? deliveryType,
    String? thumbnailImage,
    List<String>? portfolioImages,
    String? demoVideo,
    String? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
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
      deliverables: deliverables ?? this.deliverables,
      requirements: requirements ?? this.requirements,
      deliveryType: deliveryType ?? this.deliveryType,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      portfolioImages: portfolioImages ?? this.portfolioImages,
      demoVideo: demoVideo ?? this.demoVideo,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
