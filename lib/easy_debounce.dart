library easy_debounce;

import 'dart:async';

/// A void callback, i.e. (){}, so we don't need to import e.g. `dart.ui`
/// just for the VoidCallback type definition.
typedef EasyDebounceCallback = void Function();

/// A static class for handling method call debouncing.
class EasyDebounce {
  static Map<String, Timer> _timers = {};

  /// Will delay the execution of [onExecute] with the given [duration]. If another call to
  /// debounce() with the same [tag] happens within this duration, the first call will be
  /// cancelled and the debouncer will start waiting for another [duration] before executing
  /// [onExecute].
  ///
  /// [tag] is any arbitrary String, and is used to identify this particular debounce
  /// operation in subsequent calls to [debounce()] or [cancel()].
  ///
  /// If [duration] is `Duration.zero`, [onExecute] will be executed immediately, i.e.
  /// synchronously.
  static void debounce(
      String tag, Duration duration, EasyDebounceCallback onExecute) {
    if (duration == Duration.zero) {
      _timers[tag]?.cancel();
      _timers.remove(tag);
      onExecute();
    } else {
      _timers[tag]?.cancel();

      _timers[tag] = Timer(duration, () {
        _timers[tag]?.cancel();
        _timers.remove(tag);

        onExecute();
      });
    }
  }

  /// Cancels any active debounce operation with the given [tag].
  static void cancel(String tag) {
    _timers[tag]?.cancel();
    _timers.remove(tag);
  }

  /// Returns the number of active debouncers (debouncers that haven't yet called their
  /// [onExecute] methods).
  static int count() {
    return _timers.length;
  }
}
