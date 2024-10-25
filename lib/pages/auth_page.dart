import 'package:collector_app/pages/admin_page.dart';
import 'package:collector_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final _authBlock = AuthBloc();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final box = Hive.box('userInfo');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows resizing when keyboard appears
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Hermes Market'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor: Theme.of(context).colorScheme.inversePrimary,
          tabs: const [
            Tab(text: 'Авторизация'),
            Tab(text: 'Регистрация'),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        bloc: _authBlock,
        listener: (context, state) {
          if (state is AuthFailure) {
            _showErrorDialog(state.error);
          } else if (state is AuthSuccess) {
            box.put('auth', state.user);
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => HomePage(),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          }
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAuthorizationTab(),
            _buildRegistrationTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizationTab() {
    return _buildAuthForm(isRegistration: false);
  }

  Widget _buildRegistrationTab() {
    return _buildAuthForm(isRegistration: true);
  }

  Widget _buildAuthForm({required bool isRegistration}) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: isRegistration ? 40 : 70,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                width: 150,
                height: 150,
                child: Image.asset('assets/imgs/icon.png'),
              ),
            ),
            const SizedBox(height: 30),
            _buildTextField(controller: _emailController, labelText: 'Email'),
            const SizedBox(height: 16),
            if (isRegistration)
              _buildTextField(
                controller: _phoneNumberController,
                labelText: 'Номер телефона',
              ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _passwordController,
              labelText: 'Пароль',
              obscureText: !_isPasswordVisible,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            if (isRegistration)
              _buildTextField(
                controller: _confirmPasswordController,
                labelText: 'Подтвердите пароль',
                obscureText: !_isConfirmPasswordVisible,
                isPassword: true,
              ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                if (isRegistration) {
                  _authBlock.add(
                    RegisterEvent(
                      email: _emailController.text,
                      password: _passwordController.text,
                      confirmPassword: _confirmPasswordController.text,
                      phoneNumber: _phoneNumberController.text,
                    ),
                  );
                } else {
                  if (_emailController.text == "admin") {
                    if (_passwordController.text == "admin") {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AdminPage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                      return;
                    }
                  }
                  _authBlock.add(
                    LoginEvent(
                      email: _emailController.text,
                      password: _passwordController.text,
                    ),
                  );
                }
              },
              child: BlocBuilder<AuthBloc, AuthState>(
                bloc: _authBlock,
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return _buildLoadingButton();
                  }
                  return _buildAuthButton(isRegistration);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthButton(bool isRegistration) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          isRegistration ? 'Зарегистрироваться' : 'Войти',
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ошибка'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'ОК',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: controller.text.isEmpty
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.inversePrimary,
        ),
        border: const OutlineInputBorder(),
        suffixIcon: isPassword
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    if (controller == _passwordController) {
                      _isPasswordVisible = !_isPasswordVisible;
                    } else {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }
}
