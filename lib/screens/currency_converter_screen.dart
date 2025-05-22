import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _convertedAmountController =
      TextEditingController(); // Controller for converted amount
  String _fromCurrency = 'USD';
  String _toCurrency = 'INR';
  bool _isLoading = false;

  // Your ExchangeRate-API key here
  final String apiKey =
      'f3e45c772ecfa98294338a9b'; // Replace with your API key from ExchangeRate-API
  final String baseUrl = 'https://v6.exchangerate-api.com/v6';

  // Fetch currency conversion rate from ExchangeRate-API
  Future<void> _convertCurrency() async {
    if (_amountController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Construct the API URL using your API key
      final url = Uri.parse('$baseUrl/$apiKey/latest/$_fromCurrency');

      // Make the API request
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] == 'success') {
          // Retrieve the conversion rate for the target currency
          double conversionRate = data['conversion_rates'][_toCurrency];

          double amount = double.parse(_amountController.text);
          double result = amount * conversionRate;

          setState(() {
            _convertedAmountController.text = result
                .toStringAsFixed(2); // Display converted amount in the field
          });
        } else {
          setState(() {
            _convertedAmountController.text = 'Error: ${data['error']['info']}';
          });
        }
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      setState(() {
        _convertedAmountController.text = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedAmountController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Currency Converter",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Amount:',
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount in $_fromCurrency',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'From Currency:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _fromCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _fromCurrency = newValue!;
                    });
                  },
                  items: <String>['USD', 'EUR', 'INR', 'GBP']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'To Currency:',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _toCurrency,
                  onChanged: (String? newValue) {
                    setState(() {
                      _toCurrency = newValue!;
                    });
                  },
                  items: <String>['INR', 'USD', 'EUR', 'GBP']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _convertCurrency,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Convert'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:
                  _convertedAmountController, // Display the converted amount in this field
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Converted Amount:',
                border: const OutlineInputBorder(),
                hintText: 'Converted amount in $_toCurrency',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
