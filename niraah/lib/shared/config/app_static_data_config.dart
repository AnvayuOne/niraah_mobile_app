class AppStaticDataConfig {
  const AppStaticDataConfig._();

  static const int healthScore = 40;
  static const String riskBand = 'MODERATE';
  static const String bmi = '20.7 (Normal)';

  static const List<String> attentionNeeded = <String>[
    'irregular cycles',
    'spotting',
    'hirsutism',
    'mood disturbances',
  ];

  static const List<String> insights = <String>[
    'Irregular or absent cycles are a primary indicator of ovulatory dysfunction, common in PCOS.',
    'You reported symptoms of androgen excess (acne, hair growth, or loss), which is a key diagnostic feature of PCOS.',
  ];

  static const List<StaticSymptomEntry> recentSymptoms = <StaticSymptomEntry>[
    StaticSymptomEntry(title: 'Fever', date: '20/02/2026', severity: 'Severe'),
    StaticSymptomEntry(title: 'Back pain', date: '20/02/2026', severity: 'Mild'),
    StaticSymptomEntry(title: 'Headache', date: '20/02/2026', severity: 'Severe'),
    StaticSymptomEntry(title: 'Stomach pain', date: '20/02/2026', severity: 'Moderate'),
    StaticSymptomEntry(title: 'Cramps', date: '20/02/2026', severity: 'Mild'),
  ];

  static const List<StaticAppointment> appointments = <StaticAppointment>[
    StaticAppointment(date: 'OCT 16', title: 'Follow up', time: '14:00', status: 'Requested'),
    StaticAppointment(date: 'JAN 12', title: 'New Symptoms', time: '13:54', status: 'Assigned'),
    StaticAppointment(date: 'JAN 13', title: 'Checkup', time: '15:16', status: 'Assigned'),
    StaticAppointment(date: 'JAN 13', title: 'Consultation', time: '18:23', status: 'Assigned'),
  ];

  static const List<StaticProgram> programs = <StaticProgram>[
    StaticProgram(
      title: 'PCOS Lifestyle',
      subtitle: 'Diet, exercise, consults, community & rewards.',
      actionLabel: 'View',
    ),
    StaticProgram(
      title: 'Pregnancy Care',
      subtitle: 'Trimester-wise guidance and safe activity.',
      actionLabel: 'Explore',
    ),
  ];
}

class StaticSymptomEntry {
  const StaticSymptomEntry({
    required this.title,
    required this.date,
    required this.severity,
  });

  final String title;
  final String date;
  final String severity;
}

class StaticAppointment {
  const StaticAppointment({
    required this.date,
    required this.title,
    required this.time,
    required this.status,
  });

  final String date;
  final String title;
  final String time;
  final String status;
}

class StaticProgram {
  const StaticProgram({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
}
