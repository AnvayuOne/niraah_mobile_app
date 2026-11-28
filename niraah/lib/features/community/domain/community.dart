/// Community as the server returns it (spec 010 §12), matching packages/contracts/src/member.ts `Circles`,
/// `Feed`, `Thread`, `Posted`. An anonymous post carries no name or id of its author (AC39).
library;

class Circle {
  const Circle({required this.id, required this.name, required this.rules, required this.joined});

  final String id;
  final String name;
  final String? rules;
  final bool joined;
}

class CommunityRules {
  const CommunityRules({required this.version, required this.text, required this.accepted});

  final int version;
  final String text;
  final bool accepted;
}

class Circles {
  const Circles({required this.circles, required this.rules, required this.composeReminder});

  final List<Circle> circles;
  final CommunityRules? rules;

  /// "Don't share contact details or other people's health information." (spec 010 §12 rule 7).
  final String composeReminder;
}

class Author {
  const Author({required this.anonymous, required this.mine, required this.name, required this.expert, required this.title});

  final bool anonymous;
  final bool mine;
  final String? name;

  /// Doctors and dietitians, marked with name and title (rule 6).
  final bool expert;
  final String? title;
}

class Post {
  const Post({required this.id, required this.body, required this.author, required this.beingReviewed, required this.edited, required this.comments, required this.createdAt});

  final String id;
  final String body;
  final Author author;

  /// Her own post held by screening: shown to her as being reviewed, invisible to others (rule 4).
  final bool beingReviewed;
  final bool edited;
  final int comments;
  final String createdAt;
}

class Comment {
  const Comment({required this.id, required this.body, required this.author, required this.beingReviewed, required this.createdAt});

  final String id;
  final String body;
  final Author author;
  final bool beingReviewed;
  final String createdAt;
}

class ThreadDocument {
  const ThreadDocument({required this.post, required this.comments});

  final Post post;
  final List<Comment> comments;
}

/// After posting: the review note when screening held it, and supportive resources at once on a self-harm signal.
class Posted {
  const Posted({required this.beingReviewed, required this.resources});

  final String? beingReviewed;
  final String? resources;
}

const List<String> reportReasons = <String>['harmful_advice', 'harassment', 'spam', 'personal_information', 'self_harm', 'other'];

abstract class CommunityRepository {
  Future<Circles> circles();

  Future<void> acceptRules(int version);

  Future<bool> setJoined(String circleId, bool joined);

  Future<List<Post>> feed(String circleId);

  Future<Posted> post(String circleId, String body, {required bool anonymous});

  Future<ThreadDocument> thread(String postId);

  Future<Posted> edit(String postId, String body);

  Future<void> deletePost(String postId);

  Future<Posted> comment(String postId, String body);

  Future<void> deleteComment(String commentId);

  /// [target] is `post` or `comment`.
  Future<void> report(String target, String id, String reason);

  Future<void> mute(String target, String id);
}
