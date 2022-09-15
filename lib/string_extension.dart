extension ExtendedString on String {
  bool get checkEmail {
    final RegExp _regexEmail = RegExp(r"""^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$""");
    return _regexEmail.hasMatch(this);
  }

  bool checkPhoneNumber(String phoneNumberPattern) {
    final RegExp _regexPhoneNumber = RegExp(phoneNumberPattern);
    return _regexPhoneNumber.hasMatch(this);
  }

  String get getLetterFirstName {
    if (length == 1) return toUpperCase();
    String nameRaw = trim();
    var listName = nameRaw.split('');
    return listName[0].toUpperCase();
  }
}
