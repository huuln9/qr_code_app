part of 'configuration_bloc.dart';

class ConfigurationState extends Equatable {
  final configStatus status;
  final Map<String, dynamic> config;

  const ConfigurationState({
    this.status = configStatus.initial,
    this.config = const {},
  });

  ConfigurationState copyWith({
    configStatus? status,
    Map<String, dynamic>? config,
  }) {
    return ConfigurationState(
      status: status ?? this.status,
      config: config ?? this.config,
    );
  }

  @override
  List<Object> get props => [status, config];
}
