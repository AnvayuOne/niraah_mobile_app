import '../../core/network/niraah_api.dart';

/// The consult room on `/api/v1` (spec 014 §5; plan 014 "Rooms"), the same calls as the website's
/// `apps/web/src/api/room-repository.ts`. Media never touches the API: the server hands out a short-lived
/// video token for one participant inside the join window, and the call itself runs on the video service.

/// Who is in the room: the doctor or dietitian, or the member.
enum RoomSide { clinician, member }

/// `POST /appointments/{id}/room-token` (core `Rooms.token`).
class RoomToken {
  const RoomToken({
    required this.appId,
    required this.channel,
    required this.uid,
    required this.token,
    required this.expiresAt,
    this.closesAt,
    this.recording = false,
  });

  final String appId;
  final String channel;
  final int uid;
  final String token;
  final DateTime expiresAt;

  /// Scheduled end plus the grace time (or earlier if the clinician's next consult begins).
  final DateTime? closesAt;
  final bool recording;

  static RoomToken fromJson(Map<String, dynamic> j) => RoomToken(
        appId: '${j['appId']}',
        channel: '${j['channel']}',
        uid: (j['uid'] as num).toInt(),
        token: '${j['token']}',
        expiresAt: DateTime.tryParse('${j['expiresAt']}')?.toLocal() ?? DateTime.now().add(const Duration(hours: 1)),
        closesAt: j['closesAt'] == null ? null : DateTime.tryParse('${j['closesAt']}')?.toLocal(),
        recording: j['recording'] == true,
      );
}

sealed class TokenResult {
  const TokenResult();
}

class TokenReady extends TokenResult {
  const TokenReady(this.token);
  final RoomToken token;
}

/// Too early: the room opens at [opensAt].
class RoomNotOpen extends TokenResult {
  const RoomNotOpen(this.opensAt, this.message);
  final DateTime? opensAt;
  final String message;
}

/// The room has closed, or the consult is not one she can join (cancelled, someone else's).
class RoomClosed extends TokenResult {
  const RoomClosed(this.message);
  final String message;
}

/// No signal, the server is unavailable, or video is not set up (sample build).
class RoomUnavailable extends TokenResult {
  const RoomUnavailable(this.message);
  final String message;
}

/// What the room shows about the consult: who it is with and when.
class RoomInfo {
  const RoomInfo({required this.id, required this.startsAt, required this.endsAt, this.clinicianName, this.memberName, this.recording = false});

  final String id;
  final DateTime startsAt;
  final DateTime endsAt;
  final String? clinicianName;
  final String? memberName;
  final bool recording;

  /// The person on the other side of the call.
  String? otherName(RoomSide side) => side == RoomSide.member ? clinicianName : memberName;
}

abstract class RoomRepository {
  Future<RoomInfo?> info(String id);

  /// Also the renewal call while the room is open.
  Future<TokenResult> token(String id);

  /// The clinician ends the consult for both; completion follows the room record.
  Future<bool> end(String id);
}

class ApiRoomRepository implements RoomRepository {
  ApiRoomRepository(this._api);

  final NiraahApi _api;

  static String _path(String id, [String rest = '']) => '/appointments/${Uri.encodeComponent(id)}$rest';

  @override
  Future<RoomInfo?> info(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.get(_path(id));
    if (r is! ApiOk<Map<String, dynamic>>) return null;
    final Map<String, dynamic> a = r.data;
    final Map<dynamic, dynamic>? clinician = a['clinician'] as Map?;
    final Map<dynamic, dynamic>? member = a['member'] as Map?;
    return RoomInfo(
      id: id,
      startsAt: DateTime.tryParse('${a['startsAt']}')?.toLocal() ?? DateTime.now(),
      endsAt: DateTime.tryParse('${a['endsAt']}')?.toLocal() ?? DateTime.now().add(const Duration(minutes: 20)),
      clinicianName: clinician?['name'] as String?,
      memberName: (member?['name'] ?? a['memberName']) as String?,
      recording: a['recordMode'] == 'recording',
    );
  }

  @override
  Future<TokenResult> token(String id) async {
    final ApiResult<Map<String, dynamic>> r = await _api.post(_path(id, '/room-token'));
    switch (r) {
      case ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data):
        return TokenReady(RoomToken.fromJson(data));
      case ApiFail<Map<String, dynamic>>(:final ApiError error, :final int status):
        if (status == 409) {
          final Object? opensAt = error.details?['opensAt'];
          if (opensAt is String) return RoomNotOpen(DateTime.tryParse(opensAt)?.toLocal(), error.message);
          return RoomClosed(error.message);
        }
        if (status == 404 || status == 403) return RoomClosed(error.message);
        return RoomUnavailable(error.message);
    }
  }

  @override
  Future<bool> end(String id) async => (await _api.post(_path(id, '/end'))) is ApiOk;
}

/// Sample build: the room shows up to joining, as on the website's sample mode.
class SampleRoomRepository implements RoomRepository {
  @override
  Future<RoomInfo?> info(String id) async => RoomInfo(
        id: id,
        startsAt: DateTime.now(),
        endsAt: DateTime.now().add(const Duration(minutes: 20)),
        clinicianName: 'Dr. Ananya Rao',
        memberName: 'Asha',
      );

  @override
  Future<TokenResult> token(String id) async => const RoomUnavailable('Video calls need the live service. Sample mode shows the room up to joining.');

  @override
  Future<bool> end(String id) async => true;
}
