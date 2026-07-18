import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:km_test/core/theme/app_theme.dart';
import 'package:km_test/features/session/presentation/bloc/session_bloc.dart';
import 'package:km_test/features/session/presentation/bloc/session_state.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Second Screen',
          style: GoogleFonts.literata(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.tertiaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.withValues(alpha: 0.1),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: BlocBuilder<SessionBloc, SessionState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.hintTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.name.isEmpty ? 'John Doe' : state.name,
                    style: GoogleFonts.literata(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Card for Selected User
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.selectedUserName.isEmpty
                                    ? 'Selected User Name'
                                    : state.selectedUserName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.literata(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              Text(
                                'AUTH_ID: ${state.selectedUserEmail.isEmpty ? 'None' : state.selectedUserEmail}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.hintTextColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'STATUS: ACTIVE',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.tertiaryColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Top Right Corner decoration
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: Colors.grey, width: 2),
                                right: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                          ),
                        ),
                        
                        // Bottom Left Corner decoration
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey, width: 2),
                                left: BorderSide(color: Colors.grey, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Choose User Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/users');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'CHOOSE A USER',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
