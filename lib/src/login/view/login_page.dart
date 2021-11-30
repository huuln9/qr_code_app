import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vncitizens/src/login/bloc/login_bloc.dart';
import 'package:vncitizens/src/login/view/login_form.dart';
import 'package:vncitizens/src/repository/authentication_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocProvider(
          create: (context) => LoginBloc(
            authenticationRepository:
                RepositoryProvider.of<AuthenticationRepository>(context),
          ),
          child: const LoginForm(),
        ),
      ),
    );
  }
}
