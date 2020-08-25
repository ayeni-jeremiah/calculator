import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _personCount = 0;
  int _sliderPosition = 1;

  @override
  Widget build(BuildContext context) {
    double _deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: _deviceHeight * 0.07),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.black12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text("Total Amount"), Text("\u20A6 200")],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: _deviceHeight * 0.03),
              padding: EdgeInsets.all(10.0),
              // width: 150,
              // height: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(width: 1.0, color: Colors.black12),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.attach_money),
                      labelText: "Bill Amount",

                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Person(s)"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              setState(() {
                                _personCount++;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: EdgeInsets.only(right: 5.0),
                              decoration: BoxDecoration(color: Colors.black),
                              child: Center(
                                child: Text("+",
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                          Text("$_personCount"),
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (_personCount <= 0) {
                                  _personCount = 0;
                                } else {
                                  _personCount--;
                                }
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: EdgeInsets.only(left: 5.0),
                              decoration: BoxDecoration(color: Colors.black),
                              child: Center(
                                child: Text("-",
                                    style: TextStyle(
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Column(

                    children: <Widget>[
                      Text("Percentage Scale",),
                      Slider(
                          value: _sliderPosition.toDouble(),
                          min: 1.0,
                          max: 100.0,
                          divisions: 100,
                          label: '$_sliderPosition%',
                          onChanged: (double newValue) {
                            setState(() {
                              _sliderPosition = newValue.round();
                            });
                          },
                          activeColor: Colors.black,
                          semanticFormatterCallback: (double newValue) {
                            return '${newValue.round()} dollars';
                          }),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
