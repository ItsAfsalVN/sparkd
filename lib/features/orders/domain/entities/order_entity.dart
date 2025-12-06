import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';

class OrderEntity {
  final String? id;
  final String gigID;
  final String smeID;
  final String sparkID;

  final String gigTitle;
  final double gigPrice;
  final String gigThumbnail;

  final List<RequirementEntity> requirements;
  final Map<String, dynamic>
  requirementResponses; // Stores text responses and file URLs
  final OrderStatus status;
  final DateTime createdAt;

  final DateTime? deadline;
  final String? paymentID;
  final String? rejectionReason;

  const OrderEntity({
    this.id,
    required this.gigID,
    required this.smeID,
    required this.sparkID,
    required this.gigTitle,
    required this.gigPrice,
    required this.gigThumbnail,
    required this.requirements,
    required this.requirementResponses,
    required this.status,
    required this.createdAt,
    this.deadline,
    this.paymentID,
    this.rejectionReason,
  });

  OrderEntity copyWith({
    String? id,
    String? gigID,
    String? smeID,
    String? sparkID,
    String? gigTitle,
    double? gigPrice,
    String? gigThumbnail,
    List<RequirementEntity>? requirements,
    Map<String, dynamic>? requirementResponses,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? deadline,
    String? paymentID,
    String? rejectionReason,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      gigID: gigID ?? this.gigID,
      smeID: smeID ?? this.smeID,
      sparkID: sparkID ?? this.sparkID,
      gigTitle: gigTitle ?? this.gigTitle,
      gigPrice: gigPrice ?? this.gigPrice,
      gigThumbnail: gigThumbnail ?? this.gigThumbnail,
      requirements: requirements ?? this.requirements,
      requirementResponses: requirementResponses ?? this.requirementResponses,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      paymentID: paymentID ?? this.paymentID,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gigID': gigID,
      'smeID': smeID,
      'sparkID': sparkID,
      'gigTitle': gigTitle,
      'gigPrice': gigPrice,
      'gigThumbnail': gigThumbnail,
      'requirements': requirements.map((r) => r.toMap()).toList(),
      'requirementResponses': requirementResponses,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'paymentID': paymentID,
      'rejectionReason': rejectionReason,
    };
  }
}
