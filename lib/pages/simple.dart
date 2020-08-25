import 'package:flutter/material.dart';
import 'package:calculator/services/color.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:calculator/services/currencies.dart';
import 'dart:convert';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class CalculateSimple extends StatefulWidget {
  @override
  _CalculateSimpleState createState() => _CalculateSimpleState();
}

class _CalculateSimpleState extends State<CalculateSimple> {
  GlobalKey<FlipCardState> cardKey =
      GlobalKey<FlipCardState>(); //manage flip state
  final _scaffoldKey = GlobalKey<ScaffoldState>(); //to save the context

  double _deviceHeight;

  List<Currencies> currencyList = [];
  final List<DropdownMenuItem<Currencies>> currencyDropdownList = [];

  // for list of all periods usable
  static List<String> _interestRatePeriods = [
    "Daily",
    "Weekly",
    "Monthly",
    "Yearly",
  ];

  static List<String> _compoundRatePeriods = [
    "Daily",
    "Weekly",
    "Monthly",
    "Quaterly",
    "Half Yearly",
    "Yearly",
  ];

  static List<String> _periods = [
    "Month(s)",
    "Year(s)",
  ];

  static List<String> _monthlyCommitment = [
    "Deposit",
    "Withdrawal",
  ];

  // for the principal amount text field
  var initAmountController = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  var interestController = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  var periodController = new TextEditingController();

  //all form selected values
  // ignore: avoid_init_to_null
  Currencies _selectedCurrency = null; // for the selected currency object
  static String _selectedSymbol = ""; // for the selected currency symbol
  double _initialAmount = 0.0;
  bool _initialAmountValidate = false;
  String _selectedInterest = _interestRatePeriods[2];
  double _selectedInterestVal = 0.0;
  bool _interestValidate = false;
  String _selectedPeriod = _periods[0];
  int _selectedPeriodVal = 0;
  bool _periodValidate = false;
  String _selectedCompoundInterval = _compoundRatePeriods[2];
  String _selectedMontlyCommitment = _monthlyCommitment[0];
  double _selectedMontlyCommitmentVal = 0.0;

  String _simpleInterest = "";
  String _compoundInterest = "";

  @override
  void initState() {
    super.initState();
    convertCurrenciesToList();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text("Simple Interest Calculator"),
          elevation: 0.0,
          backgroundColor: Hex.color("303F9F")),
      backgroundColor: Hex.color("FFFFFF"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Hex.color("303F9F"),
        onPressed: () {
          setState(() {
            Navigator.pushReplacementNamed(context, '/compound');
          });
        },
        elevation: 0.0,
        child: Icon(
          Icons.swap_horiz,
          color: Hex.color("FFFFFF"),
        ),
        tooltip: "Switch Calculator",
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
        padding: EdgeInsets.all(10.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            //begining of form
            selectCurrency(),
            initialAmount(),
            interestRate(),
            investmentPeriod(),
            submitReset()
          ],
        ),
      ),
    );
  }

  Container submitReset() {
    return Container(
      margin: EdgeInsets.all(_deviceHeight * 0.03),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton.icon(
                onPressed: () {},
                icon: Icon(
                  Icons.refresh,
                  color: Colors.red,
                ),
                label: Text("Reset")),
            SizedBox(
              width: 10,
            ),
            RaisedButton.icon(
                clipBehavior: Clip.hardEdge,
                onPressed: () {
                  calculateInterest();
                },
                icon: Icon(
                  Icons.done,
                  color: Hex.color("303F9F"),
                ),
                label: Text("Submit"))
          ],
        ),
      ),
    );
  }

  Container montlyCommitment() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Monthly Deposit/Withdrawal (Optional)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Flexible(
                flex: 8,
                child: TextField(
                  controller: initAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "1",
                    helperText: "Monthly commitment with investment?",
                    contentPadding: EdgeInsets.only(left: 10.0),
                  ),
                  onChanged: (value) {
                    print(value);
                    if (value == null) {
                      value = "0";
                    }
                    setState(() {
                      _selectedMontlyCommitmentVal = double.parse(value);
                    });
                  },
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  padding: EdgeInsets.all(10.0),
                  // padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Hex.color("303F9F").withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _monthlyCommitment.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMontlyCommitment = value;
                      });
                    },
                    value: _selectedMontlyCommitment,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container compoundFrequency() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Compound Frequency"),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10),
                child: DropdownButton<String>(
                  isExpanded: true,
                  items: _compoundRatePeriods.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCompoundInterval = value;
                    });
                  },
                  value: _selectedCompoundInterval,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "Times per year the interest will be compounded",
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Container investmentPeriod() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Investment Period"),
          Row(
            children: <Widget>[
              Flexible(
                flex: 8,
                child: TextField(
                  controller: periodController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "1",
                    helperText: "How long do you plan on investing?",
                    contentPadding: EdgeInsets.only(left: 10.0),
                    errorText:
                        _periodValidate ? 'Value Can\'t Be Empty or 0' : null,
                  ),
                  onChanged: (value) {
                    print(value);
                    if (value == null) {
                      value = "0";
                    }
                    setState(() {
                      _periodValidate =
                          validateInputs(periodController, int.tryParse(value));
                      _selectedPeriodVal = int.parse(value);
                    });
                  },
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  padding: EdgeInsets.all(10.0),
                  // padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Hex.color("303F9F").withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items: _periods.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value;
                      });
                    },
                    value: _selectedPeriod,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container interestRate() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      // decoration: BoxDecoration(
      //   color: Colors.transparent,
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Interest Rate"),
          Row(
            children: <Widget>[
              Flexible(
                flex: 8,
                child: TextField(
                  controller: interestController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "1",
                    helperText: "The percentage increase over a period",
                    suffixText: " %",
                    contentPadding: EdgeInsets.only(left: 10.0),
                    errorText: _interestValidate
                        ? 'Value Can\'t Be Less than 1'
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _interestValidate =
                          validateMoneyInputs(interestController);
                      _selectedInterestVal = double.tryParse(value);
                    });
                  },
                ),
              ),
              Flexible(
                flex: 5,
                child: Container(
                  margin: EdgeInsets.only(left: 10.0),
                  padding: EdgeInsets.all(10.0),
                  // padding: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Hex.color("303F9F").withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    items:
                        _interestRatePeriods.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedInterest = value;
                      });
                    },
                    value: _selectedInterest,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container initialAmount() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Initial Amount"),
          TextField(
            controller: initAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.attach_money),
              prefixText: "$_selectedSymbol",
              helperText: "The Amount invested the first month",
              errorText:
                  _initialAmountValidate ? 'Value Can\'t Be Less than 1' : null,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (value) {
              if (value == null) {
                value = "0.00";
              }
              setState(() {
                _initialAmountValidate =
                    validateMoneyInputs(initAmountController);
                _initialAmount = double.parse(value);
              });
            },
          ),
        ],
      ),
    );
  }

  Container selectCurrency() {
    return Container(
      margin: EdgeInsets.only(top: _deviceHeight * 0.03),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: SearchableDropdown.single(
        items: currencyDropdownList,
        label: "Amount Currency",
        hint: "Select Your Currency",
        searchHint: "Sarch by Country",
        onChanged: (value) {
          setState(() {
            print(value);
            _selectedCurrency = value;
            if (value == null) {
              _selectedSymbol = "";
            } else {
              _selectedSymbol = "${_selectedCurrency.symbol} ";
            }
          });
        },
        displayItem: (item, selected) {
          return (Row(children: [
            selected
                ? Icon(
                    Icons.radio_button_checked,
                    color: Colors.grey,
                  )
                : Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                  ),
            SizedBox(width: 7),
            Expanded(
              child: item,
            ),
          ]));
        },
        isExpanded: true,
      ),
    );
  }

  Widget showInitialBalance(height) {
    return Container(
      margin: EdgeInsets.only(top: height * 0.07),
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: Colors.black12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[Text("Initial Deposit"), Text("\u20A6 200")],
      ),
    );
  }

  getPeriod() {
    switch (_selectedPeriod) {
      case 'Month(s)':
        return _selectedPeriodVal / 12;
        break;
      case "Year(s)":
        return _selectedPeriodVal;
        break;
      default:
    }
  }

  getRate() {
    switch (_selectedInterest) {
      case "Daily":
        return ((_selectedInterestVal / 100) / 365);
        break;
      case "Weekly":
        return ((_selectedInterestVal / 100) / 52);
        break;
      case "Monthly":
        return ((_selectedInterestVal / 100) / 12);
        break;
      case "Yearly":
        return ((_selectedInterestVal / 100));
        break;
      default:
    }
  }

  bool validateInputs(controller, value) {
    if (controller.text.isEmpty || value < 1) {
      return true;
    } else {
      return false;
    }
  }

  bool validateMoneyInputs(controller) {
    if (controller.text == "0.00" || double.tryParse(controller.text) < 1) {
      return true;
    } else {
      return false;
    }
  }

  void calculateInterest() {
    setState(() {
      _periodValidate = validateInputs(periodController, _selectedPeriodVal);
      _initialAmountValidate = validateMoneyInputs(initAmountController);
      _interestValidate = validateMoneyInputs(interestController);
    });

    if (!_periodValidate && !_interestValidate && !_initialAmountValidate) {
      double interest = _initialAmount * getRate() * getPeriod();
      _simpleInterest = interest != null ? interest.toStringAsFixed(2) : "";
      print("Simple Interest $_simpleInterest");
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Row(
          children: <Widget>[
            Icon(Icons.error),
            SizedBox(
              width: 10.0,
            ),
            Text(
              "Some Errors exist, please check and try again",
              style: TextStyle(color: Hex.color("FFFFFF")),
            )
          ],
        ),
      ));
    }
  }

  void convertCurrenciesToList() async {
    if (currencyList.isEmpty) {
      dynamic data2 = await DefaultAssetBundle.of(context)
          .loadString('assets/currencies.json');

      var ddd = await jsonDecode(data2);
      setState(() {
        currencyList =
            (ddd as List).map((data) => new Currencies.fromJson(data)).toList();

        currencyList.forEach((element) {
          currencyDropdownList.add(DropdownMenuItem(
            child: Text("${element.symbol} (${element.name})"),
            value: element,
          ));
        });
      });
    }
  }
}
