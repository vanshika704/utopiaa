// import 'package:uni_links/uni_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:utopia/pages/Login.dart';
import 'package:utopia/pages/Page2.dart';
import 'package:utopia/pages/emergency.dart';
import 'package:utopia/pages/page1.dart';
import 'package:utopia/pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized

  try {
    // Load the .env file
    await dotenv.load();
    print("Environment variables loaded successfully!");
  } catch (e) {
    print("Error loading environment variables: $e");
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //  Uri? initialUri = await getInitialUri();
  // if (initialUri != null && initialUri.toString() == 'utopia://emergency') {
  //   _triggerEmergencyProtocol();
  // }

  // // Handle deep links while app is running
  // uriLinkStream.listen((Uri? uri) {
  //   if (uri != null && uri.toString() == 'utopia://emergency') {
  //     _triggerEmergencyProtocol();
  //   }
  // });


  runApp(const MyApp());
}
// Future<void> _triggerEmergencyProtocol() async {
//   // Implement your emergency logic here
//   await _sendEmergencyAlert();
// }
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Utopia',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // Initial route
      getPages: [
        GetPage(name: '/splash', page: () => Splash()), // Splash screen route
        GetPage(name: '/home', page: () => Page1()), // Home screen route
        GetPage(name: '/Page2', page: () => SignupPage()), // Fixed: Ensure `SignupPage` is imported correctly
        GetPage(name: '/Page3', page: () => VoiceButtonPage()), // Fixed: Ensure `VoiceButtonPage` is imported correctly
        GetPage(name: '/login', page: () => LoginPage()), // Fixed: Ensure `LoginPage` is imported correctly
      ],
    );
  }
}
