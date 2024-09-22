// Created By Priya Bangera
import 'package:equatable/equatable.dart';

abstract class AbsencesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAbsences extends AbsencesEvent {
  final int page;
  final int limit;

  LoadAbsences({this.page = 1, this.limit = 10});
}
class FilterAbsencesByType extends AbsencesEvent {
  final String type;

  FilterAbsencesByType(this.type);

  @override
  List<Object?> get props => [type];
}

class LoadMoreAbsences extends AbsencesEvent {
  final int page;

  LoadMoreAbsences(this.page);

  @override
  List<Object> get props => [page];
}

class FilterAbsencesByDate extends AbsencesEvent {
  final DateTime startDate;
  final DateTime endDate;

  FilterAbsencesByDate(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}


