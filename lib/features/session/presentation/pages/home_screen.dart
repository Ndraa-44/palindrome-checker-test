import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
        const SnackBar(
          content: Text('Sentence cannot be empty'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
      return;
    }

    final isPalindromic = isPalindrome(sentence);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          isPalindromic ? 'isPalindrome' : 'not palindrome',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.jetBrainsMono(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _onNext() {
    final name = _nameController.text;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppTheme.primaryColor,
        ),
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
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'PALINDROME CHECKER',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'The Symmetrical Word.',
                    style: GoogleFonts.literata(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white30,
                  child: Icon(
                    Icons.person_add,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'NAME',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(_nameController, 'Arthur'),
                const SizedBox(height: 20),
                Text(
                  'SENTENCE OR WORD',
                  style: GoogleFonts.jetBrainsMono(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextField(_sentenceController, 'racecar'),
                const SizedBox(height: 24),
                _buildReflectionEngine(),
                const SizedBox(height: 32),
                _buildButton('CHECK', AppTheme.primaryColor, _checkPalindrome),
                const SizedBox(height: 16),
                _buildNextButton(),
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
      style: GoogleFonts.jetBrainsMono(
        color: AppTheme.textPrimaryColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.jetBrainsMono(
          color: AppTheme.hintTextColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildReflectionEngine() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'REFLECTION',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white60,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _sentenceController,
            builder: (context, value, child) {
              final text = value.text.isEmpty ? 'racecar' : value.text;
              
              // Simple check for dynamic match status
              final isMatch = value.text.isNotEmpty && isPalindrome(value.text);
              final statusColor = isMatch ? Colors.white : Colors.white60;
              final statusText = isMatch ? 'MATCH DETECTED' : 'AWAITING MATCH';
              
              return Column(
                children: [
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white24, height: 1, thickness: 1),
                  const SizedBox(height: 12),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(math.pi),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white54,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        statusText,
                        style: GoogleFonts.jetBrainsMono(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            AppTheme.tertiaryColor,
            Color(0xFF4A3C82), // Darker shade of tertiaryColor for gradient depth
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.tertiaryColor.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _onNext,
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEXT',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
