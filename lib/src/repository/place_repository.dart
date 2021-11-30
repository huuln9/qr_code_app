import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vncitizens/src/repository/abs_repository.dart';
import 'package:vncitizens/src/repository/model/utilities.dart';

enum UtilitiesStatus { initial, success, failure }

const size = 10;
const svcPlacePf = "pl/place";

class PlaceRepository extends AbsRepository {
  final String utilitiesTagId;

  PlaceRepository({required apiGatewayURL, required this.utilitiesTagId})
      : super(apiGatewayURL);

  Future<List<Utilities>> getListUtilities(int page, String accessToken) async {
    final response = await http.get(
      Uri.parse(
          '$apiGatewayURL/$svcPlacePf/--search?tag-id=$utilitiesTagId&page=$page&size=$size'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final body =
          json.decode(utf8.decode(response.bodyBytes))['content'] as List;

      return body.map(
        (dynamic json) {
          return Utilities(
            num: json['num'] ?? 0,
            id: json['id'] ?? '',
            name: json['name'] ?? '',
            icon: json['thumbnail'] ?? '',
            latitude: json['location']['latitude'] ?? 0,
            longitude: json['location']['longitude'] ?? 0,
            phoneNumber: json['phoneNumber'] ?? '',
            address: json['baPlace']['address'] ?? '',
          );
        },
      ).toList();
    }
    throw Exception('Error get list utilities!');
  }
}
