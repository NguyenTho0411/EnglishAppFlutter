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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.setUpServiceLocator();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const GlobalWidget(child: BlocProviderScope(child: MainApp())));
}
