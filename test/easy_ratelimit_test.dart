import 'dart:async';

import 'package:test/test.dart';

import 'package:easy_debounce/easy_rateLimit.dart';

void main() {

  tearDown(() async {
    final Completer completer = new Completer();
    late Timer tearDownTimer;

    tearDownTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (EasyRateLimit.count() == 0) {
        tearDownTimer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  });

  test('onExecute is never invoked for only 1 of the rate limited calls', () {
    final String id = "never-invoked";

    var onExecute = expectAsync1((String value) {
      expect(value, id);
    }, count: 2);

    EasyRateLimit.rateLimit(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyRateLimit.rateLimit(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyRateLimit.rateLimit(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyRateLimit.rateLimit(id, Duration(milliseconds: 100), () => onExecute(id));
  });

  test('onExecute is called with no delay', () {
    DateTime start = DateTime.now();

    var onExecute = expectAsync0(() {
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
      expect(actualExpectedDiffMs < 10, true); // 10 ms is reasonable
    }, count: 1);

    Duration duration = Duration(milliseconds: 100);
    EasyRateLimit.rateLimit("no-delay", duration, () => onExecute());
  });

  test('each call to rateLimit only executes if the rateLimit has finished', () async {
    DateTime start = DateTime.now();

    var onExecute = expectAsync1((int index) {
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
      expect(actualExpectedDiffMs < 10 || actualExpectedDiffMs > 500, true);
      expect(index == 0 || index == 3 || index == 4, true);
    }, count: 3);

    EasyRateLimit.rateLimit('has-finished', Duration(milliseconds: 500), () => onExecute(0));
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 110));
      EasyRateLimit.rateLimit('has-finished', Duration(milliseconds: 100), () => onExecute(i));
    }
  });

  test('multiple rateLimits can be run at the same time and will each invoke onExecute', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyRateLimit.rateLimit('multiple-1', Duration(milliseconds: 300), () => onExecute());
    EasyRateLimit.rateLimit('multiple-2', Duration(milliseconds: 300), () => onExecute());
    EasyRateLimit.rateLimit('multiple-3', Duration(milliseconds: 300), () => onExecute());
  });

  test('the first and last calls to rateLimit invokes onExecute', () async {
    var onExecute = expectAsync1((int i) {
      expect(i == 1 || i == 5, true);
    }, count: 2);

    EasyRateLimit.rateLimit('first-call', Duration(milliseconds: 300), () => onExecute(1));
    EasyRateLimit.rateLimit('first-call', Duration(milliseconds: 300), () => onExecute(2));
    EasyRateLimit.rateLimit('first-call', Duration(milliseconds: 300), () => onExecute(3));
    EasyRateLimit.rateLimit('first-call', Duration(milliseconds: 300), () => onExecute(4));
    EasyRateLimit.rateLimit('first-call', Duration(milliseconds: 300), () => onExecute(5));
  });

  test('zero-duration is a valid duration', () async {
    var onExecute = expectAsync0(() {}, count: 1);
    EasyRateLimit.rateLimit('zero-duration', Duration.zero, () => onExecute());
  });

  test('count() returns the number of active rateLimits', () async {
    var onExecute = expectAsync0(() {}, count: 3);
    expect(EasyRateLimit.count(), 0);
    EasyRateLimit.rateLimit('count-1', Duration(milliseconds: 500), () => onExecute());
    expect(EasyRateLimit.count(), 1);
    EasyRateLimit.rateLimit('count-2', Duration(milliseconds: 500), () => onExecute());
    expect(EasyRateLimit.count(), 2);
    EasyRateLimit.rateLimit('count-3', Duration(milliseconds: 500), () => onExecute());

    expect(EasyRateLimit.count(), 3);
  });

  test('cancel() cancels a rateLimit', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    expect(EasyRateLimit.count(), 0);

    EasyRateLimit.rateLimit('cancel-cancels-1', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-cancels-2', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-cancels-3', Duration(milliseconds: 500), () => onExecute());

    expect(EasyRateLimit.count(), 3);

    EasyRateLimit.cancel('cancel-cancels-1');
    EasyRateLimit.cancel('cancel-cancels-2');
    EasyRateLimit.cancel('cancel-cancels-3');

    expect(EasyRateLimit.count(), 0);
  });

  test('cancel() decreases the number of active rateLimits', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyRateLimit.rateLimit('cancel-count-1', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-count-2', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-count-3', Duration(milliseconds: 500), () => onExecute());
    expect(EasyRateLimit.count(), 3);
    EasyRateLimit.cancel('cancel-count-1');
    expect(EasyRateLimit.count(), 2);
  });

  test('calling cancel() on a non-existing tag doesn\'t cause an exception', () async {
    EasyRateLimit.cancel('non-existing tag');
  });

  test('cancelAll() cancels and removes all timers', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyRateLimit.rateLimit('cancel-all-1', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-all-2', Duration(milliseconds: 500), () => onExecute());
    EasyRateLimit.rateLimit('cancel-all-3', Duration(milliseconds: 500), () => onExecute());
    expect(EasyRateLimit.count(), 3);
    EasyRateLimit.cancelAll();
    expect(EasyRateLimit.count(), 0);
  });
}
