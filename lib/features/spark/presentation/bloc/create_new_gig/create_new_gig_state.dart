part of 'create_new_gig_bloc.dart';

class CreateNewGigState extends Equatable {
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
  final List<String> requirements;
  final DeliveryTypes? deliveryType; 
  final List<String> postGigInstructions;
  final FormStatus? status;

  const CreateNewGigState({
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
    this.requirements = const [],
    this.deliveryType,
    this.postGigInstructions = const [],
    this.status = FormStatus.initial
  });

  CreateNewGigState copyWith({
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
    List<String>? requirements,
    DeliveryTypes? deliveryType,
    List<String>? postGigInstructions,
    FormStatus? status,
  }) {
    return CreateNewGigState(
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
      requirements: requirements ?? this.requirements,
      deliveryType: deliveryType ?? this.deliveryType,
      postGigInstructions: postGigInstructions ?? this.postGigInstructions,
      status: status ?? this.status
    );
  }

  @override
  List<Object?> get props => [
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
    requirements,
    deliveryType,
    postGigInstructions,
    status
  ];
}
