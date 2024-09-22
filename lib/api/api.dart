// Created By Priya Bangera
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

import '../models/absence_model.dart';
import '../models/absencemember_model.dart';

// Asset paths
const absencesPath = 'assets/json_files/absences.json';
const membersPath = 'assets/json_files/members.json';

// Function to read JSON file from assets
Future<List<dynamic>> readJsonFile(String path) async {
  try {
    // Use rootBundle to load assets
    String jsonString = await rootBundle.loadString(path);
    final data = jsonDecode(jsonString);

    // Validate the JSON structure
    if (data == null || !data.containsKey('payload')) {
      throw Exception("Invalid JSON format");
    }

    return data['payload'] as List<dynamic>;
  } catch (e) {
    print("Error decoding JSON file: $e");
    throw Exception("Failed to decode JSON file");
  }
}

Future<List<AbsenceWithMember>> loadAbsencesWithMembers() async {
  final List<dynamic> absenceData = await absences();  // Fetch absences data
  final List<dynamic> memberData = await members();    // Fetch members data

  // Create a map for members with crewId as the key and name as the value
  final Map<String, String> memberMap = {
    for (var member in memberData) member['crewId']: member['name']
  };

  // Combine absence data with member names
  return absenceData.map((absenceJson) {
    final absence = Absence.fromJson(absenceJson);
    final memberName = memberMap[absence.crewId] ?? 'Unknown Member';
    return AbsenceWithMember(absence: absence, memberName: memberName);
  }).toList();
}

// Absences function
Future<List<dynamic>> absences() async {
  print('Loading absences from $absencesPath');
  return await readJsonFile(absencesPath);
}

// Members function
Future<List<dynamic>> members() async {
  print('Loading members from $membersPath');
  return await readJsonFile(membersPath);
}

