/*
import 'package:pwa/worker.dart';
import 'package:ya2048/pwa/offline_urls.g.dart' as offline;

/// The Progressive Web Application's entry point.
void main() {
  // The Worker handles the low-level code for initialization, fetch API
  // routing and (later) messaging.
  Worker worker = new Worker();

  // The static assets that need to be in the cache for offline mode.
  // By default it uses the automatically generated list from the output of
  // `pub build`. To refresh this list, run `pub run pwa` after each new build.
  worker.offlineUrls = offline.offlineUrls;

  // The above list is extended with additional external URLs:
  //
  List<String> offlineUrls = new List.from(offline.offlineUrls);
  offlineUrls.addAll(['https://i.creativecommons.org/l/by-sa/4.0/88x31.png']);
  worker.offlineUrls = offlineUrls;

  // Fine-tune the caching and network fetch with dynamic caches and cache
  // strategies on the url-prefixed network routes:
  //
  // DynamicCache cache = new DynamicCache('images');
  // worker.router.registerGetUrl('https://cdn.example.com/', cache.networkFirst);

  // Start the worker.
  worker.run(version: offline.lastModified);
}
*/