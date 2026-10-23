import 'package:flutter/material.dart';

import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branch alerts')),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(
              child: CircularProgressIndicator(key: Key('alerts-loading')),
            );
          }

          final alerts = viewModel.visibleAlerts;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  key: const Key('search-field'),
                  onChanged: viewModel.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search medicines',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: Severity.values.map((severity) {
                    final selected = viewModel.activeFilters.contains(severity);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        key: Key('filter-${severity.name}'),
                        label: Text(_severityLabel(severity)),
                        selected: selected,
                        onSelected: (_) {
                          viewModel.toggleFilter(severity);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${alerts.length} '
                    '${alerts.length == 1 ? 'alert' : 'alerts'}',
                    key: const Key('alerts-count'),
                  ),
                ),
              ),
              Expanded(
                child: alerts.isEmpty
                    ? const Center(
                        child: Text(
                          'No alerts found',
                          key: Key('alerts-empty'),
                        ),
                      )
                    : ListView.builder(
                        key: const Key('alerts-list'),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];

                          return Card(
                            key: Key('alert-${alert.id}'),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text(alert.medicineNameEn),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(alert.medicineNameAr),
                                  Text(
                                    'Severity: '
                                    '${_severityLabel(alert.severity)}',
                                  ),
                                  Text(
                                    'Days of cover: '
                                    '${alert.daysOfCover}',
                                  ),
                                  if (alert.acknowledged)
                                    const Text('Acknowledged'),
                                ],
                              ),
                              trailing: alert.acknowledged
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : IconButton(
                                      key: Key('ack-${alert.id}'),
                                      tooltip: 'Acknowledge alert',
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                      ),
                                      onPressed: () {
                                        viewModel.acknowledge(alert.id);
                                      },
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _severityLabel(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return 'Critical';
      case Severity.high:
        return 'High';
      case Severity.medium:
        return 'Medium';
      case Severity.low:
        return 'Low';
    }
  }
}
