import 'dart:math';

List<Map<String, dynamic>> runSimulation(
    int customers,
    List<int> arrivalTimes,
    List<double> arrivalProbs,
    List<int> serviceTimes,
    List<double> serviceProbs,
    ) {
  List<Map<String, dynamic>> results = [];
  double prevArrival = 0, prevEnd = 0;

  for (int i = 0; i < customers; i++) {
    double randArrival = Random().nextDouble();
    double randService = Random().nextDouble();

    int intervalTime = getTimeFromProbability(randArrival, arrivalTimes, arrivalProbs);
    double arrivalTime = prevArrival + intervalTime;

    int serviceTime = getTimeFromProbability(randService, serviceTimes, serviceProbs);
    double startTime = max(arrivalTime, prevEnd);
    double endTime = startTime + serviceTime;

    // حساب مدة الخدمة
    double duration = endTime - arrivalTime;

    results.add({
      'customer': i + 1,
      'randArrival': (randArrival * 100).toStringAsFixed(0),
      'intervalTime': intervalTime,
      'arrivalTime': arrivalTime,
      'startTime': startTime,
      'randService': (randService * 100).toStringAsFixed(0),
      'service': serviceTime,
      'endTime': endTime,
      'duration': duration.toStringAsFixed(2),
      'waitingTime': max(0, startTime - arrivalTime),
      'idleTime': max(0, startTime - prevEnd),
    });

    prevArrival = arrivalTime;
    prevEnd = endTime;
  }

  return results;
}

int getTimeFromProbability(double randomValue, List<int> times, List<double> probabilities) {
  double cumulative = 0;
  for (int i = 0; i < probabilities.length; i++) {
    cumulative += probabilities[i];
    if (randomValue <= cumulative) {
      return times[i];
    }
  }
  return times.last;
}