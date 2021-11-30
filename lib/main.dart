import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vncitizens/route_generator.dart';
import 'package:vncitizens/src/blocs/authentication/authentication_bloc.dart';
import 'package:vncitizens/src/blocs/configuration/configuration_bloc.dart';
import 'package:vncitizens/src/repository/authentication_repository.dart';
import 'package:vncitizens/src/repository/configuration_repository.dart';
import 'package:vncitizens/src/repository/model/model.dart';

void main() {
  runApp(App(configurationRepository: ConfigurationRepository()));
}

class App extends StatelessWidget {
  final ConfigurationRepository configurationRepository;

  const App({required this.configurationRepository, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: configurationRepository,
      child: BlocProvider(
        create: (_) =>
            ConfigurationBloc(configurationRepository: configurationRepository)
              ..add(GetConfigurationRequested()),
        child: BlocBuilder<ConfigurationBloc, ConfigurationState>(
          builder: (context, state) {
            switch (state.status) {
              case configStatus.success:
                return RepositoryProvider(
                  create: (_) => AuthenticationRepository(
                    ssoURL: state.config["ssoURL"],
                    clientId: state.config["clientId"],
                    username: state.config["username"],
                    password: state.config["password"],
                  ),
                  child: BlocProvider(
                    create: (context) => AuthenticationBloc(
                      authenticationRepository:
                          context.read<AuthenticationRepository>(),
                    ),
                    child: const AppView(),
                  ),
                );
              case configStatus.failure:
                return const MaterialApp(
                  home: Text("Error get configuration!"),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({Key? key}) : super(key: key);

  @override
  _AppViewState createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  // final _navigatorKey = GlobalKey<NavigatorState>();

  // NavigatorState get _navigator => _navigatorKey.currentState!;

  void _getPublicAccessToken(authenticationRepository) {
    authenticationRepository.logInWithCredential();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // navigatorKey: _navigatorKey,
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state.status.status == AuthStatus.unknown) {
              _getPublicAccessToken(
                  RepositoryProvider.of<AuthenticationRepository>(context));
            }
          },
          child: child,
        );
      },
    );
  }
}
