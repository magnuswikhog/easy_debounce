import 'dart:async';

import 'package:test/test.dart';

import 'package:easy_debounce/easy_throttle.dart';

void main() {

  tearDown(() async {
    final Completer completer = new Completer();
    late Timer tearDownTimer;

    tearDownTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (EasyThrottle.count() == 0) {
        tearDownTimer.cancel();
        completer.complete();
      }
    });

    return completer.future;
  });

  test('onExecute is never invoked for throttled calls', () {
    final String id = "never-invoked";

    var onExecute = expectAsync1((String value) {
      expect(value, id);
    }, count: 1);

    EasyThrottle.throttle(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyThrottle.throttle(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyThrottle.throttle(id, Duration(milliseconds: 100), () => onExecute(id));
    EasyThrottle.throttle(id, Duration(milliseconds: 100), () => onExecute(id));
  });

  test('onExecute is called with no delay', () {
    DateTime start = DateTime.now();

    var onExecute = expectAsync0(() {
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
      expect(actualExpectedDiffMs < 10, true); // 10 ms is reasonable
    }, count: 1);

    Duration duration = Duration(milliseconds: 100);
    EasyThrottle.throttle("no-delay", duration, () => onExecute());
  });

  test('each call to throttle only executes if the initial throttle has finish', () async {
    DateTime start = DateTime.now();

    var onExecute = expectAsync1((int index) {
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = startStopDiff.inMilliseconds.abs();
      expect(actualExpectedDiffMs < 10 || actualExpectedDiffMs > 500, true);
      expect(index == 0 || index == 4, true);
    }, count: 2);

    EasyThrottle.throttle('has-finished', Duration(milliseconds: 500), () => onExecute(0));
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 110));
      EasyThrottle.throttle('has-finished', Duration(milliseconds: 100), () => onExecute(i));
    }
  });

  test('multiple throttles can be run at the same time and will each invoke onExecute', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyThrottle.throttle('multiple-1', Duration(milliseconds: 300), () => onExecute());
    EasyThrottle.throttle('multiple-2', Duration(milliseconds: 300), () => onExecute());
    EasyThrottle.throttle('multiple-3', Duration(milliseconds: 300), () => onExecute());
  });

  test('the first call to throttle invokes onExecute', () async {
    var onExecute = expectAsync1((int i) {
      expect(i, 1);
    }, count: 1);

    EasyThrottle.throttle('first-call', Duration(milliseconds: 300), () => onExecute(1));
    EasyThrottle.throttle('first-call', Duration(milliseconds: 300), () => onExecute(2));
    EasyThrottle.throttle('first-call', Duration(milliseconds: 300), () => onExecute(3));
    EasyThrottle.throttle('first-call', Duration(milliseconds: 300), () => onExecute(4));
    EasyThrottle.throttle('first-call', Duration(milliseconds: 300), () => onExecute(5));
  });

  test('zero-duration is a valid duration', () async {
    var onExecute = expectAsync0(() {}, count: 1);
    EasyThrottle.throttle('zero-duration', Duration.zero, () => onExecute());
  });

  test('count() returns the number of active throttles', () async {
    var onExecute = expectAsync0(() {}, count: 3);
    expect(EasyThrottle.count(), 0);
    EasyThrottle.throttle('count-1', Duration(milliseconds: 500), () => onExecute());
    expect(EasyThrottle.count(), 1);
    EasyThrottle.throttle('count-2', Duration(milliseconds: 500), () => onExecute());
    expect(EasyThrottle.count(), 2);
    EasyThrottle.throttle('count-3', Duration(milliseconds: 500), () => onExecute());

    expect(EasyThrottle.count(), 3);
  });

  test('cancel() cancels a throttle', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    expect(EasyThrottle.count(), 0);

    EasyThrottle.throttle('cancel-cancels-1', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-cancels-2', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-cancels-3', Duration(milliseconds: 500), () => onExecute());

    expect(EasyThrottle.count(), 3);

    EasyThrottle.cancel('cancel-cancels-1');
    EasyThrottle.cancel('cancel-cancels-2');
    EasyThrottle.cancel('cancel-cancels-3');

    expect(EasyThrottle.count(), 0);
  });

  test('cancel() decreases the number of active throttles', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyThrottle.throttle('cancel-count-1', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-count-2', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-count-3', Duration(milliseconds: 500), () => onExecute());
    expect(EasyThrottle.count(), 3);
    EasyThrottle.cancel('cancel-count-1');
    expect(EasyThrottle.count(), 2);
  });

  test('calling cancel() on a non-existing tag doesn\'t cause an exception', () async {
    EasyThrottle.cancel('non-existing tag');
  });

  test('cancelAll() cancels and removes all timers', () async {
    var onExecute = expectAsync0(() {}, count: 3);

    EasyThrottle.throttle('cancel-all-1', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-all-2', Duration(milliseconds: 500), () => onExecute());
    EasyThrottle.throttle('cancel-all-3', Duration(milliseconds: 500), () => onExecute());
    expect(EasyThrottle.count(), 3);
    EasyThrottle.cancelAll();
    expect(EasyThrottle.count(), 0);
  });
}
