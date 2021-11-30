import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:vncitizens/src/login/bloc/login_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text("Authentication failure!")),
            );
        }
      },
      child: Center(
        child: Container(
          height: 300,
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const Text(
              //   "LOGIN",
              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              // ),
              _UsernameInput(),
              const Padding(padding: EdgeInsets.all(10)),
              _PasswordInput(),
              const Padding(padding: EdgeInsets.all(15)),
              _LoginButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsernameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.username != curr.username,
      builder: (context, state) {
        return TextField(
          onChanged: (username) =>
              context.read<LoginBloc>().add(LoginUsernameChanged(username)),
          decoration: InputDecoration(
            labelText: 'Username',
            errorText: state.username.invalid ? 'Invalid username!' : null,
          ),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) =>
          (prev.password != curr.password) ||
          (prev.showPassword != curr.showPassword),
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: TextField(
                obscureText: !state.showPassword,
                // enableSuggestions: false,
                // autocorrect: false,
                onChanged: (password) => {
                  context.read<LoginBloc>().add(LoginPasswordChanged(password)),
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText:
                      state.password.invalid ? 'Invalid password!' : null,
                  suffixIcon: IconButton(
                    icon: Icon(state.showPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        context.read<LoginBloc>().add(ToggleShowPassword()),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (prev, curr) => prev.status != curr.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: state.status.isValidated
                    ? () {
                        context.read<LoginBloc>().add(const LoginSubmitted());
                      }
                    : null,
                child: const Text("Login"),
              );
      },
    );
  }
}
