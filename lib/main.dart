import 'package:flutter/material.dart';
import './pages/dashboard_page.dart';
import './pages/exam_detail_page.dart';
import './pages/add_edit_exam_page.dart';
import './pages/statistics_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestione Esami Universitari',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/add-edit-exam': (context) => const AddEditExamPage(),
        '/exam-details': (context) => const ExamDetailPage(),
        '/statistics': (context) => const StatisticsPage(),
      },
    );
  }
}
