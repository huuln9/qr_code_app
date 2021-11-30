import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vncitizens/src/blocs/authentication/authentication_bloc.dart';
import 'package:vncitizens/src/blocs/configuration/configuration_bloc.dart';
import 'package:vncitizens/src/repository/place_repository.dart';
import 'package:vncitizens/src/utilities/bloc/utilities_bloc.dart';
import 'package:vncitizens/src/utilities/view/utilities_list_page.dart';

class UtilitiesPage extends StatelessWidget {
  final String utilitiesName;
  final String utilitiesTagId;

  const UtilitiesPage({
    Key? key,
    required this.utilitiesName,
    required this.utilitiesTagId,
  }) : super(key: key);

  static Route route(String utilitiesName, String utilitiesTagId) {
    return MaterialPageRoute(
      builder: (_) => UtilitiesPage(
        utilitiesName: utilitiesName,
        utilitiesTagId: utilitiesTagId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var apiGatewayURL =
        context.read<ConfigurationBloc>().state.config['apiGatewayURL'];

    return Scaffold(
      body: BlocProvider(
        create: (context) => UtilitiesBloc(
          utilitiesRepository: PlaceRepository(
            apiGatewayURL: apiGatewayURL,
            utilitiesTagId: utilitiesTagId,
          ),
          accessToken: context.read<AuthenticationBloc>().state.accessToken,
        )..add(GetListUtilitiesRequested()),
        child: UtilitiesListPage(utilitiesName: utilitiesName),
      ),
    );
  }
}
