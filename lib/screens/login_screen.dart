import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  String? _email, _password;

  final _formKey = GlobalKey<FormState>();

  void _login(context) {
    _formKey.currentState?.save();
    if (_formKey.currentState?.validate() ?? false) {
      BlocProvider.of<LoginCubit>(context).login(_email!, _password!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //email field
                _buildEmailField(),
                SizedBox(height: 20),
                //password field
                _buildPasswordField(),
                SizedBox(height: 20),
                //login button with state updates
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocConsumer<LoginCubit, LoginState>(listener: (context, state) {
      if (state == LoginState.failure)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Somethng went wrong!')));
    }, builder: (context, state) {
      if (state == LoginState.loading)
        return ElevatedButton(
          onPressed: null,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      else
        return ElevatedButton(
          onPressed: () {
            _login(context);
          },
          child: Text('Login / Register'),
        );
    });
  }

  TextFormField _buildPasswordField() {
    return TextFormField(
      textInputAction: TextInputAction.done,
      obscureText: true,
      onSaved: (value) {
        _password = value?.trim();
      },
      validator: (value) {
        if (value == null)
          return 'Enter password';
        else if (value.length < 6)
          return 'Password too short';
        else
          return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
      ),
    );
  }

  TextFormField _buildEmailField() {
    return TextFormField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        _email = value?.trim();
      },
      validator: (value) {
        if (value == null)
          return 'Enter an email';
        else if (value.length < 5 || !value.contains('@'))
          return 'Invalid email';
        else
          return null;
      },
      decoration: InputDecoration(labelText: 'Email', hintText: 'abc@xyz'),
    );
  }
}
