import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_edit_exam_page.dart';
import 'database_helper.dart';
import '../data_model.dart';

class ExamDetailPage extends StatefulWidget {
  final Exam? exam;
  const ExamDetailPage({super.key, this.exam});

  @override
  _ExamDetailPageState createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage> {
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final exams = await DatabaseHelper.instance.exams();
    setState(() {
      _exams = exams
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Esami'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'eliminaExam') {
                _eliminaEsame();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'eliminaExam',
                  child: Text('Elimina esame'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _exams.length,
        itemBuilder: (context, index) {
          final exam = _exams[index];
          return ExpansionTile(
            title: Text(exam.name),
            subtitle: Text(exam.course),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('CFU'),
                    subtitle: Text(exam.credits.toString()),
                  ),
                  ListTile(
                    title: const Text('Data'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(exam.date)),
                  ),
                  ListTile(
                    title: const Text('Ora'),
                    subtitle: Text(exam.time.format(context)),
                  ),
                  ListTile(
                    title: const Text('Tipologia di esame'),
                    subtitle: Text(exam.examType),
                  ),
                  ListTile(
                    title: const Text('Docente'),
                    subtitle: Text(exam.professor),
                  ),
                  ListTile(
                    title: const Text('Voto'),
                    subtitle: Text(exam.effectiveGrade),
                  ),
                  ListTile(
                    title: const Text('Categorie'),
                    subtitle: Wrap(
                      spacing: 8.0,
                      children: exam.categories.map((category) {
                        return Chip(
                          label: Text(category),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Diario',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      exam.effectiveDiary,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditExamPage(exam: exam),
                            ),
                          );
                          _loadExams();
                        },
                        child: const Text('Modifica'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _eliminaEsame() async {
    final selectedExam = await showDialog<Exam>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Seleziona esame da eliminare'),
          children: _exams.map((exam) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, exam);
              },
              child: Text(exam.name),
            );
          }).toList(),
        );
      },
    );

    if (selectedExam != null) {
      await DatabaseHelper.instance.deleteExam(selectedExam.name);
      _loadExams();
    }
  }
}
