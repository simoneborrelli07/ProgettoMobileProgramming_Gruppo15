import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import '../data_model.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final exams = await DatabaseHelper.instance.exams();
    setState(() {
      _exams = exams;
    });
  }

  @override
  Widget build(BuildContext context) {
    int minGrade = 32;
    int maxGrade = 0;
    double totalGrade = 0;
    int totalCredits = 0;
    bool hasThirtyLode = false;

    for (final exam in _exams) {
      if (exam.grade != null) {
        int grade = exam.grade!;
        if (grade == 31) {
          hasThirtyLode = true;
          grade = 30;
        }
        minGrade = min(minGrade, grade);
        maxGrade = max(maxGrade, grade);
        totalGrade += grade * exam.credits;
        totalCredits += exam.credits;
      }
    }

    final avgGrade = _exams.isNotEmpty ? totalGrade / totalCredits : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiche'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riepilogo',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              title: const Text('Voto minimo'),
              trailing: Text(minGrade.toString()),
            ),
            ListTile(
              title: const Text('Voto massimo'),
              trailing: Text(hasThirtyLode ? '30 & Lode' : maxGrade.toString()),
            ),
            ListTile(
              title: const Text('Media voti'),
              trailing: Text(avgGrade.toStringAsFixed(2)),
            ),
            ListTile(
              title: const Text('Media ponderata'),
              trailing: Text((_exams.isNotEmpty ? totalGrade / totalCredits : 0)
                  .toStringAsFixed(2)),
            ),
            ListTile(
              title: const Text('Voto di laurea corrente'),
              trailing: Text(_calculateGraduationGrade().toStringAsFixed(2)),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Altre statistiche',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            ListTile(
              title: const Text('Numero di esami sostenuti'),
              trailing: Text(
                  _exams.where((exam) => exam.grade != null).length.toString()),
            ),
            ListTile(
              title: const Text('Numero di esami non sostenuti'),
              trailing: Text(
                  _exams.where((exam) => exam.grade == null).length.toString()),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateWeightedAverage() {
    double weightedSum = 0;
    int totalCredits = 0;

    for (final exam in _exams) {
      if (exam.grade != null) {
        int grade = exam.grade!;
        if (grade == 31) {
          grade = 30;
        }
        weightedSum += grade * exam.credits;
        totalCredits += exam.credits;
      }
    }

    return totalCredits > 0 ? weightedSum / totalCredits : 0;
  }

  double _calculateGraduationGrade() {
    final weightedAvg = _calculateWeightedAverage();
    return ((weightedAvg * 4.1 - 7.8) * 10).round() / 10;
  }
}
