import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:math';

const String geminiKey = "AIzaSyDLPNssFTmA_W_m346-YT5rPZh-Bq-Ovmo";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAw0f9r8vn_yD4i5moK-rFe5kNuGg7qMQc",
      appId: "1:145053196371:android:dcb6b21178ced1c1d8e6a6",
      messagingSenderId: "145053196371",
      projectId: "dream-walk-ed40e",
    ),
  );
  runApp(const DreamWalkApp());
}

class DreamWalkApp extends StatelessWidget {
  const DreamWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DreamWalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
      ),
      home: const SplashScreen(),
    );
  }
}

class Star {
  late double x, y, size, opacity, speed;
  Star() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    size = random.nextDouble() * 3 + 1;
    opacity = random.nextDouble() * 0.8 + 0.2;
    speed = random.nextDouble() * 0.5 + 0.1;
  }
}

class StarsPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;
  StarsPainter(this.stars, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final opacity = (sin(animation * star.speed * 2 * pi) + 1) / 2 * star.opacity;
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => true;
}

class AnimatedStarsBackground extends StatefulWidget {
  final Widget child;
  final Color? overlayColor;
  const AnimatedStarsBackground({super.key, required this.child, this.overlayColor});

  @override
  State<AnimatedStarsBackground> createState() => _AnimatedStarsBackgroundState();
}

class _AnimatedStarsBackgroundState extends State<AnimatedStarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> stars = List.generate(80, (_) => Star());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: widget.overlayColor != null
                      ? [widget.overlayColor!.withOpacity(0.8), const Color(0xFF0A0A1A)]
                      : [const Color(0xFF0A0A1A), const Color(0xFF1A0A2E), const Color(0xFF0A0A1A)],
                ),
              ),
            ),
            CustomPaint(painter: StarsPainter(stars, _controller.value), size: Size.infinite),
            widget.child,
          ],
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.5), blurRadius: 30, spreadRadius: 5)],
                ),
                child: const Icon(Icons.nightlight_round, size: 70, color: Colors.white),
              ),
              const SizedBox(height: 25),
              const Text('DreamWalk', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
              const SizedBox(height: 10),
              const Text('Art Meets Psychology', style: TextStyle(fontSize: 16, color: Colors.white54, letterSpacing: 2)),
              const SizedBox(height: 10),
              const Text('By: Abdelrahman Elmelegy', style: TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 1)),
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _authenticate() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.4), blurRadius: 20, spreadRadius: 3)],
                    ),
                    child: const Icon(Icons.nightlight_round, size: 45, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                Text(_isLogin ? 'Welcome Back 👋' : 'Create Account ✨',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Text(_isLogin ? 'Sign in to continue' : 'Start your dream journey',
                    style: const TextStyle(fontSize: 16, color: Colors.white54)),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Email', hintStyle: TextStyle(color: Colors.white24),
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF6C63FF)),
                      border: InputBorder.none, contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _passwordController, obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Password', hintStyle: TextStyle(color: Colors.white24),
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF6C63FF)),
                      border: InputBorder.none, contentPadding: EdgeInsets.all(20),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: _isLoading ? null : _authenticate,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? "Don't have an account? Register" : 'Already have an account? Sign In',
                      style: const TextStyle(color: Color(0xFF6C63FF)),
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
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.nightlight_round, size: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Text('DreamWalk', style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold, fontSize: 18)),
                    ]),
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Good Night 🌙', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 5),
                      const Text('What did you dream about?', style: TextStyle(fontSize: 14, color: Colors.white54)),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DreamInputScreen())),
                        child: Container(
                          width: double.infinity, padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                          ),
                          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
                            SizedBox(height: 10),
                            Text('Record New Dream', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Tap to start your journey', style: TextStyle(color: Colors.white70)),
                          ]),
                        ),
                      ),
                      const SizedBox(height: 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio: 1.3,
                        children: [
                          _buildCard(context, Icons.calendar_today, 'Book Session', 'with a Doctor', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingScreen()))),
                          _buildCard(context, Icons.psychology, 'AI Assistant', 'Chat about dreams', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIAssistantScreen()))),
                          _buildCard(context, Icons.music_note, 'Sleep Music', 'Relax your mind', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepMusicScreen()))),
                          _buildCard(context, Icons.bedtime, 'Sleep Tracker', 'Track your sleep', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepTrackerScreen()))),
                          _buildCard(context, Icons.self_improvement, 'Meditation', 'Calm your mind', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MeditationScreen()))),
                          _buildCard(context, Icons.people, 'Community', 'Share dreams', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF6C63FF), size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class DreamInputScreen extends StatefulWidget {
  const DreamInputScreen({super.key});
  @override
  State<DreamInputScreen> createState() => _DreamInputScreenState();
}

class _DreamInputScreenState extends State<DreamInputScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String _analysis = '';
  Map<String, double> _moodScores = {};
  Color _dreamColor = const Color(0xFF6C63FF);
  String _dreamArtwork = '';

  Color _getMoodColor(Map<String, double> scores) {
    if (scores.isEmpty) return const Color(0xFF6C63FF);
    if ((scores['anxiety'] ?? 0) > 60) return const Color(0xFFFF4444);
    if ((scores['happiness'] ?? 0) > 60) return const Color(0xFFFFD700);
    if ((scores['mystery'] ?? 0) > 60) return const Color(0xFF9B59B6);
    return const Color(0xFF6C63FF);
  }

  Future<void> _analyzeDream() async {
    if (_controller.text.isEmpty) return;
    setState(() { _isLoading = true; _analysis = ''; _moodScores = {}; _dreamArtwork = ''; });
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': '''You are a professional dream psychologist. Analyze this dream and respond in this exact JSON format only:
{
  "analysis": "2-3 sentences psychological analysis",
  "artwork": "Describe as a painting in 1 sentence with colors",
  "anxiety": 45,
  "happiness": 30,
  "mystery": 60,
  "energy": 50
}
Dream: ${_controller.text}'''}]
          }]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        try {
          final jsonStart = text.indexOf('{');
          final jsonEnd = text.lastIndexOf('}') + 1;
          final parsed = jsonDecode(text.substring(jsonStart, jsonEnd));
          setState(() {
            _analysis = parsed['analysis'] ?? text;
            _dreamArtwork = parsed['artwork'] ?? '';
            _moodScores = {
              'Anxiety 😰': (parsed['anxiety'] ?? 50).toDouble(),
              'Happiness 😊': (parsed['happiness'] ?? 50).toDouble(),
              'Mystery 🔮': (parsed['mystery'] ?? 50).toDouble(),
              'Energy ⚡': (parsed['energy'] ?? 50).toDouble(),
            };
            _dreamColor = _getMoodColor({
              'anxiety': (parsed['anxiety'] ?? 50).toDouble(),
              'happiness': (parsed['happiness'] ?? 50).toDouble(),
              'mystery': (parsed['mystery'] ?? 50).toDouble(),
            });
            _isLoading = false;
          });
        } catch (_) {
          setState(() { _analysis = text; _isLoading = false; });
        }
      } else {
        setState(() { _analysis = 'Error: Could not analyze dream.'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _analysis = 'Error: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        overlayColor: _moodScores.isNotEmpty ? _dreamColor : null,
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Tell Your Dream', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Describe your dream in detail...', style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller, maxLines: 5,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'I was walking in a forest when suddenly...',
                          hintStyle: const TextStyle(color: Colors.white24),
                          filled: true, fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: _isLoading ? null : _analyzeDream,
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Analyze My Dream ✨', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      if (_dreamArtwork.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity, height: 130,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [_dreamColor.withOpacity(0.6), const Color(0xFF3B3486)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Icon(Icons.palette, color: Colors.white, size: 25),
                            const SizedBox(height: 8),
                            Text(_dreamArtwork, style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                          ]),
                        ),
                      ],
                      if (_moodScores.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: _dreamColor.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(Icons.psychology, color: _dreamColor),
                                const SizedBox(width: 10),
                                const Text('Dream Mood Score', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ]),
                              const SizedBox(height: 15),
                              ..._moodScores.entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                    Text('${entry.value.toInt()}%', style: TextStyle(color: _dreamColor, fontWeight: FontWeight.bold)),
                                  ]),
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: entry.value / 100,
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      valueColor: AlwaysStoppedAnimation<Color>(_dreamColor),
                                      minHeight: 8,
                                    ),
                                  ),
                                ]),
                              )),
                            ],
                          ),
                        ),
                      ],
                      if (_analysis.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Text(_analysis, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});
  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    final userMessage = _controller.text;
    _controller.clear();
    setState(() { _messages.add({'role': 'user', 'text': userMessage}); _isLoading = true; });

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': 'You are DreamWalk AI, a friendly dream psychologist. Be concise, warm, under 100 words. User: $userMessage'}]}]
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() { _messages.add({'role': 'ai', 'text': text}); _isLoading = false; });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        });
      }
    } catch (e) {
      setState(() { _messages.add({'role': 'ai', 'text': 'Sorry, try again.'}); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('AI Dream Assistant 🤖', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: Text('Ask me about your dreams! 🌙', style: TextStyle(color: Colors.white54, fontSize: 16)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['role'] == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(15),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(msg['text']!, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                            ),
                          );
                        },
                      ),
              ),
              if (_isLoading) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(color: Color(0xFF6C63FF), strokeWidth: 2)),
              Container(
                padding: const EdgeInsets.all(15),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask about your dream...', hintStyle: const TextStyle(color: Colors.white24),
                      filled: true, fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  )),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SleepMusicScreen extends StatefulWidget {
  const SleepMusicScreen({super.key});
  @override
  State<SleepMusicScreen> createState() => _SleepMusicScreenState();
}

class _SleepMusicScreenState extends State<SleepMusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingIndex;

  final List<Map<String, dynamic>> _tracks = [
    {'title': 'Rain Sounds', 'emoji': '🌧️', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Ocean Waves', 'emoji': '🌊', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Forest Night', 'emoji': '🌲', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'title': 'White Noise', 'emoji': '✨', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3'},
  ];

  Future<void> _playTrack(int index) async {
    if (_playingIndex == index) {
      await _audioPlayer.stop();
      setState(() => _playingIndex = null);
    } else {
      await _audioPlayer.play(UrlSource(_tracks[index]['url']));
      setState(() => _playingIndex = index);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Sleep Music 🎵', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose relaxing sounds', style: TextStyle(color: Colors.white54)),
                      const SizedBox(height: 20),
                      ..._tracks.asMap().entries.map((entry) => GestureDetector(
                        onTap: () => _playTrack(entry.key),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _playingIndex == entry.key ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(children: [
                            Text(entry.value['emoji'], style: const TextStyle(fontSize: 30)),
                            const SizedBox(width: 15),
                            Text(entry.value['title'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Icon(_playingIndex == entry.key ? Icons.stop : Icons.play_arrow, color: Colors.white),
                          ]),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});
  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);

  double get _hoursSlept {
    final sleepMinutes = _sleepTime.hour * 60 + _sleepTime.minute;
    final wakeMinutes = _wakeTime.hour * 60 + _wakeTime.minute;
    final diff = wakeMinutes - sleepMinutes;
    return (diff < 0 ? diff + 1440 : diff) / 60;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Sleep Tracker 😴', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(children: [
                          const Text('Total Sleep', style: TextStyle(color: Colors.white70)),
                          Text('${_hoursSlept.toStringAsFixed(1)} hrs', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                          Text(_hoursSlept >= 7 ? '😊 Great sleep!' : '😴 Need more sleep', style: const TextStyle(color: Colors.white70)),
                        ]),
                      ),
                      const SizedBox(height: 30),
                      Row(children: [
                        Expanded(child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: _sleepTime);
                            if (time != null) setState(() => _sleepTime = time);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                            child: Column(children: [
                              const Icon(Icons.bedtime, color: Color(0xFF6C63FF)),
                              const SizedBox(height: 8),
                              const Text('Sleep Time', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              Text(_sleepTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ]),
                          ),
                        )),
                        const SizedBox(width: 15),
                        Expanded(child: GestureDetector(
                          onTap: () async {
                            final time = await showTimePicker(context: context, initialTime: _wakeTime);
                            if (time != null) setState(() => _wakeTime = time);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                            child: Column(children: [
                              const Icon(Icons.wb_sunny, color: Color(0xFF6C63FF)),
                              const SizedBox(height: 8),
                              const Text('Wake Time', style: TextStyle(color: Colors.white54, fontSize: 12)),
                              Text(_wakeTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                            ]),
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});
  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isRunning = false;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Meditation 🧘', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) => Container(
                          width: 200 + _controller.value * 50,
                          height: 200 + _controller.value * 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            border: Border.all(color: const Color(0xFF6C63FF), width: 2),
                          ),
                          child: Center(
                            child: Text(
                              _controller.value > 0.5 ? 'Breathe Out' : 'Breathe In',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('${_seconds ~/ 60}:${(_seconds % 60).toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () {
                          setState(() => _isRunning = !_isRunning);
                          if (_isRunning) {
                            Future.doWhile(() async {
                              await Future.delayed(const Duration(seconds: 1));
                              if (!mounted || !_isRunning) return false;
                              setState(() => _seconds++);
                              return true;
                            });
                          }
                        },
                        child: Text(_isRunning ? 'Stop' : 'Start', style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> posts = [
      {'user': 'Ahmed M.', 'dream': 'I was flying over the pyramids, feeling free and powerful...', 'time': '2h ago'},
      {'user': 'Sara K.', 'dream': 'A strange dream where I could speak to animals in a magical forest...', 'time': '5h ago'},
      {'user': 'Omar R.', 'dream': 'I was swimming in an ocean made of stars, it felt peaceful...', 'time': '1d ago'},
    ];

    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Dream Community 🌍', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          CircleAvatar(backgroundColor: const Color(0xFF6C63FF), child: Text(post['user']![0], style: const TextStyle(color: Colors.white))),
                          const SizedBox(width: 10),
                          Text(post['user']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Text(post['time']!, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ]),
                        const SizedBox(height: 10),
                        Text(post['dream']!, style: const TextStyle(color: Colors.white70, height: 1.5)),
                        const SizedBox(height: 10),
                        Row(children: const [
                          Icon(Icons.favorite_border, color: Color(0xFF6C63FF), size: 18),
                          SizedBox(width: 5),
                          Text('Like', style: TextStyle(color: Color(0xFF6C63FF))),
                          SizedBox(width: 20),
                          Icon(Icons.comment_outlined, color: Color(0xFF6C63FF), size: 18),
                          SizedBox(width: 5),
                          Text('Comment', style: TextStyle(color: Color(0xFF6C63FF))),
                        ]),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Profile', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        width: 100, height: 100,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF3B3486)]),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 15),
                      Text(user?.email ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.withOpacity(0.3),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                        },
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? selectedTime;

  final List<Map<String, dynamic>> doctors = [
    {'name': 'Dr. Ibrahim Swilem', 'specialty': 'Psychology', 'rating': '5.0', 'phone': '01009836063', 'whatsapp': '01009836063'},
  ];

  final List<String> timeSlots = ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM', '6:00 PM'];

  Future<void> _makeCall(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _openWhatsapp(String phone) async {
    final Uri url = Uri.parse('https://wa.me/20$phone');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedStarsBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(backgroundColor: Colors.transparent, elevation: 0,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                title: const Text('Book a Session', style: TextStyle(color: Colors.white)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose a Doctor', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      ...doctors.map((doctor) => Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(children: [
                          Row(children: [
                            const CircleAvatar(backgroundColor: Color(0xFF3B3486), child: Icon(Icons.person, color: Colors.white)),
                            const SizedBox(width: 15),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(doctor['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(doctor['specialty']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ])),
                            Text('⭐ ${doctor['rating']}', style: const TextStyle(color: Colors.white)),
                          ]),
                          const SizedBox(height: 15),
                          Row(children: [
                            Expanded(child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () => _makeCall(doctor['phone']!),
                              icon: const Icon(Icons.phone, size: 16, color: Colors.white),
                              label: const Text('Call', style: TextStyle(color: Colors.white)),
                            )),
                            const SizedBox(width: 8),
                            Expanded(child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                              onPressed: () => _openWhatsapp(doctor['whatsapp']!),
                              icon: const Icon(Icons.chat, size: 16, color: Colors.white),
                              label: const Text('WhatsApp', style: TextStyle(color: Colors.white)),
                            )),
                          ]),
                        ]),
                      )),
                      const SizedBox(height: 20),
                      const Text('Choose Time', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Wrap(
                        spacing: 10, runSpacing: 10,
                        children: timeSlots.map((time) => GestureDetector(
                          onTap: () => setState(() => selectedTime = time),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: selectedTime == time ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: selectedTime == time ? const Color(0xFF6C63FF) : Colors.white.withOpacity(0.1)),
                            ),
                            child: Text(time, style: const TextStyle(color: Colors.white)),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: selectedTime != null ? () {
                            showDialog(context: context, builder: (_) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1A2E),
                              title: const Text('Booking Confirmed! ✅', style: TextStyle(color: Colors.white)),
                              content: Text('Your session with Dr. Ibrahim Swilem at $selectedTime has been booked!', style: const TextStyle(color: Colors.white70)),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great!', style: TextStyle(color: Color(0xFF6C63FF))))],
                            ));
                          } : null,
                          child: const Text('Confirm Booking 📅', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}