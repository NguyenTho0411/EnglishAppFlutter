import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/features/exam/utils/scripts/toeic_data_seeder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/features/exam/utils/scripts/toeic_questions_seeder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app.dart';
import 'app/managers/notification.dart';
import 'bloc_provider_scope.dart';
import 'config/app_bloc_observer.dart';
import 'firebase_options.dart';
import 'global_widget.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = AppBlocObserver();
  await EasyLocalization.ensureInitialized();
  await NotificationService.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // print("--- APP STARTING ---"); 

  // try {
  //   await _runSeeder_1();
  // } catch (e) {
  //   print("Seeder error: $e");
  // }


  await di.setUpServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(
    const GlobalWidget(
      child: BlocProviderScope(
        child: MainApp(),
      ),
    ),
  );

}


Future<void> _runSeeder() async {
  final firestore = FirebaseFirestore.instance;
  final seeder = ToeicQuestionSeeder(firestore); 
  final seeder_1 = ToeicDataSeeder();
  String testUserId = "6iVeBzWEAWeMjSkfgIZFsyzVH902";
  print("Starting seed...");
  await seeder.seedAllToeicQuestions();
  await seeder_1.seedFullTest("ETS 2024 - Test 1");
  print("Seed success!");
}

Future<void> _runSeeder_1() async {
  final firestore = FirebaseFirestore.instance;
  final seeder_1 = ToeicDataSeeder();
  print("Starting seed...");
  await seeder_1.seedFullTest("ETS 2024 - Test 1");
  print("Seed success!");
}
