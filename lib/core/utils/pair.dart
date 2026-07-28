/// A simple pair (tuple) of two values.
class Pair<T, R> {
  Pair({
    required this.first,
    required this.second,
  });
  T first;
  R second;
}

/// A simple triple of three values.
class Triple<T, R, S> {
  Triple({
    required this.first,
    required this.second,
    required this.third,
  });
  T first;
  R second;
  S third;
}