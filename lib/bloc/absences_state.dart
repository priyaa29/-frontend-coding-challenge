// Created By Priya Bangera
import 'package:codingchallenge_absencelistblocapp/models/absencemember_model.dart';
import 'package:equatable/equatable.dart';
import '../models/absence_model.dart';

abstract class AbsencesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AbsencesLoading extends AbsencesState {}

class AbsencesLoaded extends AbsencesState {
  final List<AbsenceWithMember> absences;
  final int totalAbsences;
  final bool hasMore;

  AbsencesLoaded(this.absences, this.totalAbsences, this.hasMore);

  @override
  List<Object> get props => [absences, totalAbsences, hasMore];
}

class AbsencesError extends AbsencesState {
  final String message;

  AbsencesError(this.message);

  @override
  List<Object?> get props => [message];
}

class AbsencesEmpty extends AbsencesState {}
