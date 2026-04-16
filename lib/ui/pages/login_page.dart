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
  bool _isObscured = true;
  final colorFondo = 0xFF1a242e;
  static const colorLetra = 0xFFF0F7F4;
  static const colorInput = 0xFF2a3841;
  static const colorButton = 0xFF10b77f;

  @override
  void initState() {
    super.initState();
    // Asignamos el valor al controller
    _userController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(colorFondo),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 120),
                      Center(
                        child: Image.asset(
                          "assets/logos/logo.png",
                          width: 250,
                        ),
                      ),
                      // const SizedBox(height: 60),
                      const Text(
                        "Programa de alimentación escolar",
                        textAlign: TextAlign.center, // ✔ Centra el texto
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // ✔ Color blanco
                        ),
                      ),
                      const SizedBox(height: 80),

                      // Campo de Usuario
                      Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Colors.white, // cursor
                            selectionHandleColor: Colors.white, // ✅ la flechita
                            selectionColor: Colors
                                .white24, // color del texto seleccionado (opcional)
                          ),
                        ),
                        child: TextField(
                          controller: _userController,
                          style: const TextStyle(color: Color(colorLetra)),
                          cursorColor: Colors.white,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Color(colorInput),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(colorLetra)), // Borde normal
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(
                                      colorLetra)), // Borde cuando escribes
                            ),
                            labelText: 'Usuario',
                            labelStyle: TextStyle(
                              color:
                                  Color(colorLetra), // El color que prefieras
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(colorLetra), // Aquí eliges el color
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campo de Contraseña
                      Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: const TextSelectionThemeData(
                            cursorColor: Colors.white, // cursor
                            selectionHandleColor: Colors.white, // ✅ la flechita
                            selectionColor: Colors
                                .white24, // color del texto seleccionado (opcional)
                          ),
                        ),
                        child: TextField(
                          controller: _passwordController,
                          style: const TextStyle(color: Color(colorLetra)),
                          obscureText: _isObscured,
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(colorInput),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(colorLetra)), // Borde normal
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(
                                      colorLetra)), // Borde cuando escribes
                            ),
                            labelText: 'Contraseña',
                            labelStyle: const TextStyle(
                              color:
                                  Color(colorLetra), // El color que prefieras
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Color(colorLetra), // Aquí eliges el color
                            ),
                            // 2. Agregamos el botón del ojo al final
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Cambia el icono según el estado
                                _isObscured
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(colorLetra),
                              ),
                              onPressed: () {
                                // 3. Cambiamos el estado para refrescar la pantalla
                                setState(() {
                                  _isObscured = !_isObscured;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón con lógica de estado
                      BlocConsumer<LoginCubit, LoginState>(
                        listener: (context, state) {
                          if (state is LoginError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(state.message),
                                  backgroundColor: Colors.red.shade400),
                            );
                          }

                          if (state is LoginUsuarioDiferente) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.mensaje),
                                backgroundColor: Colors.orange.shade700,
                                duration: const Duration(
                                    seconds: 5), // 👈 Más tiempo para leer
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }

                          if (state is LoginSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Ingreso Exitoso"),
                                  backgroundColor: Colors.green),
                            );
                            Navigator.pushReplacementNamed(context, '/home');
                          }
                        },
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return const CircularProgressIndicator(
                              color: Colors.white,
                            );
                          }

                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(colorButton),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // Bordes redondeados
                                ),
                              ),
                              onPressed: () {
                                // Enviamos los datos al Cubit
                                context.read<LoginCubit>().login(
                                    _userController.text,
                                    _passwordController.text);
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "INICIAR SESIÓN",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  SizedBox(width: 20),
                                  Icon(
                                    Icons.login,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 15,
                      ),
                      // TextButton(
                      //   onPressed: (){

                      //   },
                      //   child: const Text(
                      //     "¿Olvidó su contraseña?",
                      //     style: TextStyle(
                      //       color: Color(colorLetra),
                      //       fontWeight: FontWeight.w600,
                      //       decoration: TextDecoration.underline,
                      //     ),
                      //   )
                      // ),
                    ],
                  ),
                ),
              ),
              // 2. Footer (Siempre se queda abajo)
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: Column(
                  children: [
                    Text(
                      "Control de Entregas",
                      style: TextStyle(
                        color: const Color(colorLetra).withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Versión 1.0.2",
                      style: TextStyle(
                        color: const Color(colorLetra).withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
