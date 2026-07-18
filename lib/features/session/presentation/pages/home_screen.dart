import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:km_test/core/theme/app_theme.dart';
import 'package:km_test/core/utils/palindrome_checker.dart';
import 'package:km_test/features/session/presentation/bloc/session_bloc.dart';
import 'package:km_test/features/session/presentation/bloc/session_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _sentenceController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _sentenceController.dispose();
    super.dispose();
  }

  void _checkPalindrome() {
    final sentence = _sentenceController.text;
    if (sentence.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sentence cannot be empty')),
      );
      return;
    }

    final isPalindromic = isPalindrome(sentence);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(isPalindromic ? 'isPalindrome' : 'not palindrome'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    context.read<SessionBloc>().add(SaveName(name));
    Navigator.pushNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF5AB6A0), 
              Color(0xFF384371),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white30,
                  child: Icon(
                    Icons.person_add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                _buildTextField(_nameController, 'Name'),
                const SizedBox(height: 16),
                _buildTextField(_sentenceController, 'Palindrome'),
                const SizedBox(height: 48),
                _buildButton('CHECK', _checkPalindrome),
                const SizedBox(height: 16),
                _buildButton('NEXT', _onNext),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.hintTextColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryButtonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
}
