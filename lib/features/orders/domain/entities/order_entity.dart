import 'package:cloud_firestore/cloud_firestore.dart';
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

  final DateTime? paidAt;
  final DateTime? deliveredAt;
  

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
    this.paidAt,
    this.deliveredAt,
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
    DateTime? paidAt,
    DateTime? deliveredAt,
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
      paidAt: paidAt ?? this.paidAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
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
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'paymentID': paymentID,
      'rejectionReason': rejectionReason,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
    };
  }
}
