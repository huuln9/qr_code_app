// import 'package:http/http.dart' as http;
// import 'package:vncitizens/src/repository/abs_repository.dart';

// const filemanPf = "/fi/file";

// class FilemanRepository extends AbsRepository {
//   FilemanRepository(String apiGatewayURL) : super(apiGatewayURL);

//   void getFile(String accessToken) async {
//     final response = await http.get(
//       Uri.parse('$apiGatewayURL/$filemanPf/id/filename+size'),
//       headers: {
//         'Authorization': 'Bearer $accessToken',
//       },
//     );
//     if (response.statusCode == 200) {
//       // final body =
//       //     json.decode(utf8.decode(response.bodyBytes))['content'] as List;
//     }
//     throw Exception('Error get list utilities!');
//   }
// }
