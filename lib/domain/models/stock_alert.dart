/// How urgent a stock alert is. The order of the values is the display order:
/// critical first, low last.
enum Severity { critical, high, medium, low }

/// One stock alert for one branch, as sent by Nour head office.
///
/// Immutable: a change creates a new object through [copyWith].
/// Do not change the constructor, the fields or the method signatures.
final class StockAlert {
  const StockAlert({
    required this.id,
    required this.medicineNameEn,
    required this.medicineNameAr,
    required this.severity,
    required this.daysOfCover,
    required this.branchCode,
    this.acknowledged = false,
  });

  final String id;
  final String medicineNameEn;
  final String medicineNameAr;
  final Severity severity;
  final double daysOfCover;
  final String branchCode;
  final bool acknowledged;

  /// Reads one alert from the head-office JSON feed.
  ///
  /// TODO(W2): validate every field as the README says. Any invalid input
  /// throws a FormatException, never a TypeError.
  factory StockAlert.fromJson(Map<String, Object?> json) {
    String readRequiredString(String key) {
      final value = json[key];

      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$key must be a non-empty string');
      }

      return value;
    }

    final id = readRequiredString('id');
    final medicineNameEn = readRequiredString('medicineNameEn');
    final medicineNameAr = readRequiredString('medicineNameAr');
    final branchCode = readRequiredString('branchCode');

    final severityValue = json['severity'];

    if (severityValue is! String) {
      throw const FormatException('severity must be a string');
    }

    final severityName = severityValue.toLowerCase();

    final severity = switch (severityName) {
      'critical' => Severity.critical,
      'high' => Severity.high,
      'medium' => Severity.medium,
      'low' => Severity.low,
      _ => throw FormatException('Invalid severity: $severityValue'),
    };

    final daysValue = json['daysOfCover'];

    if (daysValue is! num || !daysValue.isFinite || daysValue < 0) {
      throw const FormatException('daysOfCover must be a non-negative number');
    }

    final daysOfCover = daysValue.toDouble();

    final acknowledgedValue = json['acknowledged'];
    bool acknowledged = false;

    if (json.containsKey('acknowledged')) {
      if (acknowledgedValue is! bool) {
        throw const FormatException('acknowledged must be a bool');
      }

      acknowledged = acknowledgedValue;
    }

    return StockAlert(
      id: id,
      medicineNameEn: medicineNameEn,
      medicineNameAr: medicineNameAr,
      severity: severity,
      daysOfCover: daysOfCover,
      branchCode: branchCode,
      acknowledged: acknowledged,
    );
  }

  /// TODO(W2): return a new StockAlert with the given fields replaced.
  StockAlert copyWith({
    String? id,
    String? medicineNameEn,
    String? medicineNameAr,
    Severity? severity,
    double? daysOfCover,
    String? branchCode,
    bool? acknowledged,
  }) {
    return StockAlert(
      id: id ?? this.id,
      medicineNameEn: medicineNameEn ?? this.medicineNameEn,
      medicineNameAr: medicineNameAr ?? this.medicineNameAr,
      severity: severity ?? this.severity,
      daysOfCover: daysOfCover ?? this.daysOfCover,
      branchCode: branchCode ?? this.branchCode,
      acknowledged: acknowledged ?? this.acknowledged,
    );
  }

  /// TODO(W2): value equality over all seven fields.
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StockAlert &&
            other.id == id &&
            other.medicineNameEn == medicineNameEn &&
            other.medicineNameAr == medicineNameAr &&
            other.severity == severity &&
            other.daysOfCover == daysOfCover &&
            other.branchCode == branchCode &&
            other.acknowledged == acknowledged;
  }

  /// TODO(W2): consistent with ==.
  @override
  int get hashCode => Object.hash(
    id,
    medicineNameEn,
    medicineNameAr,
    severity,
    daysOfCover,
    branchCode,
    acknowledged,
  );
}
