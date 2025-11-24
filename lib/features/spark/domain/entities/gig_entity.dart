import 'package:equatable/equatable.dart';
import 'package:sparkd/core/utils/delivery_types.dart';

class GigEntity extends Equatable {
  final String? id;
  final String title;
  final String description;
  final String categoryId;
  final List<String> tags;
  final double price;
  final int deliveryTimeInDays;
  final int maxRevisions;
  final List<String> deliverables;
  final List<String> requirements;
  final DeliveryTypes deliveryType;
  final String? thumbnailImage;
  final List<String> portfolioImages;
  final String? demoVideo;
  final String? creatorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const GigEntity({
    this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.tags,
    required this.price,
    required this.deliveryTimeInDays,
    required this.maxRevisions,
    required this.deliverables,
    required this.requirements,
    required this.deliveryType,
    this.thumbnailImage,
    this.portfolioImages = const [],
    this.demoVideo,
    this.creatorId,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
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
    deliverables,
    requirements,
    deliveryType,
    thumbnailImage,
    portfolioImages,
    demoVideo,
    creatorId,
    createdAt,
    updatedAt,
    isActive,
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
    return GigEntity(
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
