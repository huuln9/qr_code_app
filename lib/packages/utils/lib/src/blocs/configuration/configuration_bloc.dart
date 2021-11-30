import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:utils/src/models/models.dart';
import 'package:utils/src/repository/configuration_repository.dart';

part 'configuration_event.dart';
part 'configuration_state.dart';

class ConfigurationBloc extends Bloc<ConfigurationEvent, ConfigurationState> {
  final ConfigurationRepository _configurationRepository;

  ConfigurationBloc({required ConfigurationRepository configurationRepository})
      : _configurationRepository = configurationRepository,
        super(const ConfigurationState()) {
    on<GetConfigurationRequested>(_onGetConfigurationRequested);
  }

  void _onGetConfigurationRequested(
    GetConfigurationRequested event,
    Emitter<ConfigurationState> emit,
  ) async {
    try {
      final config = await _configurationRepository.getConfiguration();
      return emit(state.copyWith(status: configStatus.success, config: config));
    } catch (e) {
      return emit(state.copyWith(status: configStatus.failure));
    }
  }
}
