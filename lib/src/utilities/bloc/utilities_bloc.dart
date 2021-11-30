import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vncitizens/src/repository/model/utilities.dart';
import 'package:vncitizens/src/repository/place_repository.dart';

part 'utilities_event.dart';
part 'utilities_state.dart';

class UtilitiesBloc extends Bloc<UtilitiesEvent, UtilitiesState> {
  final PlaceRepository _utilitiesRepository;
  final String accessToken;

  UtilitiesBloc({
    required PlaceRepository utilitiesRepository,
    required this.accessToken,
  })  : _utilitiesRepository = utilitiesRepository,
        super(const UtilitiesState()) {
    on<GetListUtilitiesRequested>(_onGetListUtilitiesRequested);
  }

  void _onGetListUtilitiesRequested(
    GetListUtilitiesRequested event,
    Emitter<UtilitiesState> emit,
  ) async {
    if (state.hasReachedMax) return emit(state);
    try {
      final listUtilities = await _utilitiesRepository.getListUtilities(
          state.nextPage, accessToken);
      if (state.status == UtilitiesStatus.initial) {
        return emit(state.copyWith(
          status: UtilitiesStatus.success,
          listUtilities: listUtilities,
          hasReachedMax: false,
          nextPage: state.nextPage + 1,
        ));
      }
      return emit(listUtilities.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: UtilitiesStatus.success,
              listUtilities: List.of(state.listUtilities)
                ..addAll(listUtilities),
              hasReachedMax: false,
              nextPage: state.nextPage + 1,
            ));
    } catch (e) {
      return emit(state.copyWith(status: UtilitiesStatus.failure));
    }
  }
}
