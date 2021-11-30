part of 'utilities_bloc.dart';

class UtilitiesState extends Equatable {
  final UtilitiesStatus status;
  final List<Utilities> listUtilities;
  final bool hasReachedMax;
  final int nextPage;

  const UtilitiesState({
    this.status = UtilitiesStatus.initial,
    this.listUtilities = const [],
    this.hasReachedMax = false,
    this.nextPage = 0,
  });

  UtilitiesState copyWith({
    UtilitiesStatus? status,
    List<Utilities>? listUtilities,
    bool? hasReachedMax,
    int? nextPage,
  }) {
    return UtilitiesState(
      status: status ?? this.status,
      listUtilities: listUtilities ?? this.listUtilities,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  List<Object?> get props => [status, listUtilities, hasReachedMax, nextPage];
}
