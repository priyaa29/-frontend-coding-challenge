// Created By Priya Bangera
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/absencemember_model.dart';
import 'absences_event.dart';
import 'absences_state.dart';
import '../api/api.dart';
import '../models/absence_model.dart';

class AbsencesBloc extends Bloc<AbsencesEvent, AbsencesState> {
  int _currentPage = 1;
  final int _pageSize = 10;

  AbsencesBloc() : super(AbsencesLoading()) {
    on<LoadAbsences>((event, emit) async {
      try {

        final List<dynamic> absenceData = await absences();
        final List<dynamic> memberData = await members();

        print("Absence Data (first 10): ${absenceData.take(10)}");
        print("Member Data (first 10): ${memberData.take(10)}");

        final Map<String, dynamic> memberMap = {
          for (var member in memberData) member['userId'].toString(): member
        };

        print("Member Map by userId: $memberMap");

        final List<Absence> absencesList = absenceData.map((e) => Absence.fromJson(e)).toList();

        final startIndex = (event.page - 1) * event.limit;
        final endIndex = startIndex + event.limit;
        final paginatedAbsences = absencesList.sublist(
          startIndex,
          endIndex > absencesList.length ? absencesList.length : endIndex,
        );

        final hasMore = endIndex < absencesList.length;
        final total = absencesList.length;

        // If no absences are found, emit AbsencesEmpty state
        if (paginatedAbsences.isEmpty) {
          emit(AbsencesEmpty());
        } else {
          final List<AbsenceWithMember> absencesWithMembers = paginatedAbsences.map((absence) {
            print('Absence ID: ${absence.id}, Full Absence Data: $absence');

            final member = memberMap[absence.userId.toString()];

            if (member != null) {
              final memberName = member['name'];
              print('Mapped Member Name: $memberName for Absence ID: ${absence.id}');
              return AbsenceWithMember(absence: absence, memberName: memberName);
            } else {
              print('Warning: No member found for Absence ID: ${absence.id}, User ID: ${absence.userId}');
              return AbsenceWithMember(absence: absence, memberName: 'Unknown Member');
            }
          }).toList();

          emit(AbsencesLoaded(absencesWithMembers, total, hasMore));
        }
      } catch (e, stackTrace) {
        print('Error loading absences: $e');
        print('StackTrace: $stackTrace');
        emit(AbsencesError('Failed to load absences.'));
      }
    });
    on<LoadMoreAbsences>((event, emit) async {
      if (state is AbsencesLoaded) {
        try {
          final List<dynamic> absenceData = await absences();
          print('Absence Data: $absenceData');
          final List<dynamic> memberData = await members();

          print('Absence Data: $absenceData');
          print('Member Data: $memberData');

          final Map<String, String> memberMap = {
            for (var member in memberData) member['crewId']: member['name']
          };

          if (absenceData.isEmpty) {
            emit(AbsencesEmpty());
            return;
          }

          // final List<Absence> absencesList = absenceData.map((e) {
          //   try {
          //     return Absence.fromJson(e);
          //   } catch (error) {
          //     print('Failed to parse Absence: $error, JSON: $e');
          //     return null; // Handle parsing error
          //   }
          // }).whereType<Absence>().toList();

          final absencesList = absenceData.map((e) {
            try {
              return Absence.fromJson(e);
            } catch (error) {
              print('Error parsing absence: $e, error: $error');
              return null; // or handle it differently
            }
          }).whereType<Absence>().toList();


          if (absencesList.isEmpty) {
            emit(AbsencesEmpty());
            return;
          }

          final startIndex = _currentPage * _pageSize;
          final endIndex = startIndex + _pageSize;
          final paginatedAbsences = absencesList.sublist(
            startIndex,
            endIndex > absencesList.length ? absencesList.length : endIndex,
          );

          if (paginatedAbsences.isNotEmpty) {
            _currentPage++;
            final loadedState = state as AbsencesLoaded;

            final absencesWithMembers = paginatedAbsences.map((absence) {
              final memberName = memberMap[absence.crewId] ?? 'Unknown Member';
              return AbsenceWithMember(absence: absence, memberName: memberName);
            }).toList();

            emit(AbsencesLoaded(
              List.from(loadedState.absences)..addAll(absencesWithMembers),
              absencesList.length,
              endIndex < absencesList.length,
            ));
          }
        } catch (e, stackTrace) {
          print('Error Failed to load absences: $e');
          print('StackTrace: $stackTrace');
          emit(AbsencesError('Failed to load absences.'));
        }
      }
    });
    on<FilterAbsencesByType>((event, emit) async {
      try {
        final List<dynamic> absenceData = await absences();
        final List<dynamic> memberData = await members();

        final Map<String, String> memberMap = {
          for (var member in memberData) member['crewId']: member['name']
        };

        List<AbsenceWithMember> filteredAbsences = [];

        for (var e in absenceData) {
          try {
            final absence = Absence.fromJson(e);
            if (absence.type == event.type) {
              final memberName = memberMap[absence.crewId] ?? 'Unknown Member';
              filteredAbsences.add(AbsenceWithMember(absence: absence, memberName: memberName));
            }
          } catch (error) {
            print('Error parsing absence: $e, error: $error');
          }
        }

        if (filteredAbsences.isEmpty) {
          emit(AbsencesEmpty());
        } else {
          emit(AbsencesLoaded(filteredAbsences, filteredAbsences.length, false));
        }
      } catch (e, stackTrace) {
        print('Error Failed to load absences: $e');
        print('StackTrace: $stackTrace');
        emit(AbsencesError('Failed to filter absences by type.'));
      }
    });
    on<FilterAbsencesByDate>((event, emit) async {
      try {
        final List<dynamic> absenceData = await absences();
        final List<dynamic> memberData = await members();

        final Map<String, String> memberMap = {
          for (var member in memberData) member['crewId']: member['name']
        };

        final filteredAbsences = absenceData
            .map((e) => Absence.fromJson(e))
            .where((absence) {
          final absenceStartDate = DateTime.parse(absence.startDate as String);
          final absenceEndDate = DateTime.parse(absence.endDate as String);
          return absenceStartDate.isAfter(event.startDate) &&
              absenceEndDate.isBefore(event.endDate);
        })
            .map((absence) {
          final memberName = memberMap[absence.crewId] ?? 'Unknown Member';
          return AbsenceWithMember(absence: absence, memberName: memberName);
        }).toList();

        if (filteredAbsences.isEmpty) {
          emit(AbsencesEmpty());
        } else {
          emit(AbsencesLoaded(filteredAbsences, filteredAbsences.length, false));
        }
      } catch (e) {
        emit(AbsencesError('Failed to filter absences by date.'));
      }
    });
  }
}




