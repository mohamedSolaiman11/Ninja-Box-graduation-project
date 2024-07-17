import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project2024/firebase_options.dart';
import 'package:graduation_project2024/presentation/view/control_admin/control_admin_cubit.dart';
import 'package:graduation_project2024/presentation/view/splash.dart';

//taken is:
//fCCDmSQRRN2Zw6wtp_7GQj:APA91bH5ylVT6N68sBfYpjkZTlioW0EKqgq90NVf5f1NowugWFHha6CDSmecTW488M-PBiyc4m0CCtJ82ORxdRolLL0Kbtox5NiclzU-HdhMdNICs7FDG58vDPQ6fQvqi2R2FfYg8fqx
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

// Request permission to receive notifications
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => Home(), // Wrap your app
    ),
  );

  // runApp(Home());

}



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ControlAdminCubit(),
      child: MaterialApp(
        builder: DevicePreview.appBuilder,
        locale: DevicePreview.locale(context),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        home:  Scaffold(
          body: Splash(),
        ),
      ),
    );
  }
}