import 'package:easy_debounce/easy_debounce.dart';

void myMethod(String message) {
  print(message);
}

void main() async {
  // Example 1
  // This will result in a single call to myMethod() after ~200 ms.
  print('\nExample 1');
  for (int i = 0; i < 5; i++) {
    EasyDebounce.debounce(
        tag: 'debouncer1',
        duration: Duration(milliseconds: 200),
        onExecute: () => myMethod('Executing debouncer1! (i: $i)'));
  }

  // Make sure the above example finishes before continuting
  await Future.delayed(Duration(milliseconds: 400));

  // Example 2
  // This will result in five calls to myMethod() since we are waiting 300 ms before running the next iteration
  // of the for-loop.
  print('\nExample 2');
  for (int i = 0; i < 5; i++) {
    EasyDebounce.debounce(
        tag: 'debouncer2',
        duration: Duration(milliseconds: 200),
        onExecute: () => myMethod('Executing debouncer2! (i: $i)'));
    await Future.delayed(Duration(milliseconds: 300)); // Wait 300 ms
  }

  // Make sure the above example finishes before continuting
  await Future.delayed(Duration(milliseconds: 400));

  // Example 3
  // This will result in two calls to myMethod() after ~200 ms, each with a different [message].
  // Since we are using two different tags ("debouncer3" and "debouncer4"), the two debouncers
  // operate independently of each other.
  print('\nExample 3');
  for (int i = 0; i < 5; i++) {
    EasyDebounce.debounce(
        tag: 'debouncer3',
        duration: Duration(milliseconds: 200),
        onExecute: () => myMethod('Executing debouncer3! (i: $i)'));
    EasyDebounce.debounce(
        tag: 'debouncer4',
        duration: Duration(milliseconds: 200),
        onExecute: () => myMethod('Executing debouncer4! (i: $i)'));
  }

  // Make sure the above example finishes before continuting
  await Future.delayed(Duration(milliseconds: 400));

  // Example 4
  // When passing in a zero-duration, onExecute() is called synchronously. So the output of the code below would be
  // Executing debouncer5! (x: 1)
  // After debouncer5: x: 1
  print('\nExample 4');
  int x = 0;
  EasyDebounce.debounce(
      tag: 'debouncer5',
      duration: Duration.zero,
      onExecute: () {
        ++x;
        myMethod('Executing debouncer5! (x: $x)');
      });
  print('After debouncer5: x: $x');

  // Make sure the above example finishes before continuting
  await Future.delayed(Duration(milliseconds: 400));

  // Example 5
  // Opposite to Example 4, when passing in a non-zero duration, onExecute() is called asynchronously using a Timer.
  // So the output of the code below would be
  // After debouncer6: y: 0
  // Executing debouncer6! (y: 1)
  print('\nExample 5');
  int y = 0;
  EasyDebounce.debounce(
      tag: 'debouncer6',
      duration: Duration(milliseconds: 10),
      onExecute: () {
        ++y;
        myMethod('Executing debouncer6! (y: $y)');
      });
  print('After debouncer6: y: $y');
}
