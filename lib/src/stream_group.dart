import 'dart:async';

class StreamGroup<T> {
  StreamGroup(this.streams);

  final List<Stream<T>> streams;

  Stream<void> merge() {
    final controller = StreamController<void>.broadcast();

    final subscriptions = <StreamSubscription<void>>[];

    for (final stream in streams) {
      final subscription = stream.listen((event) {
        controller.add(event);
      });

      subscriptions.add(subscription);
    }

    controller.onCancel = () {
      for (final subscription in subscriptions) {
        subscription.cancel();
      }
    };

    return controller.stream;
  }
}
