import 'package:flutter/material.dart';
import 'dart:math';

class SimulationScreen extends StatefulWidget {
  @override
  _SimulationScreenState createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final TextEditingController _numCustomersController = TextEditingController();
  List<Map<String, dynamic>> results = [];

  List<double> arrivalProbs = [0.1, 0.2, 0.3, 0.25, 0.15];
  List<String> services = ["new", "delete", "inquiry", "deposit", "withdraw"];
  Map<String, double> serviceDurations = {
    "new": 7,
    "delete": 5.5,
    "inquiry": 3,
    "deposit": 4.5,
    "withdraw": 7.5
  };

  void simulate() {
    int? numCustomers = int.tryParse(_numCustomersController.text);

    if (numCustomers == null || numCustomers <= 0) {
      _showAlert("Please enter a valid number of customers.");
      return;
    }

    if (arrivalProbs.reduce((a, b) => a + b) != 1) {
      _showAlert("Arrival probabilities must sum to 1.");
      return;
    }

    setState(() {
      results = runSimulation(numCustomers, arrivalProbs, services);
    });
  }

  List<Map<String, dynamic>> runSimulation(
      int customers, List<double> arrivalProbs, List<String> services) {
    List<Map<String, dynamic>> results = [];
    double prevArrival = 0, prevEnd = 0;

    for (int i = 0; i < customers; i++) {
      double randArrival = Random().nextDouble();
      double randService = Random().nextDouble();

      int intervalTime = 1 + Random().nextInt(5); // Interval Time بين 1 و5
      double arrivalTime = (i == 0) ? 0 : prevArrival + intervalTime;

      String service = getServiceFromProbability(randService, services);
      double startTime = max(arrivalTime, prevEnd);
      double duration = serviceDurations[service]!;
      double endTime = startTime + duration;

      results.add({
        'customer': i + 1,
        'intervalTime': intervalTime,
        'arrivalTime': arrivalTime.toStringAsFixed(2),
        'randService': (randService * 100).toStringAsFixed(0),
        'service': service,
        'startTime': startTime.toStringAsFixed(2),
        'duration': duration.toStringAsFixed(2),
        'endTime': endTime.toStringAsFixed(2),
        'waitingTime': max(0, startTime - arrivalTime).toStringAsFixed(2),
        'idleTime': max(0, startTime - prevEnd).toStringAsFixed(2),
      });

      prevArrival = arrivalTime;
      prevEnd = endTime;
    }

    return results;
  }

  String getServiceFromProbability(double randomValue, List<String> services) {
    double cumulative = 0.0;
    for (int i = 0; i < services.length; i++) {
      cumulative += arrivalProbs[i];
      if (randomValue <= cumulative) {
        return services[i];
      }
    }
    return services.last; // Fallback, shouldn't be reached
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
      appBar: AppBar(title: Text("Task2 Simulation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          TextField(
          controller: _numCustomersController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Number of Customers",
            hintText: "Enter a positive integer",
          ),
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
          scrollDirection: Axis.vertical,
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
                DataColumn(label: Text("Idle Time")),
                DataColumn(label: Text("Waiting Time")),
              ],
              rows: results.map((result) {
                int index = result['customer'] - 1;
                return DataRow(
                  color: MaterialStateColor.resolveWith(
                          (states) => index % 2 == 0
                          ? Colors.grey.shade200
                          : Colors.white),
                  cells: [
                    DataCell(Text(result['customer'].toString())),
                    DataCell(Text(result['intervalTime'].toString())),
                    DataCell(Text(result['arrivalTime'].toString())),
                    DataCell(Text(result['randService'].toString())),
                    DataCell(Text(result['service'].toString())),
                    DataCell(Text(result['startTime'].toString())),
                    DataCell(Text(result['duration'].toString())),
                    DataCell(Text(result['endTime'].toString())),
                    DataCell(Text(result['idleTime'].toString())),
                    DataCell(Text(result['waitingTime'].toString())),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      )
          : Text("No results to display."),
      ],
    ),
    ));
  }
}

void main() => runApp(MaterialApp(home: SimulationScreen()));