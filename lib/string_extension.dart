extension ExtendedString on String {
  bool get checkEmail {
    final RegExp _regexEmail =
        RegExp(r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-\/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+\.{0,1}[a-zA-Z]+""");
    return _regexEmail.hasMatch(this);
  }

  bool get checkPhoneNumber {
    const String _phoneNumberlPattern = r'(09|03|07|08|05)+([0-9]{8})';
    final RegExp _regexPhoneNumber = RegExp(_phoneNumberlPattern);
    return _regexPhoneNumber.hasMatch(this) && length == 10;
  }

  String get getLetterFirstName {
    if (length == 1) return toUpperCase();
    String nameRaw = trim();
    var listName = nameRaw.split('');
    return listName[0].toUpperCase();
  }
}
