
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
// import 'page3.dart';  // Import your Page3 widget

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   String? uniqueCode;

//   // Function to handle signup
//   Future<void> signupUser() async {
//     final String apiUrl = "https://utopiaa-rqkd.onrender.com/api/users/signup"; // Replace with your local IP

//     // Validate input fields
//     if (nameController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         passwordController.text.isEmpty) {
//       Get.snackbar("Validation Error", "Name, email, and password are required.");
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "name": nameController.text,
//           "email": emailController.text,
//           "password": passwordController.text,
//         }),
//       );

//       // Debugging: Log response
//       print("Response status: ${response.statusCode}");
//       print("Response body: ${response.body}");

//       if (response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           uniqueCode = data['user']['uniqueCode'];
//         });

//         // Store unique code in SharedPreferences
//         SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString("uniqueCode", uniqueCode!);
//         print("Unique Code Saved: $uniqueCode");

//         // Show success message
//         Get.snackbar("Signup Successful", "Your Unique Code: $uniqueCode");

//         // Show the unique code in a modal dialog
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: const Text("Your Unique Code"),
//             content: Text("Your Unique Code is: $uniqueCode"),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop(); // Close the modal
//                   Get.off(VoiceButtonPage()); // Navigate to Page3
//                 },
//                 child: const Text("OK"),
//               ),
//             ],
//           ),
//         );

//         // Debugging: Log user info
//         print("User registered: ${data['user']}");
//       } else {
//         final error = jsonDecode(response.body)['message'];
//         Get.snackbar("Signup Failed", error);
//       }
//     } catch (e) {
//       print("Error: $e");
//       Get.snackbar("Signup Failed", "An error occurred. Please try again.");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       backgroundColor: const Color.fromRGBO(251, 217, 197, 1),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 25),
//                   Image.asset(
//                     'assets/istockphoto-1353464216-612x612 1 (3).png',
//                     width: MediaQuery.of(context).size.width * 0.9,
//                     height: MediaQuery.of(context).size.height * 0.4,
//                     fit: BoxFit.cover,
//                   ),
//                   const SizedBox(height: 50),
//                   buildTextField(nameController, "Name", Icons.person),
//                   const SizedBox(height: 16.0),
//                   buildTextField(emailController, "Email", Icons.email),
//                   const SizedBox(height: 16.0),
//                   buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
//                   const SizedBox(height: 25.0),
//                   ElevatedButton(
//                     onPressed: signupUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF4A2D26),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
//                     ),
//                     child: const Text(
//                       "Signup",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                   if (uniqueCode != null) ...[ 
//                     const SizedBox(height: 20),
//                     Text(
//                       "Your Unique Code: $uniqueCode",
//                       style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: screenWidth * 0.50,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 6),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 0, 0, 0),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
//     return Container(
//       width: MediaQuery.of(context).size.width * 0.8,
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(30.0),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utopia/pages/emergency.dart';
import 'page3.dart'; // Import your Page3 widget

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? uniqueCode;

  // Function to handle signup
  Future<void> signupUser() async {
    final String name = nameController.text;
    final String email = emailController.text;
    final String password = passwordController.text;

    // Validate input fields
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Validation Error", "Name, email, and password are required.");
      return;
    }

    try {
      // Create unique code based on name
      String generateUniqueCode(String name) {
        final initials = name
            .split(" ")
            .map((word) => word[0])
            .join("")
            .toUpperCase();
        final randomNumber = (1000 + (9000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).toInt(); 
        return '$initials$randomNumber';
      }

      uniqueCode = generateUniqueCode(name);
      
      // Firebase Authentication - Create User with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store the unique code and other user info in Firestore
      FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'uniqueCode': uniqueCode,
      });

      // Store unique code in SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("uniqueCode", uniqueCode!);
      print("Unique Code Saved: $uniqueCode");

      // Show success message
      Get.snackbar("Signup Successful", "Your Unique Code: $uniqueCode");

      // Show the unique code in a modal dialog
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Your Unique Code"),
          content: Text("Your Unique Code is: $uniqueCode"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the modal
                Get.off(VoiceButtonPage()); // Navigate to Page3
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );

      // Debugging: Log user info
      print("User registered: ${userCredential.user!.email}");
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Signup Failed", "An error occurred. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(251, 217, 197, 1),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  Image.asset(
                    'assets/istockphoto-1353464216-612x612 1 (3).png', // Update image path accordingly
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 50),
                  buildTextField(nameController, "Name", Icons.person),
                  const SizedBox(height: 16.0),
                  buildTextField(emailController, "Email", Icons.email),
                  const SizedBox(height: 16.0),
                  buildTextField(passwordController, "Password", Icons.lock, isPassword: true),
                  const SizedBox(height: 25.0),
                  ElevatedButton(
                    onPressed: signupUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A2D26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    ),
                    child: const Text(
                      "Signup",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  if (uniqueCode != null) ...[ 
                    const SizedBox(height: 20),
                    Text(
                      "Your Unique Code: $uniqueCode",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth * 0.50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
