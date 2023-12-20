library easy_debounce;

import 'dart:async';

typedef EasyRateLimitCallback = void Function();

class _EasyRateLimitOperation {
  EasyRateLimitCallback? callback;
  EasyRateLimitCallback? onAfter;

  Timer timer;

  _EasyRateLimitOperation(
    this.timer,
  );
}

class EasyRateLimit {
  static Map<String, _EasyRateLimitOperation> _operations = {};

  /// Will execute [onExecute] immediately and record additional attempts to
  /// call rateLimit with the same [tag] happens until the given [duration] has passed
  /// when it will execute with the last attempt.
  ///
  /// [tag] is any arbitrary String, and is used to identify this particular rate limited
  /// operation in subsequent calls to [rateLimit()] or [cancel()].
  ///
  /// [duration] is the amount of time until the subsequent attempts will be sent.
  ///
  /// [onAfter] is executed after the [duration] has passed in which there were no rate limited calls.
  ///
  /// Returns whether the operation was rate limited
  static bool rateLimit(
    String tag,
    Duration duration,
    EasyRateLimitCallback onExecute, {
    EasyRateLimitCallback? onAfter,
  }) {
    final rateLimited = _operations.containsKey(tag);
    if (rateLimited) {
      _operations[tag]?.callback = onExecute;
      _operations[tag]?.onAfter = onAfter;
      return true;
    }

    final operation = _EasyRateLimitOperation(
      Timer.periodic(duration, (Timer timer) {
        final operation = _operations[tag];

        if (operation != null) {
          if (operation.callback == null) {
            operation.timer.cancel();
            _operations.remove(tag);
            onAfter?.call();
          } else {
            operation.callback?.call();
            operation.onAfter?.call();
            operation.callback = null;
            operation.onAfter = null;
          }
        }
      }),
    );

    _operations[tag] = operation;

    onExecute();

    return false;
  }

  /// Cancels any active rate limiter with the given [tag].
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// Cancels all active rate limiters.
  static void cancelAll() {
    for (final operation in _operations.values) {
      operation.timer.cancel();
    }
    _operations.clear();
  }

  /// Returns the number of active rate limiters
  static int count() {
    return _operations.length;
  }
}
