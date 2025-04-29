import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pureflow/core/router/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;
  
  const VerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _isResending = false;
  String? _errorMessage;
  bool _showDebugPanel = false;
  List<String> _debugLogs = [];

  @override
  void initState() {
    super.initState();
    _addDebugLog('Screen initialized with email: ${widget.email}');
    _checkSupabaseSession();
  }

  void _addDebugLog(String log) {
    setState(() {
      _debugLogs.add('${DateTime.now().toString().substring(11, 19)}: $log');
    });
  }

  Future<void> _checkSupabaseSession() async {
    try {
      print('DEBUG: Checking Supabase session');
      final session = Supabase.instance.client.auth.currentSession;
      final user = Supabase.instance.client.auth.currentUser;
      
      print('DEBUG: Session status - Has session: ${session != null}');
      print('DEBUG: User status - Has user: ${user != null}');
      
      if (user != null) {
        print('DEBUG: User ID: ${user.id}');
        print('DEBUG: Email confirmed: ${user.emailConfirmedAt != null}');
        print('DEBUG: User metadata: ${user.userMetadata}');
      }
    } catch (e) {
      print('DEBUG: Error checking session: $e');
    }
  }

  Future<void> _testSupabaseConnection() async {
    try {
      print('DEBUG: Testing Supabase connection...');
      // Use a simpler approach to test connection - just check if we can access the API
      final result = await Supabase.instance.client.from('_dummy_').select().limit(1).maybeSingle();
      print('DEBUG: Connection test result: ${result != null ? 'Success (got response)' : 'Success (empty response)'}');
    } catch (e) {
      print('DEBUG: Connection test error: $e');
    }
  }

  // For development purposes only - simulates email resend
  Future<void> _handleDevelopmentResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    _addDebugLog('Development mode: Simulating email resend');
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    _addDebugLog('Development mode: Email resend simulation complete');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification email resent successfully (Development Mode)'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() {
      _isResending = false;
    });
  }

  // The real email resend method for production
  Future<void> _handleRealResend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
    });

    print('DEBUG: Attempting to resend verification email');
    print('DEBUG: Email: ${widget.email}');

    try {
      // Resend verification email using Supabase
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: widget.email,
        emailRedirectTo: null, // No redirect for development
      );

      print('DEBUG: Verification email resent successfully');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email resent successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (e) {
      print('DEBUG: AuthException during resend: ${e.message}');
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      print('DEBUG: Unexpected error during resend: $e');
      setState(() {
        _errorMessage = 'An unexpected error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // Use the development handler for now
  Future<void> _resendVerificationEmail() async {
    // For development, we'll use the simplified flow
    await _handleDevelopmentResend();
    
    // For production, uncomment this line and comment out the one above
    // await _handleRealResend();
  }

  @override
  Widget build(BuildContext context) {
    // Create message based on platform
    final String verificationInstructions = kIsWeb
        ? 'Click the link in the email to verify your account. You may need to check your spam folder.\n\nIn development mode, you can simply click "Go to Login" to proceed.'
        : 'Click the link in the email to verify your account.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        actions: [
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              setState(() {
                _showDebugPanel = !_showDebugPanel;
              });
              if (_showDebugPanel) {
                _checkSupabaseSession();
              }
            },
            tooltip: 'Toggle Debug Panel',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'DEMO',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _showDebugPanel 
              ? _buildDebugPanel() 
              : _buildMainVerificationContent(verificationInstructions),
        ),
      ),
    );
  }

  Widget _buildDebugPanel() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Debug Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showDebugPanel = false;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            Text('Email: ${widget.email}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Supabase URL: ${dotenv.env['SUPABASE_URL'] ?? 'Not available'}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _checkSupabaseSession,
                  child: const Text('Check Session'),
                ),
                ElevatedButton(
                  onPressed: _testSupabaseConnection,
                  child: const Text('Test Connection'),
                ),
                ElevatedButton(
                  onPressed: _handleRealResend,
                  child: const Text('Real Resend'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Debug Logs:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _debugLogs.length,
                itemBuilder: (context, index) {
                  return Text(
                    _debugLogs[_debugLogs.length - 1 - index],
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go(Routes.login);
                },
                child: const Text('Go to Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVerificationContent(String verificationInstructions) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mark_email_read,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We\'ve sent a verification email to:\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              verificationInstructions,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'After verification, you can log in to your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Colors.red.shade800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go(Routes.login);
                },
                child: const Text('Go to Login'),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _isResending ? null : _resendVerificationEmail,
              icon: _isResending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(_isResending ? 'Sending...' : 'Resend Email'),
            ),
          ],
        ),
      ),
    );
  }
} 