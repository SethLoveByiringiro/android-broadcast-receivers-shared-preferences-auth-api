import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = "0";
  String _equation = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operand = "";
  bool _isOperandClicked = false;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _equation = "";
        _num1 = 0;
        _num2 = 0;
        _operand = "";
        _isOperandClicked = false;
      } else if (buttonText == "+" ||
          buttonText == "-" ||
          buttonText == "×" ||
          buttonText == "÷") {
        if (_operand.isNotEmpty && !_isOperandClicked) {
          _calculate();
        }
        _num1 = double.parse(_output);
        _operand = buttonText;
        _isOperandClicked = true;
        _equation += " $_operand ";
      } else if (buttonText == ".") {
        if (!_output.contains(".")) {
          _output += buttonText;
        }
      } else if (buttonText == "=") {
        _calculate();
        _operand = "";
        _isOperandClicked = false;
      } else {
        if (_isOperandClicked) {
          _output = buttonText;
          _isOperandClicked = false;
        } else {
          _output = (_output == "0") ? buttonText : _output + buttonText;
        }
        _equation += buttonText;
      }
    });
  }

  void _calculate() {
    _num2 = double.parse(_output);
    switch (_operand) {
      case "+":
        _output = (_num1 + _num2).toString();
        break;
      case "-":
        _output = (_num1 - _num2).toString();
        break;
      case "×":
        _output = (_num1 * _num2).toString();
        break;
      case "÷":
        _output = (_num1 / _num2).toString();
        break;
    }
    _num1 = double.parse(_output);
    _equation = _output;
  }

  Widget _buildButton(String buttonText, Color buttonColor, Color textColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: FittedBox(
            fit: BoxFit.contain,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                buttonText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(16),
                alignment: Alignment.bottomRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _equation,
                      style: TextStyle(color: Colors.grey, fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _output,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("C", Colors.grey, Colors.black),
                          _buildButton("+/-", Colors.grey, Colors.black),
                          _buildButton("%", Colors.grey, Colors.black),
                          _buildButton("÷", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("7", Colors.grey[850]!, Colors.white),
                          _buildButton("8", Colors.grey[850]!, Colors.white),
                          _buildButton("9", Colors.grey[850]!, Colors.white),
                          _buildButton("×", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("4", Colors.grey[850]!, Colors.white),
                          _buildButton("5", Colors.grey[850]!, Colors.white),
                          _buildButton("6", Colors.grey[850]!, Colors.white),
                          _buildButton("-", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("1", Colors.grey[850]!, Colors.white),
                          _buildButton("2", Colors.grey[850]!, Colors.white),
                          _buildButton("3", Colors.grey[850]!, Colors.white),
                          _buildButton("+", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          _buildButton("0", Colors.grey[850]!, Colors.white),
                          _buildButton(".", Colors.grey[850]!, Colors.white),
                          _buildButton("=", Colors.orange, Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
