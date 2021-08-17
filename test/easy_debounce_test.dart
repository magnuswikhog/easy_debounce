import 'package:flutter_test/flutter_test.dart';

import 'package:easy_debounce/easy_debounce.dart';

void main() {

  test('onExecute is never invoked for debounced calls', () {
    var onExecute = expectAsync1((String value){
      expect(value, 'test4');
    }, count: 1);

    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute('test1'));
    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute('test2'));
    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute('test3'));
    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute('test4'));
  });


  test('onExecute is called within reasonable time of expected delay', () {
    DateTime start = DateTime.now();

    var onExecute = expectAsync0((){
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = (startStopDiff.inMilliseconds.abs() - 1000).abs();
      expect( actualExpectedDiffMs < 100, true ); // 100 ms is reasonable
    }, count: 1);

    Duration duration = Duration(milliseconds: 1000);
    EasyDebounce.debounce('test1', duration, () => onExecute());
  });


  test('each call to debounce waits for the set duration', () async {
    DateTime start = DateTime.now();

    var onExecute = expectAsync0((){
      Duration startStopDiff = DateTime.now().difference(start);
      int actualExpectedDiffMs = (startStopDiff.inMilliseconds.abs() - 1100).abs();
      expect( actualExpectedDiffMs < 100, true ); // 100 ms is reasonable
    }, count: 1);

    for(int i=0; i<5; i++){
      EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute());
      await Future.delayed(Duration(milliseconds: 200));
    }
  });


  test('multiple debouncers can be run at the same time and will each invoke onExecute', () async {
    var onExecute = expectAsync0((){}, count: 3);

    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute());
    EasyDebounce.debounce('test2', Duration(milliseconds: 300), () => onExecute());
    EasyDebounce.debounce('test3', Duration(milliseconds: 300), () => onExecute());
  });


  test('the last call to debounce invokes onExecute', () async {
    var onExecute = expectAsync1((int i){
      expect(i, 5);
    }, count: 1);

    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute(1));
    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute(2));
    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute(3));
    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute(4));
    EasyDebounce.debounce('test1', Duration(milliseconds: 300), () => onExecute(5));
  });


  test('zero-duration is a valid duration', () async {
    var onExecute = expectAsync0((){}, count: 1);
    EasyDebounce.debounce('test1', Duration.zero, () => onExecute());
  });


  test('count() returns the number of active debouncers', () async {
    int iExpected = 2;

    var onExecute = expectAsync0((){
      expect(EasyDebounce.count(), iExpected--);
    }, count: 3);

    EasyDebounce.debounce('test1', Duration(milliseconds: 100), () => onExecute());
    EasyDebounce.debounce('test2', Duration(milliseconds: 100), () => onExecute());
    EasyDebounce.debounce('test3', Duration(milliseconds: 100), () => onExecute());
  });


  test('cancel() cancels a debouncer', () async {
    var onExecute = expectAsync0((){}, count: 0);

    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute());
    EasyDebounce.debounce('test2', Duration(milliseconds: 1000), () => onExecute());
    EasyDebounce.debounce('test3', Duration(milliseconds: 1000), () => onExecute());

    EasyDebounce.cancel('test1');
    EasyDebounce.cancel('test2');
    EasyDebounce.cancel('test3');
  });


  test('cancel() decreases the number of active debouncers', () async {
    int iExpected = 1;

    var onExecute = expectAsync0((){
      expect(EasyDebounce.count(), iExpected--);
    }, count: 2);

    EasyDebounce.debounce('test1', Duration(milliseconds: 100), () => onExecute());
    EasyDebounce.debounce('test2', Duration(milliseconds: 100), () => onExecute());
    EasyDebounce.debounce('test3', Duration(milliseconds: 100), () => onExecute());
    EasyDebounce.cancel('test1');
  });


  test('calling cancel() on a non-existing tag doesn\'t cause an exception', () async {
    EasyDebounce.cancel('non-existing tag');
  });


  test('zero-duration should execute target method synchronously', () async {
    int test = 1;

    var onExecute = expectAsync0((){
      expect(test--, 1);
    }, count: 1);

    EasyDebounce.debounce('test1', Duration.zero, () => onExecute());
    expect(test, 0);
  });


  test('non-zero duration should execute target method asynchronously', () async {
    int test = 1;

    var onExecute = expectAsync0((){
      expect(test, 0);
    }, count: 1);

    EasyDebounce.debounce('test1', Duration(microseconds: 1), () => onExecute());
    expect(test--, 1);
  });

  test('calling fire() should execute the callback immediately', () async {
    var onExecute = expectAsync0((){}, count: 1);

    EasyDebounce.debounce('test1', Duration(seconds: 1), () => onExecute());
    EasyDebounce.fire('test1');
    EasyDebounce.cancel('test1');
  });

  test('calling fire() should not remove the debounce timer', () async {
    var onExecute = expectAsync0((){}, count: 2);

    EasyDebounce.debounce('test1', Duration(seconds: 1), () => onExecute());
    EasyDebounce.fire('test1');
  });

  test('cancelAll() cancels and removes all timers', () async {
    var onExecute = expectAsync0((){}, count: 0);

    EasyDebounce.debounce('test1', Duration(milliseconds: 1000), () => onExecute());
    EasyDebounce.debounce('test2', Duration(milliseconds: 1000), () => onExecute());
    EasyDebounce.debounce('test3', Duration(milliseconds: 1000), () => onExecute());

    EasyDebounce.cancelAll();
    expect(EasyDebounce.count(), 0);
  });

}
