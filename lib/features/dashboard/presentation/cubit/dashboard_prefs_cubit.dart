import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds lightweight dashboard display preferences.
class DashboardPrefsCubit extends Cubit<DashboardPrefsState> {
  DashboardPrefsCubit() : super(const DashboardPrefsState());

  void toggleStatsCards() => emit(state.copyWith(showStatsCards: !state.showStatsCards));
  void setStatsCards({required bool visible}) => emit(state.copyWith(showStatsCards: visible));
}

class DashboardPrefsState {
  final bool showStatsCards;

  const DashboardPrefsState({this.showStatsCards = true});

  DashboardPrefsState copyWith({bool? showStatsCards}) =>
      DashboardPrefsState(showStatsCards: showStatsCards ?? this.showStatsCards);
}
