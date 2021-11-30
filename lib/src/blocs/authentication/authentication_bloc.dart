import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vncitizens/src/repository/authentication_repository.dart';
import 'package:vncitizens/src/repository/model/model.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (authenticationStatus) => add(
        AuthenticationStatusChanged(authenticationStatus),
      ),
    );
  }

  void _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    switch (event.status.status) {
      case AuthStatus.unauthenticated:
        return emit(AuthenticationState.unauthenticated(
            accessToken: event.status.accessToken!));
      case AuthStatus.authenticated:
        return emit(AuthenticationState.authenticated(
            accessToken: event.status.accessToken!));
      default:
        return emit(const AuthenticationState.unknown());
    }
  }

  void _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logOut();
  }

  @override
  Future<void> close() {
    _authenticationRepository.dispose();
    _authenticationStatusSubscription.cancel();
    return super.close();
  }
}
