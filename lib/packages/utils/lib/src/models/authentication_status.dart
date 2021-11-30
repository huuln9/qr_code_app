import 'package:equatable/equatable.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthenticationStatus extends Equatable {
  final AuthStatus status;
  final String? accessToken;

  const AuthenticationStatus(this.status, {this.accessToken});

  @override
  List<Object?> get props => [status, accessToken];
}
