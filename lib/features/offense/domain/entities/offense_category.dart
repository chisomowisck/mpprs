import 'package:equatable/equatable.dart';

class OffenseCategory extends Equatable {
  final String id;
  final String code;
  final String name;
  final String groupName;
  final double defaultAmount;
  final bool isAmountEditable;
  final String revenueCode;

  const OffenseCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.groupName,
    required this.defaultAmount,
    required this.revenueCode,
    this.isAmountEditable = false,
  });

  @override
  List<Object?> get props => [id, code];
}

class ServiceCategory extends Equatable {
  final String id;
  final String code;
  final String name;
  final String groupName;
  final double defaultAmount;
  final bool isAmountEditable;
  final String revenueCode;
  final int deadlineDays;

  const ServiceCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.groupName,
    required this.defaultAmount,
    required this.revenueCode,
    this.isAmountEditable = false,
    this.deadlineDays = 7,
  });

  @override
  List<Object?> get props => [id, code];
}

