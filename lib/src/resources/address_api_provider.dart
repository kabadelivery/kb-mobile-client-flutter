import 'package:http/http.dart' show Client;



class AddressApiProvider {

  Client client = Client();

  /*Future<RestaurantModel> fetchRestaurantHomeList() async {

    print("entered");
    final response = await client
        .get("http://api.themoviedb.org/3/movie/popular?api_key=$_apiKey");
    print(response.body.toString());
    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return RestaurantModel.fromJson(json.decode(response.body));
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }*/
//  }



}
