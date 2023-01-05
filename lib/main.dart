import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Generator',
      home: FormGenerator(),
    );
  }
}

class FormGenerator extends StatefulWidget {
  @override
  _FormGeneratorState createState() => _FormGeneratorState();
}

class _FormGeneratorState extends State<FormGenerator> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? _formData;
  void generateForm(String jsonInput) {
    Map<String, dynamic> parsedJson = jsonDecode(jsonInput);
    setState(() {
      _formData = parsedJson;
      _isLoading = false;
    });
  }

  Future<void> dataStr() async {
    final String response = await rootBundle.loadString('assets/test.json');
    generateForm(response);
    print(response);
  }

  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dataStr();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildHomePage();
  }

  Widget _buildHomePage() {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formData!['title']),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            // Display form description
            // Generate form fields based on JSON input
            Column(
              children: [
                Text(_formData!['desc']),
                for (var field in _formData!['fields'])
                  _buildFormField(context, field),
              ],
            ),
            // Add submit and cancel buttons
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text(_formData!['cancelButtonText']),
                    onPressed: () {
                      // Navigate to previous screen
                    },
                  ),
                  ElevatedButton(
                    child: Text(_formData!['submitButtonText']),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        // Send form data to API
                        Uri url = Uri.parse(
                          _formData!['submitButtonAPI'],
                        );
                        http.Response response = await http.post(url);
                        if (response.statusCode == 200) {
                          print('Success');
                        } else {
                          print('Failed');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(BuildContext context, Map<String, dynamic> field) {
    switch (field['type']) {
      case 'textbox':
        return Container(
          height: 60,
          width: MediaQuery.of(context).size.width - 30,
          margin: EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            validator: (value) {
              for (var validation in field['validations']) {
                if (validation['length'] != null) {
                  if (value!.length < validation['length']['greaterThan']) {
                    return 'This field must be at least ${validation['length']['greaterThan']} characters long';
                  }
                }
              }
              return null;
            },
            decoration: InputDecoration(labelText: field['label']),
          ),
        );
        break;
      case 'slider':
        return Container(
          child: Slider(
            activeColor: Colors.purple,
            inactiveColor: Colors.purple.withOpacity(0.2),
            value: _formData![field['label']] ??
                double.parse(field['range']['min'].toString()),
            min: double.parse(field['range']['min'].toString()),
            max: double.parse(field['range']['max'].toString()),
            onChanged: (value) {
              setState(() {
                _formData![field['label']] = value;
              });
            },
            // validator: (value) {
            //   for (var validation in field['validations']) {
            //     if (validation['max'] != null && value > validation['max']) {
            //       return 'This field must be less than or equal to ${validation['max']}';
            //     }
            //     if (validation['min'] != null && value < validation['min']) {
            //       return 'This field must be greater than or equal to ${validation['min']}';
            //     }
            //     if (validation['required'] != null && validation['required']) {
            //       if (value == null) {
            //         return 'This field is required';
            //       }
            //     }
            //   }
            //   return null;
            // },
          ),
        );
        break;
      case 'dropdown':
        return Container(
          height: 60,
          width: MediaQuery.of(context).size.width - 30,
          margin: EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField(
            value: _formData![field['label']] ?? field['values'][0]['value'],
            items: field['values']
                .map<DropdownMenuItem<String>>(
                    (value) => DropdownMenuItem<String>(
                          value: value['value'],
                          child: Text(value['label']),
                        ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _formData![field['label']] = value;
              });
            },
            validator: (value) {
              for (var validation in field['validations']) {
                if (validation['required'] != null && validation['required']) {
                  if (value == null) {
                    return 'This field is required';
                  }
                }
              }
              return null;
            },
          ),
        );
        break;
      default:
        return Text('Invalid field type');
    }
  }
}
