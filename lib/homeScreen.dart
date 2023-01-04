import 'package:benam/api.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const List<String> cities = <String>[
  "delhi",
  "mumbai",
];

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCity = cities[0];
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  double _price = 200;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Benam'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                   SizedBox(height: 10,),
                  Container(
                    height: 40,
                    width: width - 30,
                    margin: EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        validator: (value) {
                          if (value!.length < 10) {
                            return 'Please enter at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 40,
                    width: width - 30,
                    margin: EdgeInsets.fromLTRB(7.5, 7.5, 7.5, 7.5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        validator: (value) {
                          if (value!.length < 10) {
                            return 'Please enter at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Slider(
                    min: 200,
                    divisions: 20,
                    max: 5000,
                    label: _price.round().toString(),
                    value: _price,
                    activeColor: Colors.purple,
                    inactiveColor: Colors.purple.withOpacity(0.2),
                    onChanged: ((value) => setState(() => _price = value)),
                  ),
                  DropdownButton<String>(
                    value: _selectedCity,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                    onChanged: (String? value) {
                      // This is called when the user selects an item.
                      setState(() {
                        _selectedCity = value!;
                      });
                    },
                    items: cities.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              // 2 buttons with name send and go back
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          int res = await api([
                            _firstNameController.text,
                            _lastNameController.text,
                            _price.toString(),
                            _selectedCity,
                          ]);
                        }
                      },
                      child: const Text('Send'),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
