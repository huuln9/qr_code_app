import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utils/src/models/authentication_status.dart';

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();
  String ssoURL;
  String clientId;
  String username;
  String password;

  AuthenticationRepository({
    required this.ssoURL,
    required this.clientId,
    required this.username,
    required this.password,
  });

  Stream<AuthenticationStatus> get status async* {
    yield const AuthenticationStatus(AuthStatus.unknown);
    yield* _controller.stream;
  }

  Future<void> logInWithCredential() async {
    final String accessToken = await _getAccessTokenWithPassword(
        username: username, password: password);

    _controller.add(
      AuthenticationStatus(AuthStatus.unauthenticated,
          accessToken: accessToken),
    );
  }

  Future<void> logInWithPassword({
    required String username,
    required String password,
  }) async {
    final String accessToken = await _getAccessTokenWithPassword(
        username: username, password: password);

    _controller.add(
      AuthenticationStatus(AuthStatus.authenticated, accessToken: accessToken),
    );
  }

  Future<String> _getAccessTokenWithPassword({
    required String username,
    required String password,
  }) async {
    Map<String, dynamic> requestBody = {
      "grant_type": "password",
      "client_id": clientId,
      "username": username,
      "password": password,
    };
    String requestBodyEncoded =
        requestBody.keys.map((key) => "$key=${requestBody[key]}").join("&");

    final response = await http.post(
      Uri.parse('$ssoURL/auth/realms/digo/protocol/openid-connect/token'),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: requestBodyEncoded,
    );

    if (response.statusCode == 200) {
      final accessToken = json.decode(response.body)['access_token'] as String;
      return accessToken;
    } else {
      throw Exception(response.body);
    }
  }

  void logOut() =>
      _controller.add(const AuthenticationStatus(AuthStatus.unauthenticated));

  void dispose() => _controller.close();
}
