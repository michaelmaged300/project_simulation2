import 'package:flutter/material.dart';
import 'simulation_logic.dart';

class SimulationScreen extends StatefulWidget {
  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final TextEditingController _numCustomersController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  List<double> arrivalProbs = [0.1, 0.2, 0.3, 0.25, 0.15];
  List<double> serviceProbs = [0.3, 0.25, 0.2, 0.15, 0.1];
  List<int> times = [1, 2, 3, 4, 5];

  void simulate() {
    int? numCustomers = int.tryParse(_numCustomersController.text);

    if (numCustomers == null || numCustomers <= 0) {
      _showAlert("Please enter a valid number of customers.");
      return;
    }

    if (arrivalProbs.reduce((a, b) => a + b) != 1 ||
        serviceProbs.reduce((a, b) => a + b) != 1) {
      _showAlert("Probabilities must sum to 1.");
      return;
    }

    setState(() {
      results = runSimulation(
        numCustomers,
        times,
        arrivalProbs,
        times,
        serviceProbs,
      );
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Queue Simulation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _numCustomersController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Number of Customers"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: simulate,
              child: Text("Simulate"),
            ),
            SizedBox(height: 20),
            results.isNotEmpty
                ? Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Customer")),
                    DataColumn(label: Text("Interval Time")),
                    DataColumn(label: Text("Arrival Time")),
                    DataColumn(label: Text("Rand. Service")),
                    DataColumn(label: Text("Service")),
                    DataColumn(label: Text("Start Time")),
                    DataColumn(label: Text("Duration")),
                    DataColumn(label: Text("End Time")),
                    DataColumn(label: Text("Waiting Time")),
                    DataColumn(label: Text("Idle Time")),
                  ],
                  rows: results.map((result) {
                    return DataRow(cells: [
                      DataCell(Text(result['customer'].toString())),
                      DataCell(Text(result['intervalTime'].toString())),
                      DataCell(Text(result['arrivalTime'].toString())),
                      DataCell(Text(result['randService'].toString())),
                      DataCell(Text(result['service'].toString())),
                      DataCell(Text(result['startTime'].toString())),
                      DataCell(Text(result['duration'].toString())),
                      DataCell(Text(result['endTime'].toString())),
                      DataCell(Text(result['waitingTime'].toString())),

                      DataCell(Text(result['idleTime'].toString())),
                    ]);
                  }).toList(),
                ),
              ),
            )
                : Text("No results to display."),
          ],
        ),
      ),
    );
  }
}