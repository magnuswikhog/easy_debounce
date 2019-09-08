import 'package:easy_debounce/easy_debounce.dart';




void myMethod(String message){
    print(message);
}




void main() async {

    // Example 1
    // This will result in a single call to myMethod() after ~200 ms.
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer1', Duration(milliseconds: 200), () => myMethod('Executing debouncer1! (i: $i)'));
    }

    // Make sure the above example finishes before continuting
    await Future.delayed(Duration(milliseconds: 400));


    // Example 2
    // This will result in five calls to myMethod() since we are waiting 300 ms before running the next iteration
    // of the for-loop.
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer2', Duration(milliseconds: 200), () => myMethod('Executing debouncer2! (i: $i)'));
        await Future.delayed(Duration(milliseconds: 300)); // Wait 300 ms
    }


    // Make sure the above example finishes before continuting
    await Future.delayed(Duration(milliseconds: 400));


    // Example 3
    // This will result in two calls to myMethod() after ~200 ms, each with a different [message].
    // Since we are using two different tags ("debouncer3" and "debouncer4"), the two debouncers
    // operate independently of each other.
    for(int i=0; i<5; i++){
        EasyDebounce.debounce('debouncer3', Duration(milliseconds: 200), () => myMethod('Executing debouncer3! (i: $i)'));
        EasyDebounce.debounce('debouncer4', Duration(milliseconds: 200), () => myMethod('Executing debouncer4! (i: $i)'));
    }

}

