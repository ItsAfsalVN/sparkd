import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/presentation/widgets/custom_button.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/core/utils/snackbar_helper.dart';
import 'package:sparkd/core/utils/user_helper.dart';
import 'package:sparkd/features/gigs/domain/entities/requirement_entity.dart';
import 'package:sparkd/features/orders/domain/entities/order_entity.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class SparkOrderRequestsScreen extends StatelessWidget {
  const SparkOrderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) =>
          sl<SparkOrdersBloc>()
            ..add(LoadSparkOrdersEvent(sparkId: currentUser!.uid)),
      child: const _SparkOrderRequestsContent(),
    );
  }
}

class _SparkOrderRequestsContent extends StatelessWidget {
  const _SparkOrderRequestsContent();

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text('Order Requests', style: textStyles.heading3),
      ),
      body: BlocConsumer<SparkOrdersBloc, SparkOrdersState>(
        listener: (context, state) {
          if (state is OrderUpdateSuccess) {
            showSnackbar(context, state.message, SnackBarType.success);
            // Reload orders
            final currentUser = FirebaseAuth.instance.currentUser;
            context.read<SparkOrdersBloc>().add(
              LoadSparkOrdersEvent(sparkId: currentUser!.uid),
            );
          } else if (state is OrderUpdateError) {
            showSnackbar(context, state.message, SnackBarType.error);
          }
        },
        builder: (context, state) {
          if (state is SparkOrdersLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is SparkOrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}', style: textStyles.paragraph),
                ],
              ),
            );
          }

          if (state is SparkOrdersLoaded) {
            if (state.pendingOrders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pending requests',
                      style: textStyles.heading4.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.pendingOrders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = state.pendingOrders[index];
                return _OrderRequestCard(order: order);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderRequestCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderRequestCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gig info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order.gigThumbnail,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_not_supported,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.gigTitle,
                        style: textStyles.heading4,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${order.gigPrice.toStringAsFixed(0)}',
                        style: textStyles.heading3.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SME info
                FutureBuilder<String?>(
                  future: UserHelper.getUserName(order.smeID),
                  builder: (context, snapshot) {
                    return Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Client: ${snapshot.data ?? 'Loading...'}',
                          style: textStyles.paragraph.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),

                // Time ago
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(order.createdAt),
                      style: textStyles.subtext.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Requirements
                Text(
                  'Requirements:',
                  style: textStyles.subtext.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ...order.requirements.map((requirement) {
                  final response =
                      order.requirementResponses[requirement.description];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                requirement.type == RequirementType.text
                                    ? Icons.text_fields
                                    : Icons.attach_file,
                                size: 16,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  requirement.description,
                                  style: textStyles.subtext.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (response != null)
                            Text(
                              response['type'] == 'text'
                                  ? response['value']
                                  : 'File uploaded',
                              style: textStyles.paragraph.copyWith(
                                fontSize: 14.0,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showRejectDialog(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        onPressed: () {
                          context.read<SparkOrdersBloc>().add(
                            AcceptOrderEvent(orderId: order.id!),
                          );
                        },
                        title: 'Accept',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              hintText: 'Enter rejection reason (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SparkOrdersBloc>().add(
                  RejectOrderEvent(
                    orderId: order.id!,
                    reason: reasonController.text.isEmpty
                        ? 'Not available at this time'
                        : reasonController.text,
                  ),
                );
                Navigator.pop(dialogContext);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
