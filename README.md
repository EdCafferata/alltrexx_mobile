# Alltrexx Mobile

🔒 Laatste security check: 2026-08-04 23:04 CEST

Alltrexx Mobile — iOS-app voor het Alltrexx platform. Kies bij het openen wat voor
tracker dit toestel is (persoon, boot, fiets, auto, trein, vliegtuig) en volg jezelf
mee op [alltrexx.live](https://alltrexx.live).

**Status:** 🟢 werkend op fysiek toestel. Typeselectie + sleutel aanmaken, achtergrond-
locatie-tracking (throttled elke 15s), en een tabbar met drie schermen:
- **Status** — huidig type/naam, tracking starten/stoppen
- **Tracking** — eigen positie + route op de kaart, met per-categorie kaartlagen
  exact gelijk aan de website (OpenSeaMap voor boten, CyclOSM voor fietsen, OpenAIP
  luchtruim voor vliegtuigen, OpenRailwayMap voor treinen, OpenTopoMap voor wandelen)
- **Live kaart** — de volledige alltrexx.live-website ingebed

Zie `CLAUDE.md` voor de volledige feature-status en backlog (fastlane-metadata en
achtergrond-test op toestel staan nog open).

## Eigenaar
- **Ed Cafferata** (edcafferata@icloud.com)
- **Ondersteund door:** The IT Crowd

## Locatie
`/Volumes/Backup-Ed/AI/alltrexx_mobile/`

## GitHub
https://github.com/EdCafferata/alltrexx_mobile — branch: `main`

## Sessie start
1. `git pull origin main`
2. Lees `CLAUDE.md` + dit bestand

## Sessie einde
1. `git add -A && git commit && git push`
2. Werk `CLAUDE.md` bij
