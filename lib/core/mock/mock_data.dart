import '../../features/offense/domain/entities/offense_category.dart';
import '../../features/transactions/domain/entities/transaction_entity.dart';

class MockData {
  MockData._();

  static const List<OffenseCategory> offenseCategories = [
    OffenseCategory(id: 'tf001', code: 'TF-001', name: 'Speeding', groupName: 'Speed Violations', defaultAmount: 20000, revenueCode: 'RC-TF-001'),
    OffenseCategory(id: 'tf002', code: 'TF-002', name: 'Reckless Driving', groupName: 'Dangerous Driving', defaultAmount: 50000, revenueCode: 'RC-TF-002'),
    OffenseCategory(id: 'tf003', code: 'TF-003', name: 'Driving Without Licence', groupName: 'Licence Violations', defaultAmount: 15000, revenueCode: 'RC-TF-003'),
    OffenseCategory(id: 'tf004', code: 'TF-004', name: 'No Insurance Certificate', groupName: 'Document Violations', defaultAmount: 30000, revenueCode: 'RC-TF-004'),
    OffenseCategory(id: 'tf005', code: 'TF-005', name: 'Running Red Light', groupName: 'Traffic Signal Violations', defaultAmount: 25000, revenueCode: 'RC-TF-005'),
    OffenseCategory(id: 'tf006', code: 'TF-006', name: 'Using Mobile Phone While Driving', groupName: 'Distracted Driving', defaultAmount: 10000, revenueCode: 'RC-TF-006'),
    OffenseCategory(id: 'tf007', code: 'TF-007', name: 'Vehicle Overloading', groupName: 'Vehicle Violations', defaultAmount: 40000, revenueCode: 'RC-TF-007', isAmountEditable: true),
    OffenseCategory(id: 'tf008', code: 'TF-008', name: 'No Seatbelt', groupName: 'Safety Violations', defaultAmount: 5000, revenueCode: 'RC-TF-008'),
    OffenseCategory(id: 'tf009', code: 'TF-009', name: 'Driving Under Influence (DUI)', groupName: 'Dangerous Driving', defaultAmount: 80000, revenueCode: 'RC-TF-009'),
    OffenseCategory(id: 'tf010', code: 'TF-010', name: 'Obstruction of Traffic', groupName: 'Traffic Violations', defaultAmount: 12000, revenueCode: 'RC-TF-010'),
    OffenseCategory(id: 'tf011', code: 'TF-011', name: 'Expired Road Tax', groupName: 'Document Violations', defaultAmount: 18000, revenueCode: 'RC-TF-011'),
    OffenseCategory(id: 'tf012', code: 'TF-012', name: 'Improper Overtaking', groupName: 'Speed Violations', defaultAmount: 22000, revenueCode: 'RC-TF-012'),
  ];

  static const List<ServiceCategory> serviceCategories = [
    ServiceCategory(id: 'sf001', code: 'SF-001', name: 'Police Clearance Certificate', groupName: 'Clearance', defaultAmount: 5000, revenueCode: 'RC-SF-001'),
    ServiceCategory(id: 'sf002', code: 'SF-002', name: 'Armed Guard Permit', groupName: 'Permits', defaultAmount: 20000, revenueCode: 'RC-SF-002', deadlineDays: 14),
    ServiceCategory(id: 'sf003', code: 'SF-003', name: 'Firearms Possession Permit', groupName: 'Permits', defaultAmount: 30000, revenueCode: 'RC-SF-003', deadlineDays: 14),
    ServiceCategory(id: 'sf004', code: 'SF-004', name: 'Event Security Request', groupName: 'Security Services', defaultAmount: 15000, revenueCode: 'RC-SF-004', isAmountEditable: true),
    ServiceCategory(id: 'sf005', code: 'SF-005', name: 'Lost Property Report', groupName: 'Reports', defaultAmount: 2000, revenueCode: 'RC-SF-005'),
    ServiceCategory(id: 'sf006', code: 'SF-006', name: 'Accident Report Copy', groupName: 'Reports', defaultAmount: 3000, revenueCode: 'RC-SF-006'),
  ];

  static List<TransactionEntity> get transactions => [
        TransactionEntity(
          id: 'txn001', type: TransactionType.trafficOffense, status: TransactionStatus.paid,
          prn: 'MPPRS-2026-001234', categoryName: 'Speeding', categoryCode: 'TF-001', amount: 20000,
          issuedAt: DateTime.now().subtract(const Duration(days: 5)),
          deadline: DateTime.now().subtract(const Duration(days: 5)).add(const Duration(days: 21)),
          paidAt: DateTime.now().subtract(const Duration(days: 3)),
          offenderName: 'James Banda', vehicleReg: 'MWK 1234', maltisRef: 'MALTIS-2026-0091',
          officerName: 'Ofc. S. Phiri', officerId: 'OFF-001', stationName: 'Lilongwe Central', deviceId: 'DEV-LIL-001',
        ),
        TransactionEntity(
          id: 'txn002', type: TransactionType.trafficOffense, status: TransactionStatus.issuedUnpaid,
          prn: 'MPPRS-2026-001235', categoryName: 'Reckless Driving', categoryCode: 'TF-002', amount: 50000,
          issuedAt: DateTime.now().subtract(const Duration(days: 18)),
          deadline: DateTime.now().subtract(const Duration(days: 18)).add(const Duration(days: 21)),
          offenderName: 'Mary Chirwa', vehicleReg: 'MWK 5678',
          officerName: 'Ofc. S. Phiri', officerId: 'OFF-001', stationName: 'Lilongwe Central', deviceId: 'DEV-LIL-001',
        ),
        TransactionEntity(
          id: 'txn003', type: TransactionType.trafficOffense, status: TransactionStatus.overdue,
          prn: 'MPPRS-2026-001210', categoryName: 'No Insurance Certificate', categoryCode: 'TF-004', amount: 30000,
          issuedAt: DateTime.now().subtract(const Duration(days: 30)),
          deadline: DateTime.now().subtract(const Duration(days: 30)).add(const Duration(days: 21)),
          offenderName: 'Peter Mbewe', vehicleReg: 'BT 3344',
          officerName: 'Ofc. S. Phiri', officerId: 'OFF-001', stationName: 'Lilongwe Central', deviceId: 'DEV-LIL-001',
        ),
        TransactionEntity(
          id: 'txn004', type: TransactionType.serviceFee, status: TransactionStatus.paid,
          prn: 'MPPRS-2026-001180', categoryName: 'Police Clearance Certificate', categoryCode: 'SF-001', amount: 5000,
          issuedAt: DateTime.now().subtract(const Duration(days: 10)),
          deadline: DateTime.now().subtract(const Duration(days: 10)).add(const Duration(days: 7)),
          paidAt: DateTime.now().subtract(const Duration(days: 8)),
          offenderName: 'Grace Kaunda',
          officerName: 'Ofc. S. Phiri', officerId: 'OFF-001', stationName: 'Lilongwe Central', deviceId: 'DEV-LIL-001',
        ),
        TransactionEntity(
          id: 'txn005', type: TransactionType.trafficOffense, status: TransactionStatus.voided,
          prn: 'MPPRS-2026-001100', categoryName: 'Speeding', categoryCode: 'TF-001', amount: 20000,
          issuedAt: DateTime.now().subtract(const Duration(days: 15)),
          deadline: DateTime.now().subtract(const Duration(days: 15)).add(const Duration(days: 21)),
          offenderName: 'David Nkosi', vehicleReg: 'ZB 9901',
          officerName: 'Ofc. S. Phiri', officerId: 'OFF-001', stationName: 'Lilongwe Central', deviceId: 'DEV-LIL-001',
          voidReason: 'Issued in error - wrong vehicle registration', voidedBy: 'Sgt. A. Mvula',
          voidedAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
      ];
}

