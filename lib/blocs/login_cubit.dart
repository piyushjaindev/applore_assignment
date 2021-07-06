import 'package:bloc/bloc.dart';

import '../firebase/authentication.dart';

enum LoginState { initial, loading, success, failure }

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._auth) : super(LoginState.initial);

  final FirebaseAuthentication _auth;

  void login(String email, String password) {
    emit(LoginState.loading);
    _auth.login(email, password).then((value) {
      emit(LoginState.success);
    }).catchError((e) {
      emit(LoginState.failure);
    });
  }
}
