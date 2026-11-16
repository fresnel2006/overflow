import 'dart:math' as math;

final _rng = math.Random();

/// Latence reseau simulee pour que les etats de chargement soient visibles avec les donnees fictives.
Future<void> mockDelay([int minMs = 350, int maxMs = 900]) =>
    Future.delayed(Duration(milliseconds: minMs + _rng.nextInt(math.max(1, maxMs - minMs))));
