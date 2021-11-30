import 'package:flutter/material.dart';
import 'package:vncitizens/app.dart';
import 'package:vncitizens/src/repository/configuration_repository.dart';

void main() {
  runApp(App(configurationRepository: ConfigurationRepository()));
}
