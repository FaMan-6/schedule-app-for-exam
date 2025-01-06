import 'package:flutter/material.dart';
import 'package:schedule_app/pages/home_page.dart';
import 'package:schedule_app/pages/signup_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://conphwifmfzljmvtmrmu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvbnBod2lmbWZ6bGptdnRtcm11Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMzODAyNDEsImV4cCI6MjA0ODk1NjI0MX0.VU2H9UCUqclz6e4zolHSD13TaFIYiqHAieuruM1M9Ss',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
      },

      debugShowCheckedModeBanner: false,
      home: const SignupPage(),
      // home: RegisterPage(),
      // home: HomePage(),
      // home: AddPage(),
    );
  }
}
