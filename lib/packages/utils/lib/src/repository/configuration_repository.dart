import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utils/env.dart';

const cloudPf = "sy/";

class ConfigurationRepository {
  Future<Map<String, dynamic>> getConfiguration() async {
    final response = await http.get(
      Uri.parse(
          "$apiCloudURL/$cloudPf/app-deployment?deployment-id=$deploymentId&app-code=$appCode"),
    );
    if (response.statusCode == 200) {
      final body =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return body["configuration"]["hConfig"];
    }
    throw Exception("Error get configuration!");
  }
}
