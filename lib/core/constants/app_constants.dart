class AppConstants {
  AppConstants._();

  static const String appName = 'MPPRS';
  static const String appFullName = 'Malawi Police Payment & Revenue System';
  static const String appVersion = '1.0.0';

  // Payment deadlines (days)
  static const int trafficFineDeadlineDays = 21;
  static const int serviceFeeDeadlineDays = 7;

  // PRN prefix
  static const String prnPrefix = 'MPPRS';

  // Date format
  static const String dateDisplayFormat = 'dd MMM yyyy';
  static const String dateTimeDisplayFormat = 'dd MMM yyyy, HH:mm';

  // Spacing grid (8pt)
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Border radius
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  // Min touch target
  static const double minTouchTarget = 44.0;

  // Card padding
  static const double cardPadding = 16.0;

  // Page horizontal padding
  static const double pagePadding = 16.0;

  // Mock stations
  static const List<String> stations = [
    'Lilongwe Central Police Station',
    'Blantyre Police Station',
    'Mzuzu Police Station',
    'Zomba Police Station',
    'Kasungu Police Station',
    'Mangochi Police Station',
  ];

  // Payment channels
  static const List<String> paymentChannels = [
    'National Bank of Malawi (NBM)',
    'Standard Bank',
    'FDH Bank',
    'NBS Bank',
    'Airtel Money',
    'TNM Mpamba',
  ];
}

