import 'dart:convert' as convert;

import 'package:http/http.dart' as http;

Future<int> api(List<String> arguments) async {
  var url =
      Uri.https('https://api.benam.me/api/form/submit', '', {});

  // Await the http get response, then decode the json-formatted response.
  var response = await http.post(url);
return response.statusCode;
}