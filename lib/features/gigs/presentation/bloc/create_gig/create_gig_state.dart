part of 'create_gig_bloc.dart';

class CreateGigState extends Equatable {
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
  final List<String> postGigInstructions;
  final List<GigEntity> userGigs;
  final FormStatus? status;

  const CreateGigState({
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
    this.userGigs = const [],
    this.status = FormStatus.initial,
  });

  CreateGigState copyWith({
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
    List<String>? postGigInstructions,
    List<GigEntity>? userGigs,
    FormStatus? status,
  }) {
    return CreateGigState(
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
      userGigs: userGigs ?? this.userGigs,
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
    userGigs,
    status,
  ];
}
