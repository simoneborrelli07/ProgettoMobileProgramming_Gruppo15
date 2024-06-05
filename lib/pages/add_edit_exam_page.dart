import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import '../data_model.dart';

class AddEditExamPage extends StatefulWidget {
  final Exam? exam;

  const AddEditExamPage({super.key, this.exam});

  @override
  _AddEditExamPageState createState() => _AddEditExamPageState();
}

class _AddEditExamPageState extends State<AddEditExamPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _courseController;
  late TextEditingController _creditsController;
  late TextEditingController _dateController;
  late TextEditingController _examTypeController;
  late TextEditingController _professorController;
  late TextEditingController _gradeController;
  late TextEditingController _diaryController;
  late TextEditingController _categoryController;
  late TimeOfDay _selectedTime;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    final exam = widget.exam;
    _nameController = TextEditingController(text: exam?.name);
    _courseController = TextEditingController(text: exam?.course);
    _creditsController = TextEditingController(text: exam?.credits.toString());
    _dateController = TextEditingController(
        text: exam?.date != null
            ? DateFormat('yyyy-MM-dd').format(exam!.date)
            : '');
    _selectedTime = exam?.time ?? TimeOfDay.now();
    _examTypeController = TextEditingController(text: exam?.examType);
    _professorController = TextEditingController(text: exam?.professor);
    _gradeController = TextEditingController(text: exam?.grade?.toString());
    _diaryController = TextEditingController(text: exam?.diary);
    _categoryController = TextEditingController();
    _categories = exam?.categories ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _creditsController.dispose();
    _dateController.dispose();
    _examTypeController.dispose();
    _professorController.dispose();
    _gradeController.dispose();
    _diaryController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _addCategory() {
    final category = _categoryController.text.trim();
    if (category.isNotEmpty && !_categories.contains(category)) {
      setState(() {
        _categories.add(category);
        _categoryController.clear();
      });
    }
  }

  void _removeCategory(String category) {
    setState(() {
      _categories.remove(category);
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? 'Aggiungi esame' : 'Modifica esame'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome esame',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il nome dell\'esame';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: 'Corso di studi',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il corso di studi';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _creditsController,
                  decoration: const InputDecoration(
                    labelText: 'CFU',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci i CFU';
                    }
                    final credits = int.tryParse(value);
                    if (credits == null) {
                      return 'Inserisci un numero valido';
                    }
                    if (credits <= 0 || credits > 12) {
                      return 'Il numero di CFU deve essere compreso tra 1 e 12';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      if (date.weekday == DateTime.saturday ||
                          date.weekday == DateTime.sunday) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Non puoi selezionare un sabato o una domenica'),
                          ),
                        );
                      } else {
                        _dateController.text =
                            DateFormat('yyyy-MM-dd').format(date);
                      }
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la data';
                    }
                    DateTime selectedDate =
                        DateFormat('yyyy-MM-dd').parseStrict(value);
                    if (selectedDate.weekday == DateTime.saturday ||
                        selectedDate.weekday == DateTime.sunday) {
                      return 'Non puoi selezionare un sabato o una domenica';
                    }
                    return null;
                  },
                ),
                InkWell(
                  onTap: () => _selectTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ora',
                    ),
                    child: Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
                TextFormField(
                  controller: _examTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipologia d\'esame',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci la tipologia d\'esame';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _professorController,
                  decoration: const InputDecoration(
                    labelText: 'Docente',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Inserisci il docente';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _gradeController,
                  decoration: const InputDecoration(
                    labelText: 'Voto',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  validator: (value) {
                    if (_dateController.text.isNotEmpty) {
                      DateTime now = DateTime.now();
                      DateTime examDate = DateFormat('yyyy-MM-dd')
                          .parseStrict(_dateController.text);

                      if (now.isAfter(examDate)) {
                        if (value != null && value.isNotEmpty) {
                          int? grade = int.tryParse(value);

                          if (grade == null) {
                            return 'Inserisci un voto valido';
                          }

                          if (grade < 18) {
                            return 'Inserisci un voto solo se l\'esame è stato superato';
                          } else if (grade > 31) {
                            return 'Il voto massimo è 30 & Lode (31)';
                          } else {
                            return null;
                          }
                        } else {
                          return 'Inserisci il voto dell\'esame';
                        }
                      } else {
                        if (value != null && value.isNotEmpty) {
                          return 'Non puoi inserire un voto per un esame futuro';
                        }
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Categorie',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return Chip(
                      label: Text(category),
                      onDeleted: () {
                        setState(() {
                          _categories.removeAt(index);
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: 'Categorie',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addCategory,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8.0,
                  children: _categories.map((category) {
                    return Chip(
                      label: Text(category),
                      onDeleted: () => _removeCategory(category),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Diario',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _diaryController,
                  decoration: const InputDecoration(
                    labelText: 'Diario',
                    hintText: 'Inserisci le note per questo esame',
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final exam = Exam(
                        name: _nameController.text,
                        course: _courseController.text,
                        credits: int.parse(_creditsController.text),
                        date: _dateController.text.isNotEmpty
                            ? DateFormat('yyyy-MM-dd')
                                .parseStrict(_dateController.text)
                            : DateTime.now(),
                        time: _selectedTime,
                        examType: _examTypeController.text,
                        professor: _professorController.text,
                        grade: int.tryParse(_gradeController.text),
                        categories: _categories,
                        diary: _diaryController.text,
                      );
                      final dbHelper = DatabaseHelper.instance;
                      if (widget.exam == null) {
                        await dbHelper.insertExam(exam);
                      } else {
                        await dbHelper.updateExam(exam);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salva'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
