

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class VoiceButtonPage extends StatefulWidget {
  const VoiceButtonPage({super.key});

  @override
  State<VoiceButtonPage> createState() => _VoiceButtonPageState();
}

class _VoiceButtonPageState extends State<VoiceButtonPage> {
  // App Colors
  final Color _backgroundColor = const Color.fromARGB(255, 224, 191, 172);
  final Color _primaryColor = const Color.fromARGB(255, 76, 53, 45);
  final Color _accentColor = const Color.fromARGB(255, 81, 190, 127);
  final Color _buttonColor = const Color.fromARGB(255, 227, 227, 227);

  // State Variables
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  double _buttonSize = 200.0;
  Color _currentButtonColor = const Color.fromARGB(255, 227, 227, 227);
  String _recognizedText = "";
  double _circleSize = 240.0;
  double _circleOpacity = 0.0;
  double _hollowCircleSize = 250.0;
  bool _isSendingAlert = false;
  bool _contactSet = false;
  String _emergencyContact = "";
  String _emergencyContactName = "";

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _initializeSpeechToText();
    _askPermissions();
    _loadSavedContact();
  }

  Future<void> _loadSavedContact() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emergencyContact = prefs.getString('emergencyContact') ?? "";
      _emergencyContactName = prefs.getString('emergencyContactName') ?? "";
      _contactSet = _emergencyContact.isNotEmpty;
    });
  }

  Future<void> _saveContact(String number, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergencyContact', number);
    await prefs.setString('emergencyContactName', name);
    setState(() {
      _emergencyContact = number;
      _emergencyContactName = name;
      _contactSet = true;
    });
  }

  Future<void> _askPermissions() async {
    await [
      Permission.microphone,
      Permission.location,
      Permission.phone,
      Permission.contacts,
    ].request();
  }

  Future<void> _selectContactFromPhone() async {
    try {
      if (await FlutterContacts.requestPermission()) {
        final contact = await FlutterContacts.openExternalPick();
        if (contact != null && contact.phones.isNotEmpty) {
          String cleanNumber = contact.phones.first.number.replaceAll(RegExp(r'[^0-9+]'), '');
          await _saveContact(cleanNumber, contact.displayName);
        } else {
          _showSnackBar('No phone number found for selected contact');
        }
      } else {
        _showSnackBar('Contact permission denied');
      }
    } catch (e) {
      debugPrint('Contact selection error: $e');
      _showSnackBar('Failed to select contact');
    }
  }

  void _initializeSpeechToText() async {
    bool available = await _speechToText.initialize(
      onStatus: (status) {
        if (mounted) {
          setState(() {
            _isListening = status == "listening";
            _updateButtonState();
          });
        }
      },
    );
    
    if (!available && mounted) {
      _showSnackBar('Speech recognition not available');
    }
  }

  void _updateButtonState() {
    setState(() {
      _buttonSize = _isListening ? 220.0 : 200.0;
      _currentButtonColor = _isListening ? _accentColor : _buttonColor;
      _circleSize = _isListening ? 280.0 : 240.0;
      _circleOpacity = _isListening ? 0.3 : 0.0;
      _hollowCircleSize = _isListening ? 300.0 : 270.0;
    });
  }

  void _startListening() async {
    if (_isSendingAlert) return;
    
    bool available = await _speechToText.initialize();
    if (!available) {
      if (mounted) {
        _showSnackBar('Speech recognition not available');
      }
      return;
    }

    _speechToText.listen(
      onResult: (result) async {
        if (mounted) {
          setState(() => _recognizedText = result.recognizedWords.trim().toLowerCase());
        }
        
        if (_recognizedText.contains("okay help") && !_isSendingAlert && _contactSet) {
          await _triggerEmergencyProtocol();
        }
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
    );
  }

  Future<void> _triggerEmergencyProtocol() async {
    if (_isSendingAlert || !_contactSet) return;
    
    if (mounted) {
      setState(() => _isSendingAlert = true);
    }
    
    try {
      _showSnackBar('Activating emergency protocol...');
      
      String locationMessage = await _getLocationMessage();
      String message = "🚨 Emergency! I need help. $locationMessage";

      bool whatsAppSuccess = await _sendViaWhatsApp(message);
      
      if (!whatsAppSuccess) {
        await _makeDirectCall();
      }

    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSendingAlert = false);
      }
    }
  }

  Future<String> _getLocationMessage() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return "Location services disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission != LocationPermission.denied && 
          permission != LocationPermission.deniedForever) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
        return "My location: https://maps.google.com/?q=${position.latitude},${position.longitude}";
      }
      return "Location permission denied";
    } catch (e) {
      debugPrint('Location error: $e');
      return "Could not determine location";
    }
  }

  Future<bool> _sendViaWhatsApp(String message) async {
    try {
      final url = "https://wa.me/$_emergencyContact?text=${Uri.encodeComponent(message)}";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('WhatsApp error: $e');
      return false;
    }
  }

  Future<void> _makeDirectCall() async {
    try {
      final Uri callUri = Uri(scheme: 'tel', path: _emergencyContact);
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
        return;
      }

      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.CALL',
        data: 'tel:$_emergencyContact',
      );
      await intent.launch();
    } catch (e) {
      debugPrint('Call error: $e');
      _showSnackBar('Failed to make emergency call');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _showContactSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Emergency Contact Required',
          style: TextStyle(color: _primaryColor),
        ),
        content: Text(
          'You need to set an emergency contact to use this feature',
          style: TextStyle(color: _primaryColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: _primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showContactSelectionOptions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Set Contact',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSelectionOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Set Emergency Contact',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSelectionOption(
                  icon: Icons.contacts,
                  label: 'Select from Contacts',
                  color: const Color.fromARGB(255, 48, 30, 18),
                  onTap: () {
                    Navigator.pop(context);
                    _selectContactFromPhone();
                  },
                ),
                const SizedBox(height: 12),
                _buildSelectionOption(
                  icon: Icons.edit,
                  label: 'Enter Manually',
                  color: _backgroundColor,
                  isOutlined: true,
                  onTap: () {
                    Navigator.pop(context);
                    _showManualInputDialog();
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionOption({
    required IconData icon,
    required String label,
    required Color color,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isOutlined ? Colors.transparent : color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: isOutlined
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _primaryColor,
                    width: 1.5,
                  ),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isOutlined ? _primaryColor : Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isOutlined ? _primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: _backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Emergency Number',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter phone number with country code',
                  prefixIcon: Icon(Icons.phone, color: _primaryColor),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: _primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        _saveContact(controller.text, "Emergency Contact");
                        Navigator.pop(context);
                      } else {
                        _showSnackBar('Please enter a valid phone number');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_contactSet) {
       double screenWidth = MediaQuery.of(context).size.width;
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                    'assets/istockphoto-1353464216-612x612 1 (3).png',
                    width: screenWidth * 0.9,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.cover,
                  ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Emergency Voice Alert',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Set up an emergency contact to enable the voice-activated alert system',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _primaryColor.withOpacity(0.8),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildSelectionOption(
                    icon: Icons.contacts,
                    label: 'Select from Contacts',
                    color: _primaryColor,
                    onTap: _selectContactFromPhone,
                  ),
                  const SizedBox(height: 16),
                  _buildSelectionOption(
                    icon: Icons.edit,
                    label: 'Enter Manually',
                    color: _backgroundColor,
                    isOutlined: true,
                    onTap: _showManualInputDialog,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          ' SOS Button',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.contacts),
            onPressed: _showContactSelectionOptions,
            tooltip: 'Change Emergency Contact',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emergency,
                      color: _primaryColor,
                    ),
                  ),
                  title: Text(
                    'Emergency Contact',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _emergencyContactName,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _emergencyContact,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: _primaryColor,
                    ),
                    onPressed: _showContactSelectionOptions,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: _hollowCircleSize,
                    height: _hollowCircleSize,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: _primaryColor,
                        width: 6.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: _circleSize,
                    height: _circleSize,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(_circleOpacity),
                      shape: BoxShape.circle,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: _buttonSize,
                    height: _buttonSize,
                    decoration: BoxDecoration(
                      color: _currentButtonColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _primaryColor,
                        size: 70.0,
                      ),
                      onPressed: _isSendingAlert
                          ? null
                          : () {
                              if (_isListening) {
                                _speechToText.stop();
                              } else {
                                _startListening();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _recognizedText.isEmpty
                        ? 'Say "OK Help" to trigger emergency'
                        : _recognizedText,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_isSendingAlert)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(
                      color: _primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}