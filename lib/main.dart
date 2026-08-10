import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const NewtonApp());
}

class NewtonApp extends StatelessWidget {
  const NewtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Newton',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  String _text = 'Tap the microphone and speak to Newton...';
  String _response = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String message) async {
    setState(() => _response = message);
    await _tts.speak(message);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('Status: $val'),
        onError: (val) => print('Error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              _isListening = false;
              _handleCommand(_text.toLowerCase());
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // Command Router for v0.1
  void _handleCommand(String command) {
    if (command.contains('hello') || command.contains('hi')) {
      _speak("Hello! I am Newton. How can I help you?");
    } else if (command.contains('who are you')) {
      _speak("I am Newton, your offline voice assistant.");
    } else if (command.contains('time')) {
      DateTime now = DateTime.now();
      _speak("The current time is ${now.hour}:${now.minute.toString().padLeft(2, '0')}");
    } else {
      _speak("Sorry, I don't understand that command yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NEWTON v0.1'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _text,
              style: const TextStyle(fontSize: 18.0, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Text(
              _response,
              style: const TextStyle(fontSize: 20.0, color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            GestureDetector(
              onTap: _listen,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _isListening ? Colors.redAccent : Colors.deepPurpleAccent,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

