class Currencies {
  String symbol;
  String name;
  String code;
  int decimalDigits;

  Currencies({this.symbol, this.name, this.code, this.decimalDigits});

  factory Currencies.fromJson(Map<String, dynamic> parsedJson) {
    return Currencies(
        symbol: parsedJson['symbol'].toString(),
        name: parsedJson['name'].toString(),
        code: parsedJson['code'].toString(),
        decimalDigits: parsedJson['decimal_digits'],
    );
  }

  @override
  String toString() {
    return '{symbol: ${this.symbol}, name: ${this.name}, code: ${this.code}, decimalDigits: ${this.decimalDigits}}';
  }
}
