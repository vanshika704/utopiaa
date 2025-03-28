
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/Untitled design (2).png', // Replace with your image asset path
            fit: BoxFit.cover,
          ),

          // Foreground content
          Column(
            children: [
              // Centered content (image and text)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/istockphoto-1353464216-612x612 1 (3).png', // Replace with your image
                      width: 450,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        "Utopia",
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(4, 4),
                                blurRadius: 10.0,
                                color: Color.fromARGB(212, 52, 36, 36),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Button at the very bottom with shadow
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 160,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFebdddd),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 8,
                      shadowColor: const Color.fromARGB(235, 0, 0, 0),
                    ),
                    onPressed: () {
                      // Use named route for navigation
                      Get.toNamed('/home');
                    },
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Rounded container below the button
              const SizedBox(height: 10),
              Container(
                width: 150,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFFebdddd),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
