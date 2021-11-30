part of 'authentication_bloc.dart';

class AuthenticationState extends Equatable {
  final AuthenticationStatus status;
  final String accessToken;

  const AuthenticationState._({
    this.status = const AuthenticationStatus(AuthStatus.unknown),
    this.accessToken = "",
  });

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.unauthenticated({required String accessToken})
      : this._(
          status: const AuthenticationStatus(AuthStatus.unauthenticated),
          accessToken: accessToken,
        );

  const AuthenticationState.authenticated({required String accessToken})
      : this._(
          status: const AuthenticationStatus(AuthStatus.authenticated),
          accessToken: accessToken,
        );

  @override
  List<Object?> get props => [status, accessToken];
}
