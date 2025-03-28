
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 220,
            child: Image.asset(
              'assets/page2.png',
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.4,
              decoration: const BoxDecoration(
                color: Color.fromRGBO(251, 217, 197, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(4, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Get.toNamed("/login");
                        },
                         style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCA9797)
,  
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 30), // Button height
                  elevation: 8, // Elevation to create shadow
                  shadowColor: const Color.fromARGB(235, 0, 0, 0), // Shadow color
                ),
                        child: Text('Login', style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 255, 255, 255), // Text color
                    ),
                  ),),
                      ),
                      const SizedBox(width: 25),
                      ElevatedButton(
                        onPressed: () {
                            Get.toNamed('/Page2');
                        },
                         style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4A4A), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30), // Button height
                  elevation: 8, // Elevation to create shadow
                  shadowColor: const Color.fromARGB(235, 0, 0, 0), // Shadow color
                ),
                        child: Text(
                  'SignUp',
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 255, 255, 255), // Text color
                    ),
                  ),
                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // Second Row with Three Buttons
                 Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 106, 74, 74), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20), // Button height
                  elevation: 8, // Elevation to create shadow
                  shadowColor: const Color.fromARGB(235, 0, 0, 0), // Shadow color
                ),
                
      child: const Row(
        children: [
          Icon(Icons.g_translate, color: Colors.white), // Google Icon
          
         
        ],
      ),
    ),
    const SizedBox(width: 25),
    ElevatedButton(
      onPressed: () {},
       style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4A4A), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20), // Button height
                  elevation: 8, // Elevation to create shadow
                  shadowColor: const Color.fromARGB(235, 0, 0, 0), // Shadow color
                ),
      child: const Row(
        children: [
          Icon(Icons.window, color: Colors.white), // Windows Icon
         
         
        ],
      ),
    ),
    const SizedBox(width: 25),
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A4A4A), // Background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20), // Button height
                  elevation: 8, // Elevation to create shadow
                  shadowColor: const Color.fromARGB(235, 0, 0, 0), // Shadow color
                ),
      child: const Row(
        children: [
          Icon(Icons.apple, color: Colors.white), // Apple Icon
         
         
        ],
      ),
    ),
  ],
)

                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              width: screenWidth * 0.50,
              height: 4,
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
}
