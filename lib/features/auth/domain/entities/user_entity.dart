import 'package:equatable/equatable.dart';

enum UserRole { trafficOfficer, stationSupervisor, financeViewer }

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String badgeNumber;
  final UserRole role;
  final String stationId;
  final String stationName;
  final String deviceId;

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.badgeNumber,
    required this.role,
    required this.stationId,
    required this.stationName,
    required this.deviceId,
  });

  String get roleLabel {
    switch (role) {
      case UserRole.trafficOfficer:
        return 'Traffic Officer';
      case UserRole.stationSupervisor:
        return 'Station Supervisor';
      case UserRole.financeViewer:
        return 'Finance/Audit Viewer';
    }
  }

  bool get canVoidPrn =>
      role == UserRole.stationSupervisor;

  bool get canViewStationPrns =>
      role == UserRole.stationSupervisor || role == UserRole.financeViewer;

  @override
  List<Object?> get props => [id, username, role, stationId, deviceId];
}

