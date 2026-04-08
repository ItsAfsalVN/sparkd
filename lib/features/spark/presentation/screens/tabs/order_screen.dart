import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_bloc.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_event.dart';
import 'package:sparkd/features/orders/presentation/bloc/spark_orders_state.dart';
import 'package:sparkd/features/orders/presentation/screens/order_details_screen.dart';
import 'package:sparkd/features/orders/presentation/widgets/order_card.dart';

class SparkOrdersScreen extends StatefulWidget {
  const SparkOrdersScreen({super.key});

  @override
  State<SparkOrdersScreen> createState() => _SparkOrdersScreenState();
}

class _SparkOrdersScreenState extends State<SparkOrdersScreen> {
  String? _selectedStatus;

  final List<(String?, String)> _statusOptions = [
    (null, 'All'),
    ('pendingSparkAcceptance', 'Pending'),
    ('pendingPayment', 'Payment Pending'),
    ('inProgress', 'In Progress'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) => sl<SparkOrdersBloc>()
        ..add(
          LoadSparkOrdersEvent(
            sparkId: currentUser!.uid,
            status: _selectedStatus,
          ),
        ),
      child: _SparkOrdersScreenContent(
        currentUser: currentUser,
        selectedStatus: _selectedStatus,
        statusOptions: _statusOptions,
        onStatusChanged: (status) {
          setState(() {
            _selectedStatus = status;
          });
        },
      ),
    );
  }
}

class _SparkOrdersScreenContent extends StatelessWidget {
  final User? currentUser;
  final String? selectedStatus;
  final List<(String?, String)> statusOptions;
  final Function(String?) onStatusChanged;

  const _SparkOrdersScreenContent({
    required this.currentUser,
    required this.selectedStatus,
    required this.statusOptions,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("Orders", style: textStyles.heading2),
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<SparkOrdersBloc, SparkOrdersState>(
        builder: (context, state) {
          if (state is SparkOrdersLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          if (state is SparkOrdersError) {
            return Center(
              child: Column(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  Text('Error: ${state.message}', style: textStyles.paragraph),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SparkOrdersBloc>().add(
                          LoadSparkOrdersEvent(
                            sparkId: currentUser!.uid,
                            status: selectedStatus,
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SparkOrdersLoaded) {
            final hasPendingOrders = state.pendingOrders.isNotEmpty;

            return Column(
              spacing: 12,
              children: [
                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: statusOptions
                        .map(
                          (option) => FilterChip(
                            checkmarkColor: colorScheme.onPrimary,
                            label: Text(
                              option.$2,
                              style: TextStyle(
                                color: selectedStatus == option.$1
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurface.withValues(
                                        alpha: .6,
                                      ),
                              ),
                            ),
                            selected: selectedStatus == option.$1,
                            onSelected: (sel) {
                              onStatusChanged(sel ? option.$1 : null);
                              context.read<SparkOrdersBloc>().add(
                                SparkOrderStatusFilterChanged(
                                  status: sel ? option.$1 : null,
                                ),
                              );
                            },
                            backgroundColor: Colors.transparent,
                            selectedColor: colorScheme.primary,
                            side: BorderSide.none,
                          ),
                        )
                        .toList(),
                  ),
                ),

                // Banner for pending orders
                if (hasPendingOrders && selectedStatus == null)
                  _OrderNotificationBanner(
                    pendingCount: state.pendingOrders.length,
                    onTap: () {
                      final bloc = context.read<SparkOrdersBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (routeContext) => OrderDetailsScreen(
                            order: state.pendingOrders.first,
                            isSme: false,
                            sparksOrdersBloc: bloc,
                          ),
                        ),
                      );
                    },
                  ),
                // Orders list
                Expanded(
                  child: state.orders.isEmpty
                      ? Center(
                          child: Column(
                            spacing: 4,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 38,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              Text(
                                'No Orders',
                                style: textStyles.heading4.copyWith(
                                  height: 1,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: state.orders.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = state.orders[index];
                            final bloc = context.read<SparkOrdersBloc>();
                            return OrderCard(
                              order: order,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (routeContext) =>
                                        OrderDetailsScreen(
                                          order: order,
                                          isSme: false,
                                          sparksOrdersBloc: bloc,
                                        ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderNotificationBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onTap;

  const _OrderNotificationBanner({
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textStyles;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.surface.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Row(
            spacing: 16,
            children: [
              Icon(
                Icons.notifications_active,
                color: colorScheme.primary,
                size: 24,
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount New Request${pendingCount > 1 ? 's' : ''} Pending',
                      style: textStyles.heading4.copyWith(
                        height: 1,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Tap to review and respond',
                      style: textStyles.paragraph.copyWith(
                        height: 1,
                        fontSize: 12,
                        color: colorScheme.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: colorScheme.primary.withValues(alpha: 0.7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
