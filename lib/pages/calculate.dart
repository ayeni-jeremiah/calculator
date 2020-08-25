import 'dart:math';
import 'package:flutter/material.dart';
import 'package:calculator/services/color.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/services.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:calculator/services/currencies.dart';
import 'dart:convert';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class Calculate extends StatefulWidget {
  @override
  _CalculateState createState() => _CalculateState();
}

class _CalculateState extends State<Calculate> {
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

  // for the FRONT initial Amount amount text field
  var initAmountController = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  var monthlyAmountController = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  // for the FRONT Interest text field
  var interestController = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  // for the BACK initial Amount amount text field
  var initAmountControllerB = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  // for the BACK Interest text field
  var interestControllerB = new MoneyMaskedTextController(
    decimalSeparator: '.',
    thousandSeparator: ',',
    // initialValue: null,
  );

  var periodController = TextEditingController();

  var periodControllerB = TextEditingController();

  bool front = true; //tells if the flipcard is at the front or not

  //FIELDS FOR FRONT FORMS
  // ignore: avoid_init_to_null
  Currencies _selectedCurrency = null; // for the selected currency object
  static String _selectedSymbol = ""; // for the selected currency symbol
  double _initialAmount = 0.0;
  bool _initialAmountValidate = false;
  String _selectedInterest = _interestRatePeriods[3];
  double _selectedInterestVal = 0.0;
  bool _interestValidate = false;
  String _selectedPeriod = _periods[1];
  int _selectedPeriodVal = 0;
  bool _periodValidate = false;
  String _selectedCompoundInterval = _compoundRatePeriods[2];
  String _selectedMontlyCommitment = _monthlyCommitment[0];
  double _selectedMontlyCommitmentVal = 0.0;

  //FIELDS FOR SAVING BACK FORMS
  // ignore: avoid_init_to_null
  Currencies _selectedCurrencyB = null; // for the selected currency object
  static String _selectedSymbolB = ""; // for the selected currency symbol
  double _initialAmountB = 0.0;
  bool _initialAmountValidateB = false;
  String _selectedInterestB = _interestRatePeriods[3];
  double _selectedInterestValB = 0.0;
  bool _interestValidateB = false;
  String _selectedPeriodB = _periods[1];
  int _selectedPeriodValB = 0;
  bool _periodValidateB = false;

  String _simpleInterest = "";
  String _compoundInterest = "";

  @override
  void initState() {
    super.initState();
    convertCurrenciesToList();
  }

  @override
  Widget build(BuildContext context) {
    print("I'm refreshed");
    _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title: Text(front == true
              ? "Compound Calculator"
              : "Simple Interest Calculator"),
          elevation: 0.0,
          backgroundColor: Hex.color("303F9F")),
      backgroundColor: Hex.color("FFFFFF"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Hex.color("303F9F"),
        onPressed: () {
          cardKey.currentState.toggleCard();
          setState(() {
            if (front) {
              front = false;
            } else {
              front = true;
            }
          });
        },
        elevation: 0.0,
        child: Icon(
          Icons.swap_horiz,
          color: Hex.color("FFFFFF"),
        ),
        tooltip: "Switch Calculator",
      ),
      body: FlipCard(
        key: cardKey,
        speed: 1500,
        direction: FlipDirection.VERTICAL,
        flipOnTouch: false,
        front: Container(
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
              compoundFrequency(),
              montlyCommitment(),
              submitReset()
            ],
          ),
        ),
        back: Container(
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
      ),
    );
  }

  //WIDGETS
  Container submitReset() {
    return Container(
      margin: EdgeInsets.all(_deviceHeight * 0.03),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton.icon(
                onPressed: () {
                  reset();
                },
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
                flex: 5,
                child: TextField(
                  controller: monthlyAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "1",
                    prefixText: "$_selectedSymbol",
                    helperText: "Monthly commitment to investment?",
                    contentPadding: EdgeInsets.only(left: 10.0),
                  ),
                  onChanged: (value) {
                    print(value);
                    if (value == null) {
                      value = "0";
                    }
                    save(value: value, from: "montlyCommitmentValue");
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
                      save(value: value, from: "montlyCommitmentSelect");
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
                    save(value: value, from: "compoundFrequency");
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
                flex: 5,
                child: TextField(
                  controller: (front ? periodController : periodControllerB),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // hintText: "1 or More",
                    helperText: "How long do you plan on investing?",
                    contentPadding: EdgeInsets.only(left: 10.0),
                    errorText: (front ? _periodValidate : _periodValidateB)
                        ? 'Invalid Value or Empty or 0'
                        : null,
                  ),
                  onChanged: (value) {
                    print(value);
                    save(value: value, from: "investmentPeriodValue");
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
                      save(value: value, from: "investmentPeriodSelect");
                    },
                    value: (front ? _selectedPeriod : _selectedPeriodB),
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
                flex: 5,
                child: TextField(
                  controller:
                      (front ? interestController : interestControllerB),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    // hintText: "1",
                    helperText: "The percentage increase over a period",
                    suffixText: " %",
                    contentPadding: EdgeInsets.only(left: 10.0),
                    errorText: (front ? _interestValidate : _interestValidateB)
                        ? 'Value Can\'t Be Less than 1'
                        : null,
                  ),
                  onChanged: (value) {
                    save(value: value, from: "interestRateValue");
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
                        child: Text(
                          dropDownStringItem,
                          textAlign: TextAlign.right,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      save(value: value, from: "interestRateSelect");
                    },
                    value: (front ? _selectedInterest : _selectedInterestB),
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
            controller: (front ? initAmountController : initAmountControllerB),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              // prefixIcon: Icon(Icons.attach_money),
              prefixText: (front ? "$_selectedSymbol" : "$_selectedSymbolB"),
              helperText: "The Amount invested the first month",
              errorText:
                  (front ? _initialAmountValidate : _initialAmountValidateB)
                      ? 'Value Can\'t Be Less than 1'
                      : null,
              contentPadding: EdgeInsets.only(left: 10.0),
            ),
            onChanged: (value) {
              if (value == null) {
                value = "0.00";
              }
              save(value: value, from: "initialAmount");
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
        label: Text("Amount Currency (Optional)"),
        hint: "Select Your Currency",
        searchHint: "Sarch by Country",
        onChanged: (value) {
          save(value: value, from: "selectCurrency");
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

  //ACTIONS
  getPeriod() {
    if (front) {
      switch (_selectedPeriod) {
        case 'Month(s)':
          return _selectedPeriodVal / 12;
          break;
        case "Year(s)":
          return _selectedPeriodVal;
          break;
        default:
      }
    } else {
      switch (_selectedPeriodB) {
        case 'Month(s)':
          return _selectedPeriodValB / 12;
          break;
        case "Year(s)":
          return _selectedPeriodValB;
          break;
        default:
      }
    }
  }

  getRate() {
    if (front) {
      switch (_selectedInterest) {
        case "Daily":
          return ((_selectedInterestVal / 100) * 365);
          break;
        case "Weekly":
          return ((_selectedInterestVal / 100) * 52);
          break;
        case "Monthly":
          return ((_selectedInterestVal / 100) * 12);
          break;
        case "Yearly":
          return ((_selectedInterestVal / 100));
          break;
        default:
      }
    } else {
      switch (_selectedInterestB) {
        case "Daily":
          return ((_selectedInterestValB / 100) / 365);
          break;
        case "Weekly":
          return ((_selectedInterestValB / 100) / 52);
          break;
        case "Monthly":
          return ((_selectedInterestValB / 100) / 12);
          break;
        case "Yearly":
          return ((_selectedInterestValB / 100));
          break;
        default:
      }
    }
  }

  getCompoundInterval() {
    switch (_selectedCompoundInterval) {
      case "Daily":
        return 365;
        break;
      case "Weekly":
        return 52;
        break;
      case "Monthly":
        return 12;
        break;
      case "Quaterly":
        return 4;
        break;
      case "Half Yearly":
        return 2;
        break;
      default:
        return 1;
    }
  }

  bool validateInputs(value) {
    value = value.toString();
    String selected = "";
    if (front) {
      selected = _selectedPeriodVal.toString();
    } else {
      selected = _selectedPeriodValB.toString();
    }

    try {
      value = int.tryParse(value);
      if (selected.isEmpty || value < 1) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Error converting");
      return true;
    }
  }

  bool validateMoneyInputs(controller) {
    if (controller.text == "0.00" ||
        double.tryParse(controller.value.text.replaceAll(',', '')) < 1) {
      return true;
    } else {
      return false;
    }
  }

  void save({@required value, @required from}) {
    switch (from) {
      case "selectCurrency":
        if (front) {
          setState(() {
            _selectedCurrency = value;
            if (value == null) {
              _selectedSymbol = "";
            } else {
              _selectedSymbol = "${_selectedCurrency.symbol} ";
            }
          });
        } else {
          setState(() {
            _selectedCurrencyB = value;
            if (value == null) {
              _selectedSymbolB = "";
            } else {
              _selectedSymbolB = "${_selectedCurrencyB.symbol} ";
            }
          });
        }
        break;
      case "initialAmount":
        if (front) {
          setState(() {
            _initialAmountValidate = validateMoneyInputs(initAmountController);
            _initialAmount = double.parse(value);
          });
        } else {
          setState(() {
            _initialAmountValidateB =
                validateMoneyInputs(initAmountControllerB);
            _initialAmountB = double.parse(value);
          });
        }
        break;
      case "interestRateValue":
        if (front) {
          setState(() {
            _interestValidate = validateMoneyInputs(interestController);
            _selectedInterestVal = double.tryParse(value);
          });
        } else {
          setState(() {
            _interestValidateB = validateMoneyInputs(interestControllerB);
            _selectedInterestValB = double.tryParse(value);
          });
        }
        break;
      case "interestRateSelect":
        if (front) {
          setState(() {
            _selectedInterest = value;
          });
        } else {
          setState(() {
            _selectedInterestB = value;
          });
        }
        break;
      case "investmentPeriodValue":
        if (front) {
          setState(() {
            _periodValidate = validateInputs(value);
            _selectedPeriodVal = int.tryParse(value);
          });
        } else {
          setState(() {
            _periodValidateB = validateInputs(value);
            _selectedPeriodValB = int.tryParse(value);
          });
        }
        break;
      case "investmentPeriodSelect":
        if (front) {
          setState(() {
            _selectedPeriod = value;
          });
        } else {
          setState(() {
            _selectedPeriodB = value;
          });
        }
        break;
      case "compoundFrequency":
        setState(() {
          _selectedCompoundInterval = value;
        });
        break;
      case "montlyCommitmentValue":
        setState(() {
          _selectedMontlyCommitmentVal = double.parse(value);
        });
        break;
      case "montlyCommitmentSelect":
        setState(() {
          _selectedMontlyCommitment = value;
        });
        break;

      default:
    }
  }

  void calculateInterest() {
    if (front) {
      int currentPeriod = (_selectedPeriodVal);
      var rate = getRate();
      var compounding = getCompoundInterval();
      var period = getPeriod();

      List interestPerPeriod = [];
      var interest;
      double initialAmount =
          double.tryParse(initAmountController.value.text.replaceAll(',', ''));

      //CALCULATE COMPOUND INTEREST
      if (_selectedPeriod == "Year(s)" &&
          _selectedCompoundInterval == "Yearly") {
        while (currentPeriod > 0) {
          if (currentPeriod == _selectedPeriodVal) {
            interest = initialAmount + (initialAmount * rate);
            interestPerPeriod.add(interest);
          } else {
            interest = interest * (1 + rate);
            interestPerPeriod.add(interest);
          }

          currentPeriod--;
        }
        print(interest);
        print(interestPerPeriod);
      } else {
        // interest = initialAmount *
        //     pow((1 + (rate / compounding)), (compounding * period));
        var myPeriod = _selectedPeriodVal;
        var aPeriod = myPeriod * 12;
        while (currentPeriod > 0) {
          interest += initialAmount *
            pow((1 + (rate / compounding)), (compounding * aPeriod));

          aPeriod++;
        }

        print(compounding * period);
        print(interest);
      }
    } else {
      //CALCULATE SIMPLE INTEREST
      setState(() {
        _periodValidateB = validateInputs(_selectedPeriodValB);
        _initialAmountValidateB = validateMoneyInputs(initAmountControllerB);
        _interestValidateB = validateMoneyInputs(interestControllerB);
      });

      if (!_periodValidateB &&
          !_interestValidateB &&
          !_initialAmountValidateB) {
        double interest =
            double.tryParse(initAmountControllerB.text.replaceAll(",", "")) *
                getRate() *
                getPeriod();
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
                "Some Errors exist, please fix first",
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(color: Hex.color("FFFFFF")),
              )
            ],
          ),
        ));
      }
    }
  }

  void reset() {
    if (front) {
      setState(() {
        _selectedCurrency = null; // for the selected currency object
        _selectedSymbol = ""; // for the selected currency symbol
        _initialAmount = 0.0;
        _initialAmountValidate = false;
        initAmountController.value = TextEditingValue(text: "0.0");
        _selectedInterest = _interestRatePeriods[2];
        _selectedInterestVal = 0.0;
        _interestValidate = false;
        interestController.value = TextEditingValue(text: "0.0");
        _selectedPeriod = _periods[0];
        _selectedPeriodVal = 0;
        _periodValidate = false;
        periodController.clear();
        _selectedCompoundInterval = _compoundRatePeriods[2];
        _selectedMontlyCommitment = _monthlyCommitment[0];
        _selectedMontlyCommitmentVal = 0.0;
        monthlyAmountController.value = TextEditingValue(text: "0.0");

        _compoundInterest = "";
      });
    } else {
      setState(() {
        _selectedCurrencyB = null; // for the selected currency object
        _selectedSymbolB = ""; // for the selected currency symbol
        _initialAmountB = 0.0;
        _initialAmountValidateB = false;
        initAmountControllerB.value = TextEditingValue(text: "0.0");
        _selectedInterestB = _interestRatePeriods[3];
        _selectedInterestValB = 0.0;
        _interestValidateB = false;
        interestControllerB.value = TextEditingValue(text: "0.0");
        _selectedPeriodB = _periods[1];
        _selectedPeriodValB = 0;
        _periodValidateB = false;
        periodControllerB.clear();

        _simpleInterest = "";
      });
    }
    print(_selectedCurrencyB);
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
