import 'package:equatable/equatable.dart';

enum TransactionType { trafficOffense, serviceFee }

enum TransactionStatus {
  draft,
  issuedUnpaid,
  paid,
  overdue,
  voided,
  error,
  pendingSync,
  failedSync,
}

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.draft:
        return 'Draft';
      case TransactionStatus.issuedUnpaid:
        return 'Unpaid';
      case TransactionStatus.paid:
        return 'Paid';
      case TransactionStatus.overdue:
        return 'Overdue';
      case TransactionStatus.voided:
        return 'Voided';
      case TransactionStatus.error:
        return 'Error';
      case TransactionStatus.pendingSync:
        return 'Pending Sync';
      case TransactionStatus.failedSync:
        return 'Sync Failed';
    }
  }
}

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final String? prn;
  final String categoryName;
  final String categoryCode;
  final double amount;
  final DateTime issuedAt;
  final DateTime? deadline;
  final DateTime? paidAt;
  final String offenderName;
  final String? vehicleReg;
  final String? maltisRef;
  final String officerName;
  final String officerId;
  final String stationName;
  final String deviceId;
  final String? voidReason;
  final String? voidedBy;
  final DateTime? voidedAt;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.status,
    this.prn,
    required this.categoryName,
    required this.categoryCode,
    required this.amount,
    required this.issuedAt,
    this.deadline,
    this.paidAt,
    required this.offenderName,
    this.vehicleReg,
    this.maltisRef,
    required this.officerName,
    required this.officerId,
    required this.stationName,
    required this.deviceId,
    this.voidReason,
    this.voidedBy,
    this.voidedAt,
  });

  bool get canBeVoided =>
      status == TransactionStatus.issuedUnpaid || status == TransactionStatus.overdue;

  bool get isNearingDeadline {
    if (deadline == null) return false;
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 3;
  }

  @override
  List<Object?> get props => [id, prn, status];
}

