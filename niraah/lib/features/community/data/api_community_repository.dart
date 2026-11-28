import '../../../core/network/niraah_api.dart';
import '../../../shared/area/area_access.dart';
import '../domain/community.dart';

/// Community on `/api/v1` (spec 010 §12; screening and moderation are spec 006 on the server).
class ApiCommunityRepository implements CommunityRepository {
  ApiCommunityRepository(this._api);

  final NiraahApi _api;

  static String _e(String id) => Uri.encodeComponent(id);

  @override
  Future<Circles> circles() async {
    final Map<String, dynamic> r = (await _api.get('/me/community')).orArea();
    final Map<String, dynamic>? rules = r['rules'] as Map<String, dynamic>?;
    return Circles(
      circles: <Circle>[
        for (final dynamic c in r['circles'] as List<dynamic>)
          Circle(id: (c as Map<String, dynamic>)['id'] as String, name: c['name'] as String, rules: c['rules'] as String?, joined: c['joined'] as bool),
      ],
      rules: rules == null ? null : CommunityRules(version: (rules['version'] as num).toInt(), text: rules['text'] as String, accepted: rules['accepted'] as bool),
      composeReminder: r['composeReminder'] as String,
    );
  }

  @override
  Future<void> acceptRules(int version) async => (await _api.post('/me/community/rules/accept', <String, dynamic>{'version': version})).orArea();

  @override
  Future<bool> setJoined(String circleId, bool joined) async =>
      (await _api.put('/me/community/circles/${_e(circleId)}/membership', <String, dynamic>{'joined': joined})).orArea()['joined'] as bool;

  @override
  Future<List<Post>> feed(String circleId) async =>
      <Post>[for (final dynamic p in (await _api.get('/me/community/circles/${_e(circleId)}/posts')).orArea()['items'] as List<dynamic>) _post(p as Map<String, dynamic>)];

  @override
  Future<Posted> post(String circleId, String body, {required bool anonymous}) async =>
      _posted((await _api.post('/me/community/circles/${_e(circleId)}/posts', <String, dynamic>{'body': body, 'anonymous': anonymous})).orArea());

  @override
  Future<ThreadDocument> thread(String postId) async {
    final Map<String, dynamic> r = (await _api.get('/me/community/posts/${_e(postId)}')).orArea();
    return ThreadDocument(
      post: _post(r['post'] as Map<String, dynamic>),
      comments: <Comment>[
        for (final dynamic c in r['comments'] as List<dynamic>)
          Comment(
            id: (c as Map<String, dynamic>)['id'] as String,
            body: c['body'] as String,
            author: _author(c['author'] as Map<String, dynamic>),
            beingReviewed: c['beingReviewed'] as bool,
            createdAt: c['createdAt'] as String,
          ),
      ],
    );
  }

  @override
  Future<Posted> edit(String postId, String body) async => _posted((await _api.patch('/me/community/posts/${_e(postId)}', <String, dynamic>{'body': body})).orArea());

  @override
  Future<void> deletePost(String postId) async => (await _api.delete('/me/community/posts/${_e(postId)}')).orArea();

  @override
  Future<Posted> comment(String postId, String body) async => _posted((await _api.post('/me/community/posts/${_e(postId)}/comments', <String, dynamic>{'body': body})).orArea());

  @override
  Future<void> deleteComment(String commentId) async => (await _api.delete('/me/community/comments/${_e(commentId)}')).orArea();

  @override
  Future<void> report(String target, String id, String reason) async =>
      (await _api.post('/me/community/reports', <String, dynamic>{'target': target, 'id': id, 'reason': reason})).orArea();

  @override
  Future<void> mute(String target, String id) async => (await _api.put('/me/community/mutes', <String, dynamic>{'target': target, 'id': id, 'muted': true})).orArea();

  static Posted _posted(Map<String, dynamic> r) => Posted(beingReviewed: r['beingReviewed'] as String?, resources: r['resources'] as String?);

  static Author _author(Map<String, dynamic> a) => Author(
        anonymous: a['anonymous'] as bool,
        mine: a['mine'] as bool,
        name: a['name'] as String?,
        expert: a['expert'] as bool,
        title: a['title'] as String?,
      );

  static Post _post(Map<String, dynamic> p) => Post(
        id: p['id'] as String,
        body: p['body'] as String,
        author: _author(p['author'] as Map<String, dynamic>),
        beingReviewed: p['beingReviewed'] as bool,
        edited: p['edited'] as bool,
        comments: (p['comments'] as num).toInt(),
        createdAt: p['createdAt'] as String,
      );
}
