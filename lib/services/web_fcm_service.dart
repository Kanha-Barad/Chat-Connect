import 'dart:html' as html;

Future<void> registerServiceWorker() async {
  await html.window.navigator.serviceWorker
      ?.register('firebase-messaging-sw.js');
}
