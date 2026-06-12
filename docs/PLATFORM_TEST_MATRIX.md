# Pixel Fruit Arena Platform Test Matrix

Generated from implementation inspection on 2026-06-12. Hardware/browser execution is marked unverified where it was not run on the physical target.

| Feature | Windows PC | macOS | Web Browser | Steam Deck | RGDS Android | RGDS Linux |
| --- | --- | --- | --- | --- | --- | --- |
| Static launch | PASS via browser | PASS via browser | PASS | PASS expected via browser, unverified | PASS expected via browser, unverified | UNVERIFIED browser path |
| Native package | MISSING | MISSING | N/A | MISSING | MISSING APK | MISSING |
| HTML5 Canvas gameplay | PASS expected | PASS expected | PASS by implementation | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Character profile save | PASS via localStorage | PASS via localStorage | PASS | PASS expected | PASS expected | UNVERIFIED |
| Fruit abilities | PASS by implementation | PASS by implementation | PASS by implementation | PASS expected | PASS expected | PASS expected if browser runs |
| Cooldowns/damage/awakening/mastery | PASS by implementation | PASS by implementation | PASS by implementation | PASS expected | PASS expected | PASS expected if browser runs |
| Stocks/ring-outs/respawn | PASS by implementation | PASS by implementation | PASS by implementation | PASS expected | PASS expected | PASS expected if browser runs |
| 2P keyboard | PASS expected | PASS expected | PASS by implementation | LIMITED | LIMITED | LIMITED |
| 3P/4P local match setup | PASS by implementation | PASS by implementation | PASS by implementation | PASS expected with controllers/CPU | PASS expected with controllers/CPU | UNVERIFIED |
| Gamepad API | PASS expected in modern browser | PASS expected in modern browser | PASS by implementation | UNVERIFIED hardware | UNVERIFIED hardware/browser | UNVERIFIED hardware/browser |
| Multiple controllers | PASS by implementation, unverified hardware | PASS by implementation, unverified hardware | PASS by implementation | UNVERIFIED | UNVERIFIED | UNVERIFIED |
| Controller rebinding | MISSING | MISSING | MISSING | MISSING | MISSING | MISSING |
| Controller-first menu | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL |
| PWA manifest | PASS | PASS | PASS | PASS expected | PASS expected | PASS expected if browser supports |
| Offline service worker | PASS after served load | PASS after served load | PASS after served load | PASS expected | PASS expected | UNVERIFIED |
| Install prompt | Browser-dependent | Browser-dependent | Browser-dependent | Browser-dependent | Browser-dependent | Browser-dependent |
| Screen mode control | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL | PARTIAL |
| 720p scaling | PASS CSS | PASS CSS | PASS CSS | PASS expected | PASS expected | PASS expected if browser runs |
| 720x720 scaling | PASS CSS | PASS CSS | PASS CSS | PASS expected | PASS expected | PASS expected if browser runs |
| 1280x720 scaling | PASS CSS | PASS CSS | PASS CSS | PASS expected | PASS expected | PASS expected if browser runs |
| Touch controls | MISSING | MISSING | MISSING | MISSING | MISSING | MISSING |

## Notes

* PASS by implementation means source code directly implements the feature.
* PASS expected means the web implementation should work on the platform through a modern browser, but no physical device run was available in this environment.
* RGDS Linux remains the weakest target because there is no native package or verified browser/controller stack.
