# Alltrexx Mobile — Claude instructies

## Projectoverzicht
Alltrexx Mobile — iOS/Android mobiele app voor het Alltrexx platform.

## Eigenaar
- **Ed Cafferata** (edcafferata@icloud.com)
- **Mede-eigenaar:** Jim Orie
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

## Feature status
- [x] Project geïnitialiseerd (kopie BVK-scaffold, opgeschoond, hernoemd)
- [x] Eerste scherm: typeselectie (persoon/boot/fiets/auto/trein/vliegtuig) + sleutel aanmaken
- [ ] Scherm na typeselectie (bevestiging/status, token tonen)
- [ ] Achtergrond-locatie daadwerkelijk periodiek versturen naar `/api/mobiel/positie`
- [ ] App-icoon (nu nog BVK-icoon in Images.xcassets/AppIcon.appiconset)
- [ ] Watch-target (bewust verwijderd uit de BVK-kopie, kan later terug als gewenst)

## Open issues (backlog)
- [ ] Positie-loop bouwen (CLLocationManager + timer/significant-location-changes → AlltrexxAPI.stuurPositie)
- [ ] Naam invoerbaar maken i.p.v. automatisch UIDevice.current.name
- [ ] App-icoon vervangen
- [ ] TestFlight-indiening (fastlane staat al klaar, hergebruikt BVK's App Store Connect API-key)
