import 'dart:async';
import 'dart:math';


class CitiesService {

  CitiesService({required this.locationName});

  late final String locationName;



  static final List<String> cities = [
    'Beirut',
    'Damascus',
    'San Fransisco',
    'Rome',
    'Los Angeles',
    'Madrid',
    'Bali',
    'Barcelona',
    'Paris',
    'Bucharest',
    'New York City',
    'Philadelphia',
    'Sydney',
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(cities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}

//
// var _token = 'fsq3MPCrWAoSAAHkszVJzpf/ge+bsvu4MI+HptEWYMb+4BE=';
// Dio dio = Dio();
// dio.options.headers['Content-Type'] = 'application/json';
// dio.options.headers['Accept'] = 'application/json';
// dio.options.headers["Authorization"] = "$_token";
//
// var response = await dio.get(
// 'https://api.foursquare.com/v3/places/search?near=${latitude}%2C${longitude}',
// queryParameters: {"name": filter},
// );
//
//
// // http.Response response = await http.get(Uri.parse(
// //     'https://api.foursquare.com/v3/places/search?near=${latitude}%2C${longitude}'), headers: {
// //   "Content-Type": "application/json",
// //   "Accept": "application/json",
// //   "Authorization": "$_token",
// // });
// // print(response.data);
// var data = response.data;
// var test = data['results'][0]['fsq_id'];
// print('testdata ${test}');
// var models = UserModel.fromJsonList(data);
// print(models);
// return models;