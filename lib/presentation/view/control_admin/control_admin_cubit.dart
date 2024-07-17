import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

part 'control_admin_state.dart';

class ControlAdminCubit extends Cubit<ControlAdminState> {
  ControlAdminCubit() : super(ControlAdminInitial());

  void getLoginPage(){
    emit(ControlAdminLogin());
  }
  void getRegisterPage(){
    emit(ControlAdminInitial());
  }

}
