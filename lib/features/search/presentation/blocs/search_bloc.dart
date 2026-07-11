import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchHistoryRequested extends SearchEvent {}

class SearchQueryAdded extends SearchEvent {
  final String query;
  const SearchQueryAdded(this.query);
  @override
  List<Object?> get props => [query];
}

class SearchQueryRemoved extends SearchEvent {
  final String query;
  const SearchQueryRemoved(this.query);
  @override
  List<Object?> get props => [query];
}

/// Clears the entire search history (for the "Clear all" button — U3).
class SearchHistoryCleared extends SearchEvent {}

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchHistoryLoaded extends SearchState {
  final List<String> history;
  const SearchHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const String _historyKey = 'search_history';

  SearchBloc() : super(SearchInitial()) {
    on<SearchHistoryRequested>(_onHistoryRequested);
    on<SearchQueryAdded>(_onQueryAdded);
    on<SearchQueryRemoved>(_onQueryRemoved);
    on<SearchHistoryCleared>(_onHistoryCleared);
  }

  Future<void> _onHistoryRequested(
      SearchHistoryRequested event, Emitter<SearchState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      debugPrint('[SearchBloc] Failed to load history: $e');
      emit(const SearchHistoryLoaded([]));
    }
  }

  Future<void> _onQueryAdded(
      SearchQueryAdded event, Emitter<SearchState> emit) async {
    if (event.query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];

      // Move to top if already exists, otherwise insert at top.
      history.remove(event.query.trim());
      history.insert(0, event.query.trim());

      // Keep max 10 entries.
      if (history.length > 10) {
        history = history.sublist(0, 10);
      }

      // L2 fix: wrap write in try/catch so bloc never crashes on storage error.
      try {
        await prefs.setStringList(_historyKey, history);
      } catch (e) {
        debugPrint('[SearchBloc] Failed to persist history: $e');
      }

      emit(SearchHistoryLoaded(history));
    } catch (e) {
      debugPrint('[SearchBloc] Failed to add query: $e');
    }
  }

  Future<void> _onQueryRemoved(
      SearchQueryRemoved event, Emitter<SearchState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList(_historyKey) ?? [];
      history.remove(event.query);
      try {
        await prefs.setStringList(_historyKey, history);
      } catch (e) {
        debugPrint('[SearchBloc] Failed to persist history after remove: $e');
      }
      emit(SearchHistoryLoaded(history));
    } catch (e) {
      debugPrint('[SearchBloc] Failed to remove query: $e');
    }
  }

  Future<void> _onHistoryCleared(
      SearchHistoryCleared event, Emitter<SearchState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      try {
        await prefs.remove(_historyKey);
      } catch (e) {
        debugPrint('[SearchBloc] Failed to clear history: $e');
      }
      emit(const SearchHistoryLoaded([]));
    } catch (e) {
      debugPrint('[SearchBloc] Failed to clear history: $e');
    }
  }
}
