import 'package:easy_debounce/easy_debounce.dart';




void myMethod(String message){
    print(message);
}




void main() async {

    // Example 1
    // This will result in a single call to myMethod() after ~200 ms.
    print('\nExample 1');
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer1', Duration(milliseconds: 200), () => myMethod('Executing debouncer1! (i: $i)'));
    }

    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


    // Example 2
    // This will result in five calls to myMethod() since we are waiting 300 ms before running the next iteration
    // of the for-loop.
    print('\nExample 2');
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer2', Duration(milliseconds: 200), () => myMethod('Executing debouncer2! (i: $i)'));
        await Future.delayed(Duration(milliseconds: 300)); // Wait 300 ms
    }


    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


    // Example 3
    // This will result in two calls to myMethod() after ~200 ms, each with a different [message].
    // Since we are using two different tags ("debouncer3" and "debouncer4"), the two debouncers
    // operate independently of each other.
    print('\nExample 3');
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer3', Duration(milliseconds: 200), () => myMethod('Executing debouncer3! (i: $i)'));
        EasyDebounce.debounce('debouncer4', Duration(milliseconds: 200), () => myMethod('Executing debouncer4! (i: $i)'));
    }


    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


    // Example 4
    // When passing in a zero-duration, onExecute() is called synchronously. So the output of the code below would be
    // Executing debouncer5! (x: 1)
    // After debouncer5: x: 1
    print('\nExample 4');
    int x = 0;
    EasyDebounce.debounce('debouncer5', Duration.zero, (){ ++x; myMethod('Executing debouncer5! (x: $x)'); });
    print('After debouncer5: x: $x');


    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


    // Example 5
    // Opposite to Example 4, when passing in a non-zero duration, onExecute() is called asynchronously using a Timer.
    // So the output of the code below would be
    // After debouncer6: y: 0
    // Executing debouncer6! (y: 1)
    print('\nExample 5');
    int y = 0;
    EasyDebounce.debounce('debouncer6', Duration(milliseconds: 10), (){ ++y; myMethod('Executing debouncer6! (y: $y)'); });
    print('After debouncer6: y: $y');


    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


    // Example 6
    // When calling fire(), the callback associated with the soecified tag is called immediately. The callback timer is not
    // removed, so if you do not cancel the debouncer after calling fire(), it will still execute after the debounce duration.
    // The output of the code below would be:
    // Executing debouncer7! (z: 1)
    // After debouncer7: z: 1
    // Executing debouncer7! (z: 2)
    print('\nExample 6');
    int z = 0;
    EasyDebounce.debounce('debouncer7', Duration(milliseconds: 10), (){ ++z; myMethod('Executing debouncer7! (z: $z)'); });
    EasyDebounce.fire('debouncer7');
    print('After debouncer7: z: $z');


    // Make sure the above example finishes before continuing
    await Future.delayed(Duration(milliseconds: 400));


}

