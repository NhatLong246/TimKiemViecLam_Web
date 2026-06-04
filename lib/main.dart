import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'constants.dart';
import 'controllers/auth_controller.dart';
import 'controllers/menu_app_controller.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/job_post_controller.dart';
import 'controllers/disbursement_controller.dart';
import 'controllers/complaint_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/employer_controller.dart';
import 'controllers/candidate_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/settings_controller.dart';
import 'views/auth/login_page.dart';
import 'views/dashboard/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthController()),
        ChangeNotifierProvider(create: (context) => MenuAppController()),
        ChangeNotifierProvider(create: (context) => DashboardController()),
        ChangeNotifierProvider(create: (context) => JobPostController()),
        ChangeNotifierProvider(create: (context) => DisbursementController()),
        ChangeNotifierProvider(create: (context) => ComplaintController()),
        ChangeNotifierProvider(create: (context) => UserController()),
        ChangeNotifierProvider(create: (context) => EmployerController()),
        ChangeNotifierProvider(create: (context) => CandidateController()),
        ChangeNotifierProvider(create: (context) => CategoryController()),
        ChangeNotifierProvider(create: (context) => SettingsController()),
      ],
      child: MaterialApp(
        title: 'ViecNow Admin',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Inter'),
          canvasColor: secondaryColor,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isLoggedIn) {
          return MainScreen();
        }
        return const LoginPage();
      },
    );
  }
}
