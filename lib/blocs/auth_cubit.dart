import 'dart:async';

import 'package:bloc/bloc.dart';

import '../models/user_model.dart';
import '../firebase/authentication.dart';

class AuthState {
  final UserModel user;
  AuthState(this.user);
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth)
      : super(AuthState(UserModel(userStatus: UserStatus.unknown)));

  final FirebaseAuthentication _auth;
  late StreamSubscription _userSubscription;

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  void init() {
    _userSubscription = _auth.user.listen((user) {
      if (user == null)
        emit(AuthState(UserModel(userStatus: UserStatus.unauthenticated)));
      else
        emit(AuthState(
            UserModel(userStatus: UserStatus.authenticated, id: user.uid)));
    });
  }
}
