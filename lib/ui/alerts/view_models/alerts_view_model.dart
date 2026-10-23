import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

/// Turns the alerts from [AlertRepository] into what the alerts screen shows.
///
/// Keep these public signatures exactly: the hidden tests call them.
/// Add private fields and helpers as you need.
class AlertsViewModel extends ChangeNotifier {
 AlertsViewModel({required this._repository});

  final AlertRepository _repository;

  bool _loading = false;

  List<StockAlert> _alerts = <StockAlert>[];

  final Set<Severity> _activeFilters = <Severity>{};

  String _query = '';

  /// True while [load] is in progress.
  bool get loading => _loading;

  /// The severities currently shown. Empty means "show all".
  Set<Severity> get activeFilters => Set<Severity>.unmodifiable(_activeFilters);

  /// Fetches the alerts from the repository.
  Future<void> load() async {
    _loading = true;
    notifyListeners();

    try {
      _alerts = await _repository.fetchAlerts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('ـ', '')
        .replaceAll(RegExp('[\u064B-\u0652]'), '');
  }

  /// Unmodifiable; filtered by severity and search query, then sorted.
  List<StockAlert> get visibleAlerts {
    final filtered = _alerts.where((alert) {
      final matchesSeverity =
          _activeFilters.isEmpty || _activeFilters.contains(alert.severity);

      final matchesQuery =
          _query.isEmpty ||
          _normalize(alert.medicineNameEn).contains(_query) ||
          _normalize(alert.medicineNameAr).contains(_query);

      return matchesSeverity && matchesQuery;
    }).toList();

    filtered.sort((a, b) {
      if (a.acknowledged != b.acknowledged) {
        return a.acknowledged ? 1 : -1;
      }

      final severityComparison = a.severity.index.compareTo(b.severity.index);

      if (severityComparison != 0) {
        return severityComparison;
      }

      final daysComparison = a.daysOfCover.compareTo(b.daysOfCover);

      if (daysComparison != 0) {
        return daysComparison;
      }

      return a.medicineNameEn.toLowerCase().compareTo(
        b.medicineNameEn.toLowerCase(),
      );
    });

    return List<StockAlert>.unmodifiable(filtered);
  }

  void toggleFilter(Severity severity) {
    if (_activeFilters.contains(severity)) {
      _activeFilters.remove(severity);
    } else {
      _activeFilters.add(severity);
    }

    notifyListeners();
  }

  void setQuery(String query) {
    final normalizedQuery = _normalize(query);

    if (_query == normalizedQuery) {
      return;
    }

    _query = normalizedQuery;
    notifyListeners();
  }

  Future<void> acknowledge(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);

    if (index == -1 || _alerts[index].acknowledged) {
      return;
    }

    final acknowledgement = _repository.acknowledge(id);
    final updatedAlerts = List<StockAlert>.of(_alerts);

    updatedAlerts[index] = updatedAlerts[index].copyWith(acknowledged: true);

    _alerts = updatedAlerts;
    notifyListeners();

    await acknowledgement;
  }

  /// Unacknowledged critical alerts among ALL loaded alerts.
  int get unacknowledgedCriticalCount => _alerts
      .where(
        (alert) => alert.severity == Severity.critical && !alert.acknowledged,
      )
      .length;
}
