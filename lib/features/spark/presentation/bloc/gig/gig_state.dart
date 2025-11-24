part of 'gig_bloc.dart';

class GigState extends Equatable {
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
  final List<String> requirements;
  final DeliveryTypes? deliveryType;
  final List<String> postGigInstructions;
  final FormStatus? status;

  const GigState({
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
    this.postGigInstructions = const [],
    this.status = FormStatus.initial,
  });

  GigState copyWith({
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
    List<String>? requirements,
    DeliveryTypes? deliveryType,
    List<String>? postGigInstructions,
    FormStatus? status,
  }) {
    return GigState(
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
      postGigInstructions: postGigInstructions ?? this.postGigInstructions,
      status: status ?? this.status,
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
    demoVideo,
    requirements,
    deliveryType,
    postGigInstructions,
    status,
  ];
}
