import 'package:codingchallenge_absencelistblocapp/screens/absence_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/absences_bloc.dart';
import 'bloc/absences_event.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => AbsencesBloc()..add(LoadAbsences()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AbsenceListScreen(),
    );
  }
}
