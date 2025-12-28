import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  bool loading = false;
  bool isLogin = true;
  bool hidePassword = true;
  bool hideConfirm = true;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    final supabase = Supabase.instance.client;

    final email = emailCtrl.text.trim();
    final password = passCtrl.text;

    if (!isValidEmail(email)) {
      showMsg("Enter a valid email");
      return;
    }

    if (password.length < 6) {
      showMsg("Password must be at least 6 characters");
      return;
    }

    if (!isLogin && password != confirmCtrl.text) {
      showMsg("Passwords do not match");
      return;
    }

    setState(() => loading = true);

    try {
      if (isLogin) {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
      }
    } on AuthException catch (e) {
      showMsg(e.message);
    } catch (_) {
      showMsg("Authentication failed");
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= FORGOT PASSWORD =================
  void showResetDialog() {
    final resetCtrl = TextEditingController(text: emailCtrl.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reset Password"),
        content: TextField(
          controller: resetCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email",
            prefixIcon: Icon(Icons.email),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            child: const Text("Send Link"),
            onPressed: () async {
              final email = resetCtrl.text.trim();

              if (!isValidEmail(email)) {
                showMsg("Enter a valid email");
                return;
              }

              try {
                await Supabase.instance.client.auth
                    .resetPasswordForEmail(email);
                Navigator.pop(context);
                showMsg("Password reset email sent");
              } catch (_) {
                showMsg("Failed to send reset email");
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.report_problem_rounded,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Incident Reporter",
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLogin
                        ? "Sign in to continue"
                        : "Create a new account",
                  ),

                  const SizedBox(height: 28),

                  // EMAIL
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD
                  TextField(
                    controller: passCtrl,
                    obscureText: hidePassword,
                    textInputAction:
                    isLogin ? TextInputAction.done : TextInputAction.next,
                    onSubmitted: (_) {
                      if (isLogin) submit();
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                      ),
                    ),
                  ),

                  // CONFIRM PASSWORD (REGISTER)
                  if (!isLogin) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: hideConfirm,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => submit(),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            hideConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => hideConfirm = !hideConfirm);
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // 🔐 FORGOT PASSWORD (LOGIN ONLY)
                  if (isLogin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: showResetDialog,
                        child: Text(
                          "Forgot password?",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  // SUBMIT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        isLogin ? "Login" : "Register",
                        style:
                        const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // SWITCH LOGIN / REGISTER
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                          confirmCtrl.clear();
                        });
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: isLogin
                                  ? "Don’t have an account? "
                                  : "Already have an account? ",
                            ),
                            TextSpan(
                              text: isLogin ? "Register" : "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                theme.colorScheme.primary,
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
}