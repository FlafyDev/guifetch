Stream<dynamic> counterStream() async* {
  yield 0;
  yield* Stream.periodic(const Duration(seconds: 1), (i) => 1 + i);
}
