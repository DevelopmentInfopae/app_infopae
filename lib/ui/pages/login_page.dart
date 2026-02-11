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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(colorFondo),
      body: Padding(
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
                      textAlign: TextAlign.center,   // ✔ Centra el texto
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,          // ✔ Color blanco
                      ),
                    ),
                    const SizedBox(height: 80),
                    
                    // Campo de Usuario
                    TextField(
                      controller: _userController,
                      style: const TextStyle(color: Color(colorLetra)),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(colorInput),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(colorLetra)), // Borde normal
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(colorLetra)), // Borde cuando escribes
                        ),
                        labelText: 'Usuario',
                        labelStyle: TextStyle(
                          color: Color(colorLetra), // El color que prefieras
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(colorLetra), // Aquí eliges el color
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Campo de Contraseña
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Color(colorLetra)),
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(colorInput),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(colorLetra)), // Borde normal
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Color(colorLetra)), // Borde cuando escribes
                        ),
                        labelText: 'Contraseña',
                        labelStyle: const TextStyle(
                          color: Color(colorLetra), // El color que prefieras
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
                            _isObscured ? Icons.visibility_off : Icons.visibility,
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
                    const SizedBox(height: 30),

                    // Botón con lógica de estado
                    BlocConsumer<LoginCubit, LoginState>(
                      listener: (context, state) {
                        if (state is LoginError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.message), backgroundColor: Colors.red.shade400),
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
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(colorButton),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10), // Bordes redondeados
                                ),
                              ),
                            onPressed: () {
                              // Enviamos los datos al Cubit
                              context.read<LoginCubit>().login(
                                _userController.text, 
                                _passwordController.text
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "INICIAR SESIÓN",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 20),
                                Icon(Icons.login)
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15,),
                    TextButton(
                      onPressed: (){
                        print("recuperación de contraseña");
                      }, 
                      child: const Text(
                        "¿Olvidó su contraseña?",
                        style: TextStyle(
                          color: Color(colorLetra),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      )
                    ),

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
                    color: const Color(colorLetra).withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Versión 1.0.0",
                  style: TextStyle(
                    color: const Color(colorLetra).withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}