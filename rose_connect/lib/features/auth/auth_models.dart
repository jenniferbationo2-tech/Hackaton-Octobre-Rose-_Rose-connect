class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.identifier,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        identifier: json['identifier'] as String,
      );

  final String id;
  final String firstName;

  /// Adresse e-mail ou numéro de téléphone (normalisé).
  final String identifier;

  String get initial => firstName.isEmpty
      ? '?'
      : String.fromCharCode(firstName.runes.first).toUpperCase();

  Map<String, dynamic> toJson() =>
      {'id': id, 'firstName': firstName, 'identifier': identifier};
}

class Session {
  const Session({required this.token, required this.user});

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        token: json['token'] as String,
        user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
      );

  final String token;
  final AppUser user;

  Map<String, dynamic> toJson() => {'token': token, 'user': user.toJson()};
}

enum AuthStatus {
  /// Premier lancement : l'écran de bienvenue n'a pas encore été passé.
  onboarding,

  /// Utilisation sans compte.
  guest,
  signedIn,
}

class AuthState {
  const AuthState(this.status, {this.session});

  const AuthState.onboarding() : this(AuthStatus.onboarding);
  const AuthState.guest() : this(AuthStatus.guest);
  AuthState.signedIn(Session session)
      : this(AuthStatus.signedIn, session: session);

  final AuthStatus status;
  final Session? session;

  AppUser? get user => session?.user;
}
