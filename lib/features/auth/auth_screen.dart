import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/app_colors.dart';
import '../home/main_shell.dart';

/// Authentication screen with a high-fidelity Black & White glassmorphic design and Lucide Icons.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  bool _isLogin = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.easeIn)),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    if (!value.toLowerCase().endsWith('@gmail.com')) return 'Only @gmail.com emails are authorized';
    if (value.toLowerCase().startsWith('abc@')) return 'This email ID is not authorized';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value == '12345678') return 'This password is too common';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Must contain at least one uppercase letter';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Must contain at least one number';
    return null;
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const MainShell(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.mainBgGradient),
          ),
          
          // Floating Glows
          Positioned(
            top: -100,
            left: -100,
            child: _GlowCircle(color: Colors.white.withValues(alpha: 0.1), size: 300),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _GlowCircle(color: Colors.white.withValues(alpha: 0.05), size: 250),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        
                        // Premium Monochrome Logo
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                )
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Image.asset('assets/images/app_icon.png', fit: BoxFit.contain),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        
                        Text(
                          _isLogin ? 'Venture\nAwaits' : 'Begin the\nJourney',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            height: 0.9,
                            letterSpacing: -2.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isLogin ? 'Access your high-end travel plans' : 'Join a world of curated experiences',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 60),
  
                        // Glassmorphic Form Container
                        Column(
                          children: [
                            if (!_isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                hint: 'Full Name',
                                icon: LucideIcons.user,
                                validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _emailController,
                              hint: 'Email Address',
                              icon: LucideIcons.mail,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'Password',
                              icon: LucideIcons.lock,
                              isPassword: true,
                              validator: _validatePassword,
                            ),
                          ],
                        ),
  
                        if (_isLogin) ...[
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                final emailCtrl = TextEditingController();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: const Color(0xFF111111),
                                    title: const Text('Reset Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                    content: TextField(
                                      controller: emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(color: Colors.white),
                                      decoration: const InputDecoration(
                                        hintText: 'Enter your email',
                                        hintStyle: TextStyle(color: Colors.white38),
                                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
                                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold))),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Reset link sent! Check your email.', style: TextStyle(fontWeight: FontWeight.w600)),
                                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          );
                                        },
                                        child: const Text('SEND LINK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
  
                        const SizedBox(height: 48),
  
                        // Monochrome Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              elevation: 0,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: _isLoading 
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                ) 
                              : Text(
                                  _isLogin ? 'Sign In' : 'Get Started',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                ),
                          ),
                        ),
  
                        const SizedBox(height: 32),
  
                        // Toggle Button
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() => _isLogin = !_isLogin),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 15),
                                children: [
                                  TextSpan(text: _isLogin ? "New to the club? " : "Already a member? "),
                                  TextSpan(
                                    text: _isLogin ? "Sign Up" : "Log In",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontWeight: FontWeight.w400),
              prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.3), size: 20),
              border: InputBorder.none,
              errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              contentPadding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            ),
          ),
        ),
      ),
    );
  }

}

class _GlowCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          )
        ],
      ),
    );
  }
}
