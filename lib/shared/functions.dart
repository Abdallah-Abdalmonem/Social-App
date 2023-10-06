class MyFunctions {
  static bool isArabic(String? textMessage) {
    if (textMessage!.isEmpty) {
      return false;
    }
    if (textMessage[0].codeUnits[0] >= 0x0600 &&
        textMessage[0].codeUnits[0] <= 0x06E0) {
      return true;
    }
    return false;
  }
}
