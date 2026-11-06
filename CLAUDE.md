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
- **Bundle ID:** `info.cafferata.alltrexxmobile`
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
- [x] `PrivacyInfo.xcprivacy`, ATS uit (alles HTTPS), arm64, **iPhone-only**, versie 1.0.0/1
- [x] Eigen Alltrexx-app-icoon; metadata + 11 permissie-strings van BVK → Alltrexx
- [x] App Store-screenshots (6.9", 4 schermen) in `AppStore/Screenshots/` — zie `AppStore/README.md` (#7)
- [ ] Watch-target (bewust verwijderd uit de BVK-kopie, kan later terug als gewenst)

## Open punten
Zie **`APP_STORE_READINESS.md`** (eindstand + TestFlight-afrondlijstje) en de GitHub-issues.
- **TestFlight geblokkeerd** op eenmalige Apple-setup (needs Ed, interactief/2FA): app-record bestaat nog
  niet (`APP_EXISTS=false`), bundle-id niet geregistreerd, geen `match`-profiel. Stappen in de readiness-doc.
  Code bouwt groen in Release; alleen account-/signing-setup ontbreekt.
- Open issues: #7 (screenshots ✅ gemaakt, upload wacht op app-record), #9 (App Privacy in ASC), #12 (server-delete → backend #25),
  #17 (focus-op-zelf → backend #26); backend alltrexx_live #25/#26/#27 (mobiele kant voorbereid).
- Opruimen: TEST-trackers op alltrexx.live (id 216 e.a.) — zie alltrexx_live #27.
