# easy_debounce

An extremely easy-to-use method call **debouncer** and **throttler** package for Dart/Flutter.

#### Debouncing
Debouncing is needed when there is a possibility of multiple calls to a method being made within a short duration of each other, and it's desireable that only the last of those calls actually invoke the target method.

So basically each call starts a timer, and if another call happens before the timer executes, the timer is reset and starts waiting for the desired duration again. When the timer finally does time out, the target method is invoked.


#### Throttling
Throttling is sort of the opposite of debouncing - only the first call to a method actually invokes the method, and any subsequent calls that are made within a specified duration are ignored. This can be useful to throttle presses on a refresh button for example.


## Usage

### Debouncing
Use the debouncer by calling `debounce`:

    EasyDebounce.debounce(
        'my-debouncer',                 // <-- An ID for this particular debouncer
        Duration(milliseconds: 500),    // <-- The debounce duration
        () => myMethod()                // <-- The target method
    );
    
The above call will invoke `myMethod()` after 500 ms, unless another call to `debounce()` with the same `tag` is made within 500 ms. A `tag` identifies this particular debouncer, which means you can have multiple different debouncers running concurrently and independent of each other.  

#### Cancelling a debouncer

A debouncer which hasn't yet executed its target function can be called by calling `cancel()` with the debouncers `tag`:

    EasyDebounce.cancel('my-debouncer');

To cancel all active debouncers, call `cancelAll()`:

    EasyDebounce.cancelAll();
        
    
#### Counting active debouncers

You can get the number of active debouncers (debouncers which haven't yet executed their target methods) by calling `count()`:

    print('Active debouncers: ${EasyDebounce.count()}'); 
    
    
#### Fire a debouncer target function manually

If you need to fire the target function of a debouncer before the timer executes, you can call `fire()`:

    EasyDebounce.fire('my-debouncer');
    
This will execute the debouncers target function, but the debounce timer will keep running unless you also call `cancel()`.


### Throttling
Use the throttler by calling `throttle`:

    EasyThrottle.throttle(
        'my-throttler',                 // <-- An ID for this particular throttler
        Duration(milliseconds: 500),    // <-- The throttle duration
        () => myMethod()                // <-- The target method
        onAfter: (){ ... }              // <-- Optional callback, called after the duration has passed 
    );

The above call will invoke `myMethod()` once, and any subsequent calls to `throttle()` with the same `tag` within 500 ms are ignored. A `tag` identifies this particular throttler, which means you can have multiple different throttlers running concurrently and independent of each other.

The `onAfter` callback will be invoked after the throttler is done, i.e. when the specified duration has passed and the throttler is no longer ignoring calls.

#### Cancelling a throttler

A throttler which hasn't yet executed its target function can be called by calling `cancel()` with the throttlers `tag`:

    EasyThrottle.cancel('my-throttler');

To cancel all active throttlers, call `cancelAll()`:

    EasyThrottle.cancelAll();


#### Counting active throttlers

You can get the number of active throttlers (throttlers which are still ignoring subsequent calls to their target methods) by calling `count()`:

    print('Active throttlers: ${EasyThrottle.count()}'); 


