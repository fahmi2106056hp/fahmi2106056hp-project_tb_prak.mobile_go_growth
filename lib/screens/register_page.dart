import 'package:achievement_app/main.dart';
import 'package:flutter/material.dart';
import 'achievement_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  void _showNotification(String title, String body) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your_channel_id', 'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', style: GoogleFonts.lato()),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/logo.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Shimmer(
            duration: Duration(seconds: 2),
            color: Colors.white,
            colorOpacity: 0.5,
            enabled: true,
            direction: ShimmerDirection.fromLTRB(),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'WELCOME TO GO GROWTH',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.purple,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Card(
                      color: Colors.white.withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              style: GoogleFonts.lato(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Masukkan email yang valid';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: GoogleFonts.roboto(),
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (value.length < 8) {
                                  return 'Password harus terdiri dari minimal 8 karakter';
                                }
                                if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$')
                                    .hasMatch(value)) {
                                  return 'Password harus terdiri dari kombinasi huruf dan angka';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: InputDecoration(
                                labelText: 'Konfirmasi Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                              ),
                              style: GoogleFonts.roboto(),
                              obscureText: !_passwordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi Password tidak boleh kosong';
                                }
                                if (value != _passwordController.text) {
                                  return 'Password tidak cocok';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _register();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                              icon: Icon(Icons.check, color: Colors.white),
                              label: Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _register() {
    _showNotification('Registrasi Berhasil', 'Selamat datang di Go Growth!');
    _showDialog('Berhasil', 'Registrasi berhasil.', true);
  }

  void _showDialog(String title, String content, bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AchievementList(),
                    ),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
