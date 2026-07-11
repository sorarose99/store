import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kLangPrefKey = 'app_language';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('ar'));

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangPrefKey) ?? 'ar';
    emit(Locale(saved));
  }

  Future<void> setArabic() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangPrefKey, 'ar');
    emit(const Locale('ar'));
  }

  Future<void> setEnglish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangPrefKey, 'en');
    emit(const Locale('en'));
  }

  Future<void> toggle() async {
    if (state.languageCode == 'ar') {
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  bool get isArabic => state.languageCode == 'ar';
}
