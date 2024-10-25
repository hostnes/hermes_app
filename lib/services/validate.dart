  bool validateEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegExp.hasMatch(email);
  }

  bool validatePhoneNumber(String phone) {
    final RegExp phoneRegExp = RegExp(r'^\+375\d{9}$');
    return phoneRegExp.hasMatch(phone);
  }