import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  static const _mockUser = UserEntity(
    id: 'usr-001',
    username: 'sphiri',
    fullName: 'Sergeant Samuel Phiri',
    badgeNumber: 'MPS-4421',
    role: UserRole.stationSupervisor,
    stationId: 'stn-lil-001',
    stationName: 'Lilongwe Central Police Station',
    deviceId: 'DEV-LIL-001',
  );

  Future<void> login({required String username, required String password}) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 2));

    if (username.trim().isEmpty || password.trim().isEmpty) {
      emit(const AuthError('Username and password are required.'));
      return;
    }

    // Mock: any non-empty credentials succeed
    emit(AuthAuthenticated(_mockUser));
  }

  void logout() => emit(AuthInitial());
}

