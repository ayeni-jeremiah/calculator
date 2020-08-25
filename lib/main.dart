import 'package:calculator/pages/compound.dart';
import 'package:calculator/pages/simple.dart';
import 'package:flutter/material.dart';
import 'package:calculator/pages/calculate.dart';


void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/' : (context) => Calculate(), 
      '/compound' : (context) => CalculateCompound(), 
    },
  ));
}
