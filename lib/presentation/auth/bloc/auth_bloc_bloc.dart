import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_bloc_event.dart';
import 'auth_bloc_state.dart';
import '../../../service/auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService httpClient;

  AuthBloc(this.httpClient) : super(AuthInitial()) {
    // LOGIN
    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await httpClient.post('/login', {
          'email': event.email,
          'password': event.password,
        });

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final token = data['data']['token'];
          final user = data['data']['user'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', user['id'].toString());
          await prefs.setString('name', user['name']);
          await prefs.setString('email', user['email']);
          await prefs.setString('role', user['role']); 
          const storage = FlutterSecureStorage();
          await storage.write(key: 'token', value: token);

          emit(AuthAuthenticated(
            name: user['name'],
            email: user['email'],
            role: user['role'], 
          ));
        } else {
          final error = jsonDecode(response.body);
          emit(AuthError(error['message'] ?? 'Login gagal'));
        }
      } catch (e) {
        emit(AuthError('Terjadi kesalahan: $e'));
      }
    });

    // REGISTER
    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await httpClient.post('/register', {
          'name': event.name,
          'email': event.email,
          'password': event.password,
          'password_confirmation': event.passwordConfirmation,
        });

        if (response.statusCode == 201) {
          emit(AuthRegisterSuccess());
        } else {
          final error = jsonDecode(response.body);
          emit(AuthError(error['message'] ?? 'Registrasi gagal'));
        }
      } catch (e) {
        emit(AuthError('Terjadi kesalahan: $e'));
      }
    });

    // LOGOUT
    on<AuthLogoutRequested>((event, emit) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      const storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      emit(AuthInitial());
    });

    // CEK STATUS LOGIN
    on<AuthCheckStatus>((event, emit) async {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('name');
      final email = prefs.getString('email');
      final role = prefs.getString('role');

      if (token != null && token.isNotEmpty && name != null && email != null && role != null) {
        emit(AuthAuthenticated(name: name, email: email, role: role));
      } else {
        emit(AuthInitial());
      }
    });
  }
}
