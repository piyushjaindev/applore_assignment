import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/user_model.dart';
import '../blocs/auth_cubit.dart';
import 'login_screen.dart';
import 'user_products_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
        final status = state.user.userStatus;
        if (status == UserStatus.unauthenticated)
          return LoginScreen();
        else if (status == UserStatus.authenticated)
          return UserProductsScreen();
        else
          return SplashScreen();
      }),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
