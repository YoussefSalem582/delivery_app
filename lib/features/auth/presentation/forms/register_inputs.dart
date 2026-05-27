import 'package:formz/formz.dart';

enum NameValidationError { empty, tooShort }

class NameInput extends FormzInput<String, NameValidationError> {
  const NameInput.pure() : super.pure('');

  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  NameValidationError? validator(String value) {
    if (value.trim().isEmpty) return NameValidationError.empty;
    if (value.trim().length < 2) return NameValidationError.tooShort;
    return null;
  }
}

enum ConfirmPasswordValidationError { empty, mismatch }

class ConfirmPasswordInput extends FormzInput<String, ConfirmPasswordValidationError> {
  const ConfirmPasswordInput.pure({this.password = ''}) : super.pure('');

  const ConfirmPasswordInput.dirty(
    super.value, {
    required this.password,
  }) : super.dirty();

  final String password;

  @override
  ConfirmPasswordValidationError? validator(String value) {
    if (value.isEmpty) return ConfirmPasswordValidationError.empty;
    if (value != password) return ConfirmPasswordValidationError.mismatch;
    return null;
  }
}
