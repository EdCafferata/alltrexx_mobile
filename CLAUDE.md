# Alltrexx Mobile — Claude instructies

## Projectoverzicht
Alltrexx Mobile — iOS/Android mobiele app voor het Alltrexx platform.

## Eigenaar
- **Ed Cafferata** (edcafferata@icloud.com)
- **Team ID:** `9J2S23WJH3`

## Locatie & build
- **Project:** `/Volumes/Backup-Ed/AI/alltrexx_mobile/`
- **GitHub:** https://github.com/EdCafferata/alltrexx_mobile — branch: `main`

## Sessie start (ALTIJD uitvoeren)
1. `git -C /Volumes/Backup-Ed/AI/alltrexx_mobile pull origin main`
2. Lees dit bestand + `README.md`
3. Meld wat er nieuw is t.o.v. vorige sessie

## Sessie einde (ALTIJD uitvoeren)
1. `git add -A && git commit && git push`
2. Werk `CLAUDE.md` bij indien nodig
3. Update memory indien van toepassing

## Stack
- **iOS, UIKit** (geen storyboard-entrypoint, volledig programmatisch) — gestart als kopie
  van de scaffold van BVK-GpxTracker (project/signing/fastlane-infra), daarna alle
  GPX/kaart-specifieke code verwijderd en vervangen door nieuwe, kleine bestanden.
- **Bundle ID:** `info.cafferata.alltrexx` (hergebruikt bestaand ASC-record "AllTreXX for all your tracks", app-id 1553691366 — iOS-versie 1.0 stond al klaar in "Prepare for Submission")
- **Project:** `AlltrexxMobile.xcodeproj`, scheme `AlltrexxMobile`
- **Minimum iOS:** 16.0 (bewust verhoogd van de 12.0 die BVK nog had — nieuwe app, geen
  reden om oude toestellen te ondersteunen)
- **Backend:** alltrexx.live — `POST /api/sleutel/gratis` {naam, type} → token,
  `POST /api/mobiel/positie` {token, lat, lon, snelheid?, koers?} (beide al gebouwd
  in alltrexx_live, zie project_alltrexx_live-geheugen)

## Kernbestanden
| Bestand | Inhoud |
|---|---|
| `TrackerType.swift` | Enum met de 6 typen (persoon/boot/fiets/auto/trein/vliegtuig), label + emoji — zelfde set als de webkaart |
| `AlltrexxAPI.swift` | Netwerkclient: `maakSleutel` (sleutel/gratis) + `stuurPositie` (mobiel/positie) |
| `TrackerOpslag.swift` | UserDefaults-wrapper voor het bewaarde token + gekozen type |
| `TypeSelectieViewController.swift` | **Eerste scherm** — kies je type, maakt een sleutel aan en bewaart 'm lokaal |
| `AppDelegate.swift` | Minimale programmatische opstart (geen storyboard) |

## Feature status (bijgewerkt 5 nov 2026)
App is **functioneel compleet** en geverifieerd (Debug-sim + Release-device bouwen groen;
hele UI-flow simulator-getest; live backend-pijplijn getest tegen alltrexx.live).
- [x] Onboarding (eenmalig) → typeselectie (met naam-invoer) → status / Tracking-kaart / Live kaart (3 tabs)
- [x] Gratis sleutel aanmaken + lokaal bewaren (token + tracker-id + type)
- [x] Achtergrond-locatie **(bijna) real-time** naar `/api/mobiel/positie`, met offline-wachtrij + inhaal
- [x] Snelheidsafhankelijk batterijprofiel; significante-locatiewijzigingen voor relaunch
- [x] Hoogte meesturen + HTTP 403 (geweigerd token) afgehandeld
- [x] Rijker statusscherm (live) + 'Bekijk mij live' + 'Verwijder mijn gegevens' + Instellingen (kaartsleutels)
- [x] Instellingen uitgebreid: 'Neerslag tonen'-schakelaar, fooienpot (StoreKit, 3 consumables) + 'Beoordeel'-knop (6 nov)
- [x] `PrivacyInfo.xcprivacy`, ATS uit (alles HTTPS), arm64, **iPhone-only**, versie 1.0.0/1
- [x] Eigen Alltrexx-app-icoon; metadata + 11 permissie-strings van BVK → Alltrexx
- [x] App Store-screenshots (6.9", 4 schermen) in `AppStore/Screenshots/` — zie `AppStore/README.md` (#7)
- [ ] Watch-target (bewust verwijderd uit de BVK-kopie, kan later terug als gewenst)

## Open punten
Zie **`APP_STORE_READINESS.md`** (eindstand + TestFlight-afrondlijstje) en de GitHub-issues.
- **iOS 1.0 LIVE in de App Store sinds 10 nov 2026** ("Ready for Distribution" 22:31; ASC appStoreState READY_FOR_SALE,
  record 1553691366, versie-id 6391b92d; https://apps.apple.com/nl/app/alltrexx-mobile/id1553691366). #7/#9/#12 daarmee gesloten.
  ⚠️ Het record heeft ook een lege macOS-1.0-slot (a1574abc, PREPARE_FOR_SUBMISSION) → #22.
- Open issues: #22 (macOS-versie), #17 (focus-op-zelf → backend #26), #26 (nieuw logo), #5 (site-info), #4 (rate-the-app),
  #1–#3 (oudere wensen). Nog open in ASC: IAP-fooienproducten aanmaken.
- Opruimen: TEST-trackers op alltrexx.live (id 216 e.a.) — zie alltrexx_live #27.
