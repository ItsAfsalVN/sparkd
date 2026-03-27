import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';
import 'package:sparkd/features/orders/presentation/bloc/sme_order_bloc.dart';
import 'package:sparkd/features/orders/presentation/screens/order_details_screen.dart';
import 'package:sparkd/features/spark/presentation/widgets/spark_order_card.dart';

class SmeOrdersScreen extends StatefulWidget {
  const SmeOrdersScreen({super.key});

  @override
  State<SmeOrdersScreen> createState() => _SmeOrdersScreenState();
}

class _SmeOrdersScreenState extends State<SmeOrdersScreen> {
  String? _selectedStatus;

  final List<(String?, String)> _statusOptions = [
    (null, 'All'),
    ('pendingSparkAcceptance', 'Pending'),
    ('pendingPayment', 'Payment Pending'),
    ('inProgress', 'In Progress'),
    ('delivered', 'Delivered'),
    ('completed', 'Completed'),
    ('cancelled', 'Cancelled'),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return BlocProvider(
      create: (context) => sl<SmeOrderBloc>()
        ..add(
          SmeOrdersRequested(smeId: currentUser!.uid, status: _selectedStatus),
        ),
      child: _OrderScreenContent(
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

class _OrderScreenContent extends StatelessWidget {
  final User? currentUser;
  final String? selectedStatus;
  final List<(String?, String)> statusOptions;
  final Function(String?) onStatusChanged;

  const _OrderScreenContent({
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
        title: Text('Orders', style: textStyles.heading2),
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0.0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
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
                                : colorScheme.onSurface,
                          ),
                        ),
                        selected: selectedStatus == option.$1,
                        onSelected: (sel) {
                          onStatusChanged(sel ? option.$1 : null);
                          context.read<SmeOrderBloc>().add(
                            SmeOrderStatusFilterChanged(
                              status: sel ? option.$1 : null,
                            ),
                          );
                        },
                        backgroundColor: Colors.transparent,
                        selectedColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          // Orders List
          Expanded(
            child: BlocBuilder<SmeOrderBloc, SmeOrderState>(
              builder: (context, state) {
                if (state is SmeOrderBlocLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (state is SmeOrderBlocError) {
                  return Center(
                    child: Column(
                      spacing: 16,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        Text(
                          'Error: ${state.message}',
                          style: textStyles.paragraph,
                        ),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<SmeOrderBloc>().add(
                                SmeOrderRefreshRequested(
                                  smeId: currentUser!.uid,
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

                if (state is SmeOrderBlocLoaded) {
                  if (state.orders.isEmpty) {
                    return Center(
                      child: Column(
                        spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 38,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
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
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: state.orders.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      final smeOrderBloc = context.read<SmeOrderBloc>();
                      return SparkOrderCard(
                        order: order,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (routeContext) => OrderDetailsScreen(
                                order: order,
                                isSme: true,
                                smeOrderBloc: smeOrderBloc,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
