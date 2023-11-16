'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "23d30769bb1ef3f9014a790b670667d1",
"favicon.ico": "0125e645bff336e7331e57a1535265f0",
"index.html": "ffee667aaf9f5a05d088963b9663e496",
"/": "ffee667aaf9f5a05d088963b9663e496",
"main.dart.js": "6bb84e2658c363075358e6b8c8b312fc",
"flutter.js": "6fef97aeca90b426343ba6c5c9dc5d4a",
"icons/Icon-192.png": "b414ac4b626eb027b4144e152849c9b4",
"manifest.json": "ca875bbc12ca2b8c7745c1c1a5e2f9f7",
"assets/AssetManifest.json": "6373123549e498ed4a9e4dc66df5b608",
"assets/NOTICES": "187a9972736d2d3927dc0d97bed1e506",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/shaders/ink_sparkle.frag": "f8b80e740d33eb157090be4e995febdf",
"assets/AssetManifest.bin": "bc74fe7b4c2a899de0d170bba0641584",
"assets/fonts/MaterialIcons-Regular.otf": "32fce58e2acb9c420eab0fe7b828b761",
"assets/assets/images/Background/Pink.png": "57b6e93f81531fca9b2ec082d0fa6469",
"assets/assets/images/Background/Green.png": "50313139bcdd8a9636df86d877d67a9e",
"assets/assets/images/Background/Door/Door.png": "16c3a47c01d3e0a67e6b4c7b6596a777",
"assets/assets/images/Marvington/Marv%2520Idle.png": "7bb19a75f42f53f730948853e1497b84",
"assets/assets/images/Marvington/Marv%2520Fall.png": "6beb7270879c9959bc7d280418e84839",
"assets/assets/images/Marvington/Disappearing%2520(96x96).png": "1284313649da02eccc0d3ed6796996a3",
"assets/assets/images/Marvington/Marv%2520Disappear.png": "1f1883e35dcd87407f4610dd25bb3707",
"assets/assets/images/Marvington/Marv%2520Enter.png": "fe068da7c433bae0aa196081c6a09df2",
"assets/assets/images/Marvington/Marv%2520Duck.png": "66b46a2e57e5115346aab79017534351",
"assets/assets/images/Marvington/Marv%2520Jump.png": "55e04e3a3c4777954ab2c8b851d5af1f",
"assets/assets/images/Marvington/Marv%2520Appear.png": "d4338549cec128b389ecba0322bed40b",
"assets/assets/images/Marvington/Marv%2520Hit.png": "1208715e8e950d8b59eec475df7b60a0",
"assets/assets/images/Marvington/Appearing%2520(96x96).png": "9449bf1f8d68ac08331aa091d6095e34",
"assets/assets/images/Marvington/Marv%2520Run.png": "3551792c2bd6019dcdec805f95ba9245",
"assets/assets/images/Marvington/Marv%2520Turned%2520Away.png": "71d9f2dc1a03a740742dcdaf2cc086f5",
"assets/assets/images/Traps/Moon/Moon%2520On.png": "e2aa0c8bbd51c86b3a1b7e03fad77218",
"assets/assets/images/Traps/Fire/Fire%2520On.png": "56fef8ae27a4a51f35fea12e99b8e50a",
"assets/assets/images/Traps/Fire/Fire%2520Off.png": "ed25d102967cfd1f9605a8b7683c6a91",
"assets/assets/images/Traps/Fire/Fire%2520Start.png": "820a1dfb8f1fba11f1534360e4478653",
"assets/assets/images/Bullet/Marv%2520Bullet%2520Vert.png": "5bcb204a615f9e0f4977800ac191757a",
"assets/assets/images/Bullet/Marv%2520Bullet.png": "b10efbc4136ea9bf93f983d9712ea09d",
"assets/assets/images/Bullet/Bullet%2520Hit.png": "48cd256e74560d0fe309084fbd36b899",
"assets/assets/images/Bullet/Marv%2520Bullet%25208x8.png": "28f516b684fbfd55ff4b03386e7969a8",
"assets/assets/images/Terrain/Rock.png": "135b9b97be7750e516f194bf4b9730c5",
"assets/assets/images/Terrain/Rock%2520Break.png": "74e48f0006e768eecd38e973d08b4678",
"assets/assets/images/Terrain/Marvington%2520Terrain.png": "eaa92989244c27743ec8a237ff22f35e",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(No%2520Flag).png": "9126203dc833ec3b7dfb7a05e41910e5",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(Flag%2520Idle)(64x64).png": "dd8752c20a0f69ab173f1ead16044462",
"assets/assets/images/Items/Checkpoints/Checkpoint/Checkpoint%2520(Flag%2520Out)(64x64).png": "c4730e5429a75691e2d2a9351c76738e",
"assets/assets/images/Items/Shitake/Collected.png": "90467641be81753492aff4c785247093",
"assets/assets/images/Items/Shitake/Shitake.png": "045c6aea2f8c2d5daf4268083a1011ff",
"assets/assets/images/Enemies/Radish/Leafs.png": "c3837aabb9f5b565e3cd1e38c6e29915",
"assets/assets/images/Enemies/Radish/Idle%25202%2520(30x38).png": "d54d96d8a428f9ea22c7509217d12cd0",
"assets/assets/images/Enemies/Radish/Idle%25201%2520(30x38).png": "fca6305299182c58f920ddb54a5b7f53",
"assets/assets/images/Enemies/Radish/Hit%2520(30x38).png": "5adc10c5b89f2642a4c10a0da0b1c90b",
"assets/assets/images/Enemies/Radish/Run%2520(30x38).png": "d0d3ff59320e7c9ea44dcead669dddfd",
"assets/assets/images/Enemies/Blob/Flying%2520Blob%2520Run.png": "9f3e1765ad99baff2aa9b99d03293d5b",
"assets/assets/images/Enemies/Blob/Flying%2520Blob%2520Hit.png": "c3b5e3309dbda9e17e6c8629d424f8fa",
"assets/assets/images/Enemies/Blob/Blob%2520Hit.png": "8e2c1757743a275e6df20c9215edc8fd",
"assets/assets/images/Enemies/Blob/Blob%2520Run.png": "565d986ba0b9c04ee7557ffd2e1879e6",
"assets/assets/tiles/Blue%2520World%2520Two.tmx": "bbfa567bd823365ee3eda89bcd9ff48f",
"assets/assets/tiles/Blue%2520World%2520Three.tmx": "c234bbb7f63a619f8da1505f49d17bc6",
"assets/assets/tiles/Marvington%2520Game.tiled-project": "97165873765b29a5041f09e541be15d5",
"assets/assets/tiles/Marvington%2520Game.tiled-session": "4e7c5539e999f14790b8f80e4df883ee",
"assets/assets/tiles/Marvington%2520Terrain.tsx": "cf01277c580f637118295c6b914f7d4c",
"assets/assets/tiles/Blue%2520World%2520One.tmx": "068c833ee8ba8fd780f9e01af108630d",
"assets/assets/tiles/Blue%2520World%2520Four.tmx": "03b23ce58a651dfd222efbd07cf8b4c7",
"assets/assets/audio/synth3.wav": "bf9293422ec1ab6b8977cf864567f70c",
"assets/assets/audio/hitHurt.wav": "24a1fbc08229bed9970f9d21d87f545f",
"assets/assets/audio/landOnEnemy.wav": "4d762eec4badc5038860909a161a6e11",
"assets/assets/audio/explosion.wav": "db20c491b40cf9bbd2864ad4fbbc0a04",
"assets/assets/audio/jump1.wav": "35d77892853e523af115f13bbe607969",
"assets/assets/audio/pickupCoin1.wav": "29b594c210b357494183b68f915df7a8",
"canvaskit/skwasm.js": "95f16c6690f955a45b2317496983dbe9",
"canvaskit/skwasm.wasm": "1a074e8452fe5e0d02b112e22cdcf455",
"canvaskit/chromium/canvaskit.js": "96ae916cd2d1b7320fff853ee22aebb0",
"canvaskit/chromium/canvaskit.wasm": "be0e3b33510f5b7b0cc76cc4d3e50048",
"canvaskit/canvaskit.js": "bbf39143dfd758d8d847453b120c8ebb",
"canvaskit/canvaskit.wasm": "42df12e09ecc0d5a4a34a69d7ee44314",
"canvaskit/skwasm.worker.js": "51253d3321b11ddb8d73fa8aa87d3b15"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
