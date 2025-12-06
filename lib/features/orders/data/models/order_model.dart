import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';

class OrderModel {
  final OrderEntity order;

  OrderModel({required this.order});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      order: OrderEntity(
        id: json["id"] as String?,
        createdAt: DateTime.parse(json["createdAt"] as String),
        gigID: json["gigID"] as String,
        gigPrice: (json["gigPrice"] as num).toDouble(),
        gigThumbnail: json["gigThumbnail"] as String,
        gigTitle: json["gigTitle"] as String,
        requirements: (json["requirements"] as List)
            .map((r) => RequirementEntity.fromMap(r as Map<String, dynamic>))
            .toList(),
        requirementResponses: Map<String, dynamic>.from(
          json["requirementResponses"] as Map,
        ),
        smeID: json["smeID"] as String,
        sparkID: json["sparkID"] as String,
        status: _getStatusFromString(json["status"] as String),
        deadline: json["deadline"] != null
            ? DateTime.parse(json["deadline"] as String)
            : null,
        paymentID: json["paymentID"] as String?,
        rejectionReason: json["rejectionReason"] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return order.toMap();
  }

  static OrderStatus _getStatusFromString(String status) {
    switch (status) {
      case 'pendingSparkAcceptance':
        return OrderStatus.pendingSparkAcceptance;
      case 'pendingPayment':
        return OrderStatus.pendingPayment;
      case 'inProgress':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pendingSparkAcceptance;
    }
  }
}
