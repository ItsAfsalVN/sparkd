import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sparkd/core/services/service_locator.dart' as sl;
import 'package:sparkd/features/gigs/domain/entities/gig_entity.dart';
import 'package:sparkd/features/gigs/presentation/bloc/edit_gig/edit_gig_bloc.dart';
import 'package:sparkd/features/spark/presentation/screens/edit_gig_screen.dart';

class EditGigProvider extends StatelessWidget {
  final GigEntity gig;

  const EditGigProvider({super.key, required this.gig});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EditGigBloc>(
      create: (context) => sl.sl<EditGigBloc>()..add(EditGigInitialized(gig)),
      child: const EditGigScreen(),
    );
  }
}
