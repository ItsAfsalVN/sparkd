import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';

class OrderModel {
  static final Logger _logger = Logger();
  final OrderEntity order;

  OrderModel({required this.order});

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      order: OrderEntity(
        id: json["id"] as String?,
        createdAt: _parseDateTime(json["createdAt"]),
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
            ? _parseDateTime(json["deadline"])
            : null,
        paymentID: json["paymentID"] as String?,
        rejectionReason: json["rejectionReason"] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return order.toMap();
  }

  static DateTime _parseDateTime(dynamic value) {
    try {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      }
      _logger.e(
        'Invalid date format - value type: ${value.runtimeType}, value: $value',
      );
      throw Exception('Invalid date format: ${value.runtimeType}');
    } catch (e) {
      _logger.e('Error parsing date: $e, value: $value');
      rethrow;
    }
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
