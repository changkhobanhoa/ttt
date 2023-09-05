import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';

import 'constants.dart';
import 'firebase_options.dart';
import 'screens/auth/authentication_bloc.dart';
import 'screens/lancher/launcher_screen.dart';
import 'screens/loading/loading_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthenticationBloc()),
        RepositoryProvider(create: (_) => LoadingCubit()),
      ],
      child: const MyApp(),
    ));
  });
}

_initializeFirebase() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For Showing Message Notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats');
  debugPrint('\nNotification Channel Result: $result');
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // Show error message if initialization failed

    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBarTheme:
              const AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark),
          snackBarTheme: const SnackBarThemeData(
              contentTextStyle: TextStyle(color: Colors.white)),
          colorScheme: ColorScheme.fromSwatch().copyWith(
              secondary: const Color(colorPrimary),
              brightness: Brightness.light),
        ),
        darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.grey.shade800,
            appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle.light),
            snackBarTheme: const SnackBarThemeData(
                contentTextStyle: TextStyle(color: Colors.white)),
            colorScheme: ColorScheme.fromSwatch().copyWith(
                secondary: const Color(colorPrimary),
                brightness: Brightness.dark)),
        debugShowCheckedModeBanner: false,
        color: const Color(colorPrimary),
        home: const LauncherScreen());
  }
}
