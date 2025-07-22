import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/localization/app_localizations.dart';
import 'routes/app_routes.dart';
import 'view_model/splash/splash_view_model.dart';
import 'view_model/language/language_selection_view_model.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/firebase_service.dart';
import 'data/services/notification_service.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'view_model/auth/signup_view_model.dart';
import 'view_model/auth/login_view_model.dart';
import 'view_model/auth/forgot_password_view_model.dart';
import 'view_model/buy/visit_schedule_view_model.dart';
import 'view_model/notification/notification_view_model.dart';
import 'view_model/dashboard/weather_view_model.dart'; // Add this import
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/models/user_model.dart';



// Exported RouteObserver for navigation lifecycle
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => LocalStorageService()),
        Provider(create: (_) => FirebaseService()),
        Provider(create: (_) => NotificationService()),
        ProxyProvider2<FirebaseService, LocalStorageService, UserRepository>(
          update: (_, firebase, local, __) => UserRepository(firebase, local),
        ),
        ProxyProvider<NotificationService, NotificationRepository>(
          update: (_, notificationService, __) => NotificationRepository(notificationService),
        ),
        FutureProvider<UserModel?>(
          create: (context) => Provider.of<UserRepository>(context, listen: false).getCurrentUser(),
          initialData: null,
        ),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => WeatherViewModel()), // Add WeatherViewModel
        ChangeNotifierProvider(create: (_) => LanguageSelectionViewModel()),
        ChangeNotifierProxyProvider<UserRepository, SignupViewModel>(
          create: (context) => SignupViewModel(userRepository: Provider.of<UserRepository>(context, listen: false)),
          update: (context, userRepository, previous) => SignupViewModel(userRepository: userRepository),
        ),
        ChangeNotifierProxyProvider<UserRepository, LoginViewModel>(
          create: (context) => LoginViewModel(userRepository: Provider.of<UserRepository>(context, listen: false)),
          update: (context, userRepository, previous) => LoginViewModel(userRepository: userRepository),
        ),
        ChangeNotifierProxyProvider<UserRepository, ForgotPasswordViewModel>(
          create: (context) => ForgotPasswordViewModel(userRepository: Provider.of<UserRepository>(context, listen: false)),
          update: (context, userRepository, previous) => ForgotPasswordViewModel(userRepository: userRepository),
        ),
        ChangeNotifierProxyProvider2<UserRepository, NotificationRepository, NotificationViewModel>(
          create: (context) => NotificationViewModel(
            Provider.of<NotificationRepository>(context, listen: false),
          ),
          update: (context, userRepository, notificationRepository, previous) => 
              NotificationViewModel(notificationRepository),
        ),
        ChangeNotifierProxyProvider2<UserRepository, NotificationViewModel, VisitScheduleViewModel>(
          create: (context) => VisitScheduleViewModel(
            userRepository: Provider.of<UserRepository>(context, listen: false),
            notificationViewModel: Provider.of<NotificationViewModel>(context, listen: false),
          ),
          update: (context, userRepository, notificationViewModel, previous) => 
              VisitScheduleViewModel(
                userRepository: userRepository,
                notificationViewModel: notificationViewModel,
              ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrim Seller',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      navigatorObservers: [routeObserver],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
    );
  }
}