import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a242e),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Image.asset(
                  "assets/logos/logo.png",
                  width: 220,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Programa de alimentación escolar",
                textAlign: TextAlign.center,   // ✔ Centra el texto
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,          // ✔ Color blanco
                ),
              ),
              const SizedBox(height: 40),
              
              // Campo de Usuario
              TextField(
                controller: _userController,
                style: const TextStyle(color: Color(0xFFF0F7F4)),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF2a3841),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF0F7F4)), // Borde normal
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFF0F7F4)), // Borde cuando escribes
                  ),
                  // labelText: 'Usuario',
                  // border: OutlineInputBorder(),
                  // prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              
              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true, // Esto oculta el texto
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              // Botón con lógica de estado
              BlocConsumer<LoginCubit, LoginState>(
                listener: (context, state) {
                  if (state is LoginError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  }
                  if (state is LoginSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ingreso Exitoso"), backgroundColor: Colors.green),
                    );
                    // Aquí iría: Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                builder: (context, state) {
                  if (state is LoginLoading) {
                    return const CircularProgressIndicator();
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Enviamos los datos al Cubit
                        context.read<LoginCubit>().login(
                          _userController.text, 
                          _passwordController.text
                        );
                      },
                      child: const Text("INGRESAR"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}