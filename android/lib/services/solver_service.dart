import '../models/solver.dart';

class SolverService {
  /// Fetch top solvers from API or database
  /// This is a mock implementation - replace with actual API call
  static Future<List<Solver>> getTopSolvers() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - replace with actual backend API call
    const solversData = [
      {
        'rank': 1,
        'name': 'Dr. Sarah Chen',
        'contributions': 42,
        'rating': 4.8,
        'specialty': 'Water Treatment',
        'isRegistered': true,
      },
      {
        'rank': 2,
        'name': 'Alex Rivera',
        'contributions': 38,
        'rating': 4.7,
        'specialty': 'Environmental Chemistry',
        'isRegistered': true,
      },
      {
        'rank': 3,
        'name': 'Prof. James Watson',
        'contributions': 35,
        'rating': 4.6,
        'specialty': 'Polymer Science',
        'isRegistered': true,
      },
      {
        'rank': 4,
        'name': 'Maria Kowalski',
        'contributions': 29,
        'rating': 4.5,
        'specialty': 'Marine Biology',
        'isRegistered': true,
      },
      {
        'rank': 5,
        'name': 'Ahmed Hassan',
        'contributions': 27,
        'rating': 4.4,
        'specialty': 'Material Science',
        'isRegistered': true,
      },
      {
        'rank': 6,
        'name': 'Yuki Tanaka',
        'contributions': 24,
        'rating': 4.3,
        'specialty': 'Environmental Science',
        'isRegistered': true,
      },
      {
        'rank': 7,
        'name': 'Dr. Robert Patel',
        'contributions': 21,
        'rating': 4.2,
        'specialty': 'Chemistry',
        'isRegistered': true,
      },
      {
        'rank': 8,
        'name': 'Jessica Brown',
        'contributions': 19,
        'rating': 4.1,
        'specialty': 'Research',
        'isRegistered': true,
      },
      {
        'rank': 9,
        'name': 'Dr. Emily Stone',
        'contributions': 17,
        'rating': 4.0,
        'specialty': 'Environmental Chemistry',
        'isRegistered': true,
      },
      {
        'rank': 10,
        'name': 'Klaus Mueller',
        'contributions': 15,
        'rating': 3.9,
        'specialty': 'Polymer Analysis',
        'isRegistered': true,
      },
    ];

    return solversData
        .map(
          (data) => Solver(
            rank: data['rank'] as int,
            name: data['name'] as String,
            solutionsCount: data['contributions'] as int,
            rating: data['rating'] as double,
            specialty: data['specialty'] as String,
            isRegistered: data['isRegistered'] as bool,
          ),
        )
        .toList();
  }
}
