// Created By Priya Bangera

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/absences_bloc.dart';
import '../bloc/absences_event.dart';
import '../bloc/absences_state.dart';
import '../models/absencemember_model.dart';


class AbsenceListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AbsencesBloc()..add(LoadAbsences()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Absences'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          elevation: 2,
        ),
        body: Column(
          children: [
            FilterSection(),
            Expanded(child: AbsenceList()),
          ],
        ),
      ),
    );
  }
}

class FilterSection extends StatefulWidget {
  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  DateTime? startDate;
  DateTime? endDate;
  String selectedType = 'Sickness';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Absences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Absence Type Dropdown
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              labelText: 'Absence Type',
              border: OutlineInputBorder(),
            ),
            items: ['Sickness', 'Vacation', 'Other'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedType = newValue!;
              });
            },
          ),
          SizedBox(height: 10),
          // Start Date Picker
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        startDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      startDate == null
                          ? 'Start Date'
                          : 'From: ${DateFormat('yyyy-MM-dd').format(startDate!)}',
                      style: TextStyle(color: startDate == null ? Colors.grey : Colors.black),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        endDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      endDate == null
                          ? 'End Date'
                          : 'To: ${DateFormat('yyyy-MM-dd').format(endDate!)}',
                      style: TextStyle(color: endDate == null ? Colors.grey : Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // context.read<AbsencesBloc>().add(FilterAbsencesByDate(startDate, endDate));
            },
            child: Text('Apply Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              minimumSize: Size(double.infinity, 40), // Full width button
            ),
          ),
        ],
      ),
    );
  }
}

class AbsenceList extends StatefulWidget {
  @override
  _AbsenceListState createState() => _AbsenceListState();
}

class _AbsenceListState extends State<AbsenceList> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
  //  _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<AbsencesBloc>().add(LoadMoreAbsences(_currentPage + 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AbsencesBloc, AbsencesState>(
      builder: (context, state) {
        if (state is AbsencesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is AbsencesLoaded) {
          _currentPage = (state.absences.length ~/ 10) + 1;

          // Group the absences by member name
          final groupedAbsences = groupBy(state.absences, (AbsenceWithMember awm) => awm.memberName);
          final sortedMemberNames = groupedAbsences.keys.toList()..sort();

          return Column(
            children: [
              // Padding(
              //   padding: const EdgeInsets.all(8.0),
              //   child: Text(
              //     'Total Absences: ${state.totalAbsences}',
              //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              //   ),
              // ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: sortedMemberNames.length + (state.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= sortedMemberNames.length) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final memberName = sortedMemberNames[index];
                    final memberAbsences = groupedAbsences[memberName]!;

                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ExpansionTile(
                        title: Text('Member: $memberName', style: TextStyle(fontWeight: FontWeight.bold)),
                        children: memberAbsences.map((absenceWithMember) {
                          final absence = absenceWithMember.absence;
                          return ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.blueAccent),
                                  SizedBox(width: 8),
                                  Text(
                                    'Absence ID: ${absence.id}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.label_important, color: Colors.orangeAccent), // Icon for Type
                                      SizedBox(width: 8),
                                      Text(
                                        'Type: ${absence.type}',
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8), // Space between rows
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(
                                        'From: ${DateFormat('yyyy-MM-dd').format(absence.startDate)} To: ${DateFormat('yyyy-MM-dd').format(absence.endDate)}',
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8), // Space between rows
                                  if (absence.memberNote.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.note, color: Colors.blueAccent), // Icon for Member Note
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Member Note: ${absence.memberNote}',
                                            style: TextStyle(fontSize: 14, color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (absence.memberNote.isNotEmpty) SizedBox(height: 8),


                                  if (absence.admitterNote.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(Icons.note_alt_outlined, color: Colors.redAccent),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Admitter Note: ${absence.admitterNote}',
                                            style: TextStyle(fontSize: 14, color: Colors.black54),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );

                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else if (state is AbsencesEmpty) {
          return Center(child: Text('No absences found.'));
        } else if (state is AbsencesError) {
          return Center(child: Text(state.message));
        } else {
          return SizedBox.shrink();
        }
      },
    );
  }
}
