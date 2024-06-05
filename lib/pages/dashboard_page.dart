import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../data_model.dart';
import 'exam_detail_page.dart';
import 'database_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isMonthView = true;
  List<Exam> _allUpcomingExams = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadUpcomingExams();
  }

  Future<void> _loadUpcomingExams() async {
    final exams = await DatabaseHelper.instance.exams();
    final now = DateTime.now();
    DateTime start = now;
    DateTime end = now.add(const Duration(days: 28));

    switch (_calendarFormat) {
      case CalendarFormat.twoWeeks:
        end = now.add(const Duration(days: 14));
        break;
      case CalendarFormat.month:
        end = now.add(const Duration(days: 28));
        break;
      case CalendarFormat.week:
      default:
        end = now.add(const Duration(days: 7));
        break;
    }

    setState(() {
      _allUpcomingExams = exams
          .where((exam) => exam.date.isAfter(start) && exam.date.isBefore(end))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    });
  }

  List<Exam> _getNearest3UpcomingExams() {
    return _allUpcomingExams.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExamDetailPage(),
                ),
              );
              _loadUpcomingExams();
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/statistics');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Esami',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await Navigator.pushNamed(context, '/add-edit-exam');
                  _loadUpcomingExams();
                },
              ),
            ],
          ),
          if (_isMonthView)
            Expanded(
              child: _buildCalendarView(),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: _allUpcomingExams.length,
                itemBuilder: (context, index) {
                  final exam = _allUpcomingExams[index];
                  return ListTile(
                    title: Text(exam.name),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(exam.date),
                    ),
                    trailing: Text(exam.course),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExamDetailPage(exam: exam),
                        ),
                      );
                      _loadUpcomingExams();
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16.0),
          const Text(
            'Esami imminenti',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _getNearest3UpcomingExams().length,
              itemBuilder: (context, index) {
                final exam = _getNearest3UpcomingExams()[index];

                return ListTile(
                  title: Text(exam.name),
                  subtitle: Text(
                    DateFormat('yyyy-MM-dd').format(exam.date),
                  ),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamDetailPage(exam: exam),
                      ),
                    );
                    _loadUpcomingExams();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return SingleChildScrollView(
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
              _loadUpcomingExams();
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }
}
