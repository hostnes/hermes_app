import 'package:bloc/bloc.dart';
import '../../services/api.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/validate.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>((LoginEvent event, Emitter<AuthState> emit) async {
      emit(AuthLoading());
      try {
        final res = await ConnectServer.auth(event.email, event.password);
        if (res.length == 1) {
          emit(AuthSuccess(user: res[0]));
        } else {
          emit(AuthFailure(error: 'Ошибка авторизации'));
        }
      } catch (e) {
        emit(AuthFailure(error: 'Ошибка авторизации'));
      }
    });
    on<RegisterEvent>((RegisterEvent event, Emitter<AuthState> emit) async {
      emit(AuthLoading());
      bool isValid = false;
      try {
        if (!validateEmail(event.email)) {
          emit(AuthFailure(error: 'Некорректный email'));
        } else {
          if (!validatePhoneNumber(event.phoneNumber)) {
            emit(AuthFailure(error: 'Некорректный номер телефона'));
          } else {
            if (event.password != event.confirmPassword) {
              emit(AuthFailure(error: 'Пароли не совпадают'));
            } else {
              if (event.password.length < 8) {
                emit(AuthFailure(error: 'Длинна пароля должна быть больше 8'));
              } else {
                isValid = true;
              }
            }
          }
        }
        if (isValid == true) {
          final res = await ConnectServer.register(
            email: event.email,
            phone: event.phoneNumber,
            pass: event.password,
          );
          emit(AuthSuccess(user: res));
        }
      } catch (e) {
        emit(AuthFailure(error: 'Пользователь с таким Email или номером телефона уже существует'));
      }
    });
  }
}
