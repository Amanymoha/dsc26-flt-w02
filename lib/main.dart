import 'package:flutter/material.dart';

import 'data/repositories/alert_repository.dart';
import 'domain/models/stock_alert.dart';
import 'ui/alerts/view_models/alerts_view_model.dart';
import 'ui/alerts/widgets/alerts_screen.dart';

void main() {
  runApp(NourShelfApp(repository: InMemoryAlertRepository(demoAlerts)));
}

/// A few alerts for running the app by hand (`flutter run`).
const List<StockAlert> demoAlerts = [
  StockAlert(
    id: 'insulin',
    medicineNameEn: 'Insulin glargine',
    medicineNameAr: 'انسولين جلارجين',
    severity: Severity.critical,
    daysOfCover: 2,
    branchCode: 'CAI-014',
  ),
  StockAlert(
    id: 'levo',
    medicineNameEn: 'Levothyroxine 50 mcg',
    medicineNameAr: 'ليفوثيروكسين ٥٠ ميكروجرام',
    severity: Severity.high,
    daysOfCover: 6,
    branchCode: 'CAI-014',
  ),
  StockAlert(
    id: 'amox',
    medicineNameEn: 'Amoxicillin syrup',
    medicineNameAr: 'شراب أموكسيسيلين',
    severity: Severity.medium,
    daysOfCover: 9,
    branchCode: 'CAI-014',
  ),
  StockAlert(
    id: 'vitd',
    medicineNameEn: 'Vitamin D3 drops',
    medicineNameAr: 'نقط فيتامين د',
    severity: Severity.low,
    daysOfCover: 30,
    branchCode: 'CAI-014',
  ),
];

/// The app root.
///
/// TODO(W2): keep this constructor. Create the AlertsViewModel here (once),
/// call load(), show AlertsScreen, and dispose the view model when this
/// widget goes away. It probably needs to become a StatefulWidget.
class NourShelfApp extends StatefulWidget {
  const NourShelfApp({super.key, required this.repository});

  final AlertRepository repository;

  @override
  State<NourShelfApp> createState() => _NourShelfAppState();
}

class _NourShelfAppState extends State<NourShelfApp> {
  late final AlertsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AlertsViewModel(repository: widget.repository);
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AlertsScreen(viewModel: _viewModel));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CounterScreen(),
    );
  }
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('$_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
