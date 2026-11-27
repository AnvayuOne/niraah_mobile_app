import '../features/care/domain/care.dart';
import '../features/community/domain/community.dart';
import '../features/dietitian/dietitian_repository.dart';
import '../features/doctor/domain/doctor_work.dart';
import '../features/home/data/unavailable_home_repository.dart';
import '../features/instructor/instructor_repository.dart';
import '../features/labs/domain/labs.dart';
import '../features/me/domain/me.dart';
import '../features/messaging/messaging.dart';
import '../features/practice/domain/practice.dart';
import '../features/provider_auth/application_repository.dart';
import '../features/provider_work/domain/provider_work.dart';

/// Used by the sample build: these areas exist only on the real API, so every call fails plainly and the
/// screens show their "Try again" state instead of invented data (constitution §2 rule 6).
mixin _NotConnected {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future<Never>.error(const HomeNotConnected());
}

class UnavailablePracticeRepository with _NotConnected implements PracticeRepository {}

class UnavailableMeRepository with _NotConnected implements MeRepository {}

class UnavailableCareRepository with _NotConnected implements CareRepository {}

class UnavailableLabsRepository with _NotConnected implements LabsRepository {}

class UnavailableCommunityRepository with _NotConnected implements CommunityRepository {}

class UnavailableMessagingRepository with _NotConnected implements MessagingRepository {}

class UnavailableProviderWorkRepository with _NotConnected implements ProviderWorkRepository {}

class UnavailableDoctorWorkRepository with _NotConnected implements DoctorWorkRepository {}

class UnavailableDietitianRepository with _NotConnected implements DietitianRepository {}

class UnavailableInstructorRepository with _NotConnected implements InstructorRepository {}

class UnavailableProviderApplicationRepository with _NotConnected implements ProviderApplicationRepository {}
