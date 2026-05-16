import 'package:flutter/material.dart';

class MenuAppController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const pageDashboard = 'dashboard';
  static const pageJobs = 'jobs';

  String _currentPage = pageDashboard;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  String get currentPage => _currentPage;

  void navigateTo(String page) {
    if (_currentPage == page) return;
    _currentPage = page;
    notifyListeners();
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }
}
