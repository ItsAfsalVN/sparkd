part of 'edit_gig_bloc.dart';

class EditGigState extends Equatable {
  final String? gigId;
  final String? creatorId;
  final DateTime? createdAt;
  final String title;
  final SkillEntity? category;
  final List<String> tags;
  final String description;
  final double price;
  final int deliveryTimeInDays;
  final int revisions;
  final List<String> deliverables;
  final String? thumbnailImage;
  final List<String> galleryImages;
  final String? demoVideo;
  final List<RequirementEntity> requirements;
  final DeliveryTypes? deliveryType;
  final FormStatus? status;

  const EditGigState({
    this.gigId,
    this.creatorId,
    this.createdAt,
    this.title = '',
    this.category,
    this.tags = const [],
    this.description = '',
    this.price = 0.0,
    this.deliveryTimeInDays = 0,
    this.revisions = 0,
    this.deliverables = const [],
    this.thumbnailImage,
    this.galleryImages = const [],
    this.demoVideo,
    this.requirements = const [],
    this.deliveryType,
    this.status = FormStatus.initial,
  });

  EditGigState copyWith({
    String? gigId,
    String? creatorId,
    DateTime? createdAt,
    String? title,
    SkillEntity? category,
    List<String>? tags,
    String? description,
    double? price,
    int? deliveryTimeInDays,
    int? revisions,
    List<String>? deliverables,
    String? thumbnailImage,
    List<String>? galleryImages,
    String? demoVideo,
    List<RequirementEntity>? requirements,
    DeliveryTypes? deliveryType,
    FormStatus? status,
  }) {
    return EditGigState(
      gigId: gigId ?? this.gigId,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      price: price ?? this.price,
      deliveryTimeInDays: deliveryTimeInDays ?? this.deliveryTimeInDays,
      revisions: revisions ?? this.revisions,
      deliverables: deliverables ?? this.deliverables,
      thumbnailImage: thumbnailImage ?? this.thumbnailImage,
      galleryImages: galleryImages ?? this.galleryImages,
      demoVideo: demoVideo ?? this.demoVideo,
      requirements: requirements ?? this.requirements,
      deliveryType: deliveryType ?? this.deliveryType,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    gigId,
    creatorId,
    createdAt,
    title,
    category,
    tags,
    description,
    price,
    deliveryTimeInDays,
    revisions,
    deliverables,
    thumbnailImage,
    galleryImages,
    demoVideo,
    requirements,
    deliveryType,
    status,
  ];
}
