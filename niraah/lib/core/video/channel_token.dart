import '../network/niraah_api.dart';

/// A token for one video channel, as the server returns it for a class room (core `Classes.token`, `cameraToken`):
/// `{appId, channel, uid, token, role, expiresAt}`. The app id is the vendor's public id, taken from here.
class ChannelToken {
  const ChannelToken({required this.appId, required this.channel, required this.uid, required this.token, this.expiresAt});

  final String appId;
  final String channel;
  final int uid;
  final String token;
  final DateTime? expiresAt;

  static ChannelToken parse(Map<String, dynamic> j, {String? appId}) => ChannelToken(
        appId: '${j['appId'] ?? appId ?? ''}',
        channel: '${j['channel']}',
        uid: (j['uid'] as num).toInt(),
        token: '${j['token']}',
        expiresAt: j['expiresAt'] is String ? DateTime.tryParse(j['expiresAt'] as String)?.toLocal() : null,
      );
}

/// Asking for a class room token: ready, or refused with the server's words. Anyone but the instructor and members with
/// a confirmed place gets 404; outside the join window the answer is 409 "not open" (spec 014 §8 "The class room" 1).
sealed class ClassRoomAccess {
  const ClassRoomAccess();

  static ClassRoomAccess from(ApiResult<Map<String, dynamic>> r) => switch (r) {
        ApiOk<Map<String, dynamic>>(:final Map<String, dynamic> data) => ClassRoomReady(ChannelToken.parse(data)),
        ApiFail<Map<String, dynamic>>(:final ApiError error, :final int status) => ClassRoomShut(error.message, notOpen: status == 409),
      };
}

class ClassRoomReady extends ClassRoomAccess {
  const ClassRoomReady(this.token);
  final ChannelToken token;
}

class ClassRoomShut extends ClassRoomAccess {
  const ClassRoomShut(this.message, {this.notOpen = false});
  final String message;
  final bool notOpen;
}
