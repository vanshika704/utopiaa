
// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:app_links/app_links.dart';
// import 'package:utopia/emergency_handler.dart';

// class VoiceButtonPage extends StatefulWidget {
//   const VoiceButtonPage({super.key});

//   @override
//   State<VoiceButtonPage> createState() => _VoiceButtonPageState();
// }

// class _VoiceButtonPageState extends State<VoiceButtonPage> {
//   stt.SpeechToText _speechToText = stt.SpeechToText();
//   bool _isListening = false;
//   double _buttonSize = 200.0;
//   Color _buttonColor = const Color.fromARGB(255, 227, 227, 227);
//   String _recognizedText = "";
//   double _circleSize = 240.0;
//   double _circleOpacity = 0.0;
//   double _hollowCircleSize = 250.0;
//   final AppLinks _appLinks = AppLinks();

//   @override
//   void initState() {
//     super.initState();
//     _initializeSpeechToText();
//     _handleInitialUri();

//     // Listen for deep links while app is running
//     _appLinks.uriLinkStream.listen((Uri? uri) {
//       if (uri != null) {
//         print("New deep link received: ${uri.toString()}");
//         if (uri.toString().contains("emergency")) {
//           EmergencyHandler.triggerEmergency();
//         }
//       }
//     });
//   }

//   void _initializeSpeechToText() {
//     _speechToText.initialize(onStatus: (status) {
//       setState(() {
//         _isListening = status == "listening";
//         _buttonSize = _isListening ? 220.0 : 200.0;
//         _buttonColor = _isListening ? const Color.fromARGB(255, 97, 203, 139) : const Color.fromARGB(255, 227, 227, 227);
//         _circleSize = _isListening ? 280.0 : 240.0;
//         _circleOpacity = _isListening ? 0.3 : 0.0;
//         _hollowCircleSize = _isListening ? 300.0 : 270.0;
//       });
//     });
//   }

//   void _startListening() {
//     _speechToText.listen(onResult: (result) {
//       setState(() {
//         _recognizedText = result.recognizedWords.trim();
//       });
//     });
//   }

//   Future<void> _handleInitialUri() async {
//     final String? initialLink = (await _appLinks.getInitialLink()) as String?;
//     if (initialLink != null && initialLink.contains("emergency")) {
//       EmergencyHandler.triggerEmergency();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 224, 191, 172),
//       body: Stack(
//         children: [
//           Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       width: _hollowCircleSize,
//                       height: _hollowCircleSize,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         border: Border.all(color: const Color.fromARGB(255, 76, 53, 45), width: 6.0),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       width: _circleSize,
//                       height: _circleSize,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 81, 190, 127).withOpacity(_circleOpacity),
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                       width: _buttonSize,
//                       height: _buttonSize,
//                       decoration: BoxDecoration(
//                         color: _buttonColor,
//                         shape: BoxShape.circle,
//                       ),
//                       child: IconButton(
//                         icon: Icon(
//                           _isListening ? Icons.mic : Icons.mic_none,
//                           color: const Color.fromARGB(255, 72, 46, 37),
//                           size: 70.0,
//                         ),
//                         onPressed: () {
//                           if (_isListening) {
//                             _speechToText.stop();
//                           } else {
//                             _startListening();
//                           }
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Text(_recognizedText.isEmpty ? 'Say something...' : _recognizedText,
//                     style: const TextStyle(fontSize: 24, color: Colors.black)),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 10,
//             left: screenWidth * 0.25,
//             child: Container(
//               width: screenWidth * 0.50,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 36, 26, 26),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
