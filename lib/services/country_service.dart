import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/country_model.dart';

class CountryService {
  Future<List<Country>> fetchCountries() async {
    final response = await http.get(
      Uri.parse('https://restcountries.com/v2/all?fields=name'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Country.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
