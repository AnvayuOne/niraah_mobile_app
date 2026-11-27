import '../domain/consults.dart';

/// Words for Find a specialist and booking, the same as the website's (spec 010 §9, spec 014). Wellness-only wording.
abstract final class ConsultsCopy {
  static const String findTitle = 'Find a specialist';
  static const String findIntro = 'Book a video consult with a doctor or dietitian who works with Niraah.';
  static const String wellness = 'Niraah supports your wellbeing and does not replace your own doctor. For anything urgent, please seek care near you.';
  static const String all = 'All';
  static const String doctors = 'Doctors';
  static const String dietitians = 'Dietitians';
  static const String none = 'No one has free times for this choice right now. Try another kind of specialist.';
  static const String appointments = 'Your appointments';
  static const String book = 'Book';
  static const String yourCare = 'Your care team';

  static String years(int n) => '$n ${n == 1 ? 'year' : 'years'} experience';
  static String rating(double avg, int n) => '${avg.toStringAsFixed(1)} · $n ${n == 1 ? 'rating' : 'ratings'}';
  static String speaks(List<String> langs) => 'Speaks ${langs.join(', ')}';
  static String fee(int paise) => '${rupees(paise)} incl. GST';
  static const String noFee = 'Not taking bookings';

  static const String back = 'Back';
  static const String about = 'About';
  static const String chooseTime = 'Choose a time';
  static const String timesLocal = 'Times are shown in your time zone.';
  static const String noTimes = 'No times available right now. Please check again later or choose another specialist.';
  static const String noneThisDay = 'No free times on this day.';
  static const String morning = 'Morning';
  static const String afternoon = 'Afternoon';
  static const String evening = 'Evening';
  static String free(int n) => n == 0 ? 'Full' : '$n free';
  static const String includedNote = 'Included in your plan';
  static const String pickATime = 'Pick a time to continue';
  static const String holdTime = 'Hold this time';
  static const String today = 'Today';
  static const String tomorrow = 'Tomorrow';

  static const String confirmTitle = 'Confirm your consult';
  static String heldFor(String left) => 'Held for you · $left';
  static const String expired = 'Your hold has ended, so the time is free again. Please choose a time again.';
  static const String chooseAgain = 'Choose a time again';
  static const String videoConsult = 'Video consult';
  static String minutes(int m) => '$m min';
  static const String shareTitle = 'What may your specialist see?';
  static const String shareIntro = 'Choose what this specialist can see for this consult. You can leave anything out.';
  static const String shareNone = 'If you leave everything out, your specialist will only know what you tell them in the call.';
  static const Map<ShareCategory, String> categories = <ShareCategory, String>{
    ShareCategory.healthData: 'Your health profile',
    ShareCategory.assessment: 'Your health assessment',
    ShareCategory.cycleSymptoms: 'Your cycle and symptoms',
    ShareCategory.meals: 'Your meals',
    ShareCategory.labReports: 'Your lab reports',
    ShareCategory.messages: 'Your messages with your care team',
  };
  static const String reason = 'Reason for the visit (optional)';
  static const String reasonHint = 'A few words. Only this specialist will read it.';
  static const String recordTitle = 'Keep a record of this consult?';
  static const String recordText =
      'With your yes, the call is kept as a private record for 3 years, used only if there is a complaint or dispute. You can say no and still have your consult.';
  static const String confirmIncluded = 'Confirm, using an included consult';
  static String pay(int paise) => 'Pay ${rupees(paise)} and confirm';
  static const String giveBack = 'Give back this time';

  static const String payTitle = 'Finish paying on the website';
  static String payText(int paise) =>
      'Your time is held. Paying in the app is coming soon, so please pay ${rupees(paise)} on niraahwellness.com, signed in with this number. Your consult is confirmed as soon as the payment goes through.';
  static const String openWebsite = 'Open the website';
  static const String later = 'Not now';

  static const String bookedTitle = 'You are booked';
  static String bookedText(String who, String when) => 'Your video consult with $who is on $when. We will remind you before it starts.';
  static const String seeAppointments = 'See your appointments';
  static const String done = 'Done';

  static const String upcoming = 'Upcoming';
  static const String past = 'Past';
  static const String noUpcoming = 'You have no upcoming consults.';
  static const String bookConsult = 'Book a consult';
  static const String cancel = 'Cancel consult';
  static const String cancelTitle = 'Cancel this consult?';
  static const String cancelText = 'If it is close to the start, the fee or included consult may not come back.';
  static const String keep = 'Keep it';
  static const String yesCancel = 'Yes, cancel';
  static const String cancelled = 'Your consult is cancelled.';
  static const String someone = 'your specialist';

  static const Map<AppointmentStatus, String> status = <AppointmentStatus, String>{
    AppointmentStatus.held: 'Waiting for confirmation',
    AppointmentStatus.confirmed: 'Confirmed',
    AppointmentStatus.inProgress: 'In progress',
    AppointmentStatus.completed: 'Completed',
    AppointmentStatus.cancelled: 'Cancelled',
    AppointmentStatus.noShow: 'Missed',
    AppointmentStatus.expired: 'Not confirmed in time',
  };
}
