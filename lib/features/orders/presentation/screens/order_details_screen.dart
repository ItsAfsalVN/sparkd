import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_status.dart';
import 'package:sparkd/features/orders/presentation/bloc/sme_order_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:sparkd/features/orders/presentation/bloc/workshop_bloc.dart';
import 'package:sparkd/features/orders/presentation/screens/workshop_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class OrderDetailsScreen extends StatefulWidget {
  final OrderEntity order;
  final bool isSme; // true for SME view, false for Spark view
  final SparkOrdersBloc? sparksOrdersBloc;
  final SmeOrderBloc? smeOrderBloc;

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.isSme,
    this.sparksOrdersBloc,
    this.smeOrderBloc,
  });

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingSparkAcceptance:
        return 'Pending Acceptance';
      case OrderStatus.pendingPayment:
        return 'Pending Payment';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _statusColor(ColorScheme colorScheme, OrderStatus status) {
    switch (status) {
      case OrderStatus.pendingSparkAcceptance:
      case OrderStatus.pendingPayment:
        return colorScheme.tertiary;
      case OrderStatus.inProgress:
        return colorScheme.primary;
      case OrderStatus.delivered:
        return colorScheme.primary;
      case OrderStatus.completed:
        return colorScheme.primary;
      case OrderStatus.cancelled:
        return colorScheme.error;
    }
  }

  String? _getNextActionLabel() {
    switch (widget.order.status) {
      case OrderStatus.pendingSparkAcceptance:
        return widget.isSme ? null : 'Accept Order';
      case OrderStatus.pendingPayment:
        return widget.isSme ? 'Mark as Paid' : null;
      case OrderStatus.inProgress:
        return 'Go to Workshop';
      case OrderStatus.delivered:
        return 'Complete Order';
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return null;
    }
  }

  bool _canRejectOrder() {
    return !widget.isSme &&
        widget.order.status == OrderStatus.pendingSparkAcceptance;
  }

  void _handleOrderAction() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final actionLabel = _getNextActionLabel();
    if (actionLabel == null) return;

    if (actionLabel != 'Go to Workshop') {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm Action'),
          content: Text('Are you sure you want to $actionLabel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performOrderAction();
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    } else {
      _performOrderAction();
    }
  }

  void _performOrderAction() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    if (widget.order.id == null) return;

    // Navigate to workshop
    if (widget.order.status == OrderStatus.inProgress) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (_) => sl<WorkshopBloc>(),
            child: WorkshopScreen(order: widget.order, isSme: widget.isSme),
          ),
        ),
      );
      return;
    }

    if (widget.isSme && widget.order.status == OrderStatus.pendingPayment) {
      if (widget.smeOrderBloc == null) return;
      widget.smeOrderBloc!.add(
        MarkOrderAsPaidEvent(
          orderId: widget.order.id!,
          deliveryTimeInDays: widget.order.gigDeliveryTimeInDays,
        ),
      );
      return;
    }

    // Spark accept order
    if (!widget.isSme &&
        widget.order.status == OrderStatus.pendingSparkAcceptance) {
      if (widget.sparksOrdersBloc == null) return;
      widget.sparksOrdersBloc!.add(AcceptOrderEvent(orderId: widget.order.id!));
    }
  }

  void _showRejectDialog() {
    final TextEditingController reasonController = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (reasonController.text.isEmpty) {
                  showSnackbar(
                    context,
                    'Please enter a reason',
                    SnackBarType.error,
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                _performRejectOrder(reasonController.text);
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _performRejectOrder(String reason) {
    if (widget.order.id == null) return;
    if (widget.sparksOrdersBloc == null) return;

    widget.sparksOrdersBloc!.add(
      RejectOrderEvent(orderId: widget.order.id!, reason: reason),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textStyles;
    final statusColor = _statusColor(colorScheme, widget.order.status);
    final nextActionLabel = _getNextActionLabel();

    final scaffold = Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Image.network(
                    widget.order.gigThumbnail,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          size: 48,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: .5),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(widget.order.gigTitle, style: textStyles.heading3),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/rupee.svg",
                            width: 24,
                            height: 24,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onSurface.withValues(alpha: .8),
                              BlendMode.srcIn,
                            ),
                          ),
                          Text(
                            widget.order.gigPrice.toStringAsFixed(0),
                            style: textStyles.heading2.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: .8,
                              ),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Order Info Container
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: .1),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        spacing: 12,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Created',
                                    style: textStyles.subtext.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .3,
                                      ),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(widget.order.createdAt),
                                    style: textStyles.heading4.copyWith(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: .6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.order.deadline != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Deadline',
                                      style: textStyles.subtext.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: .3,
                                        ),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      timeago.format(widget.order.deadline!),
                                      style: textStyles.heading4.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: .6,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Status',
                                      style: textStyles.subtext.copyWith(
                                        color: colorScheme.onSurface.withValues(
                                          alpha: .3,
                                        ),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      _statusLabel(widget.order.status),
                                      style: textStyles.subtext.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Requirements Section
                  if (widget.order.requirements.isNotEmpty)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: .1),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          spacing: 8,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Requirements',
                              style: textStyles.subtext.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: .3,
                                ),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            ...widget.order.requirements.map((requirement) {
                              return Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: Text(
                                      requirement.description,
                                      style: textStyles.paragraph.copyWith(
                                        fontSize: 14,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  // Rejection Reason (if applicable)
                  if (widget.order.status == OrderStatus.cancelled &&
                      widget.order.rejectionReason != null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: .3),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            Text(
                              'Cancellation Reason',
                              style: textStyles.subtext.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              widget.order.rejectionReason!,
                              style: textStyles.paragraph.copyWith(
                                fontSize: 14,
                                color: colorScheme.error.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox.shrink(),
                // Show buttons based on order status and user role
                if (nextActionLabel != null || _canRejectOrder())
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _canRejectOrder()
                        ? Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _showRejectDialog,
                                  icon: const Icon(Icons.close),
                                  label: const Text('Reject'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.error,
                                    side: BorderSide(
                                      color: _isLoading
                                          ? colorScheme.error.withValues(
                                              alpha: 0.5,
                                            )
                                          : colorScheme.error,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: CustomButton(
                                    borderRadius: BorderRadius.circular(12),
                                    onPressed: _handleOrderAction,
                                    title: nextActionLabel ?? 'Accept Order',
                                    isLoading: _isLoading,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: CustomButton(
                              onPressed: _handleOrderAction,
                              title: nextActionLabel ?? 'Accept Order',
                              isLoading: _isLoading,
                            ),
                          ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.sparksOrdersBloc != null) {
      return BlocProvider<SparkOrdersBloc>.value(
        value: widget.sparksOrdersBloc!,
        child: BlocListener<SparkOrdersBloc, SparkOrdersState>(
          listener: (context, state) {
            if (state is OrderUpdating) {
              setState(() => _isLoading = true);
            } else if (state is OrderUpdateSuccess) {
              setState(() => _isLoading = false);
              showSnackbar(context, state.message, SnackBarType.success);
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.pop(context);
              });
            } else if (state is OrderUpdateError) {
              setState(() => _isLoading = false);
              showSnackbar(context, state.message, SnackBarType.error);
            }
          },
          child: scaffold,
        ),
      );
    }

    if (widget.isSme && widget.smeOrderBloc != null) {
      return BlocProvider<SmeOrderBloc>.value(
        value: widget.smeOrderBloc!,
        child: BlocListener<SmeOrderBloc, SmeOrderState>(
          listener: (context, state) {
            if (state is OrderStatusUpdateInProgress) {
              setState(() => _isLoading = true);
            } else if (state is OrderStatusUpdateSuccess) {
              setState(() => _isLoading = false);
              showSnackbar(
                context,
                'Order updated successfully!',
                SnackBarType.success,
              );
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) Navigator.pop(context);
              });
            } else if (state is OrderStatusUpdateFailure) {
              setState(() => _isLoading = false);
              showSnackbar(context, state.message, SnackBarType.error);
            }
          },
          child: scaffold,
        ),
      );
    }

    return scaffold;
  }
}
