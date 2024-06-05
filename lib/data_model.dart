import 'package:flutter/material.dart';

class Exam {
  final String name;
  final String course;
  final int credits;
  final DateTime date;
  final TimeOfDay time;
  final String examType;
  final String professor;
  final int? grade;
  final List<String> categories;
  final String diary;

  Exam({
    required this.name,
    required this.course,
    required this.credits,
    required this.date,
    required this.time,
    required this.examType,
    required this.professor,
    this.grade,
    required this.categories,
    required this.diary,
  });

  Map<String, dynamic> toMap() {
    return {
      'Nome': name,
      'Corso_di_studi': course,
      'CFU': credits,
      'Data': date.toIso8601String(),
      'Ora': '${time.hour}:${time.minute}',
      'Tipologia': examType,
      'Docente': professor,
      'Voto': grade,
      'Categoria': categories.join(','),
      'Diario': diary,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTimeOfDay(String time) {
      final timeParts = time.split(':');
      if (timeParts.length == 2) {
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);
        if (hour != null &&
            hour >= 0 &&
            hour < 24 &&
            minute != null &&
            minute >= 0 &&
            minute < 60) {
          return TimeOfDay(hour: hour, minute: minute);
        }
      }
      return const TimeOfDay(hour: 0, minute: 0);
    }

    int? parseGrade(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value.toString());
    }

    return Exam(
      name: map['Nome'],
      course: map['Corso_di_studi'],
      credits: map['CFU'],
      date: DateTime.parse(map['Data']),
      time: parseTimeOfDay(map['Ora']),
      examType: map['Tipologia'],
      professor: map['Docente'],
      grade: parseGrade(map['Voto']),
      categories: map['Categoria']?.split(',') ?? [],
      diary: map['Diario'],
    );
  }

  String get effectiveGrade {
    if (grade == 31) {
      return '30 & Lode';
    } else {
      return grade?.toString() ?? 'Non ancora sostenuto';
    }
  }

  String get effectiveDiary {
    return diary.isNotEmpty ? diary : 'Diario non inserito';
  }
}
