part of 'control_admin_cubit.dart';

@immutable
abstract class ControlAdminState {}


class ControlAdminInitial extends ControlAdminState {
  bool isRegister = true;
}

class ControlAdminLogin extends ControlAdminState {
  bool isRegister = false;
}
