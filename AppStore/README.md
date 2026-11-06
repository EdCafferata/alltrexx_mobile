# App Store-screenshots — Alltrexx Mobile

_Gegenereerd 6 nov 2026 (Claude). Issue #7._

## Wat staat hier
`Screenshots/<locale>/` bevat de iPhone-screenshots voor de App Store-listing.
Er zijn er **vier**, in volgorde (het nummer-prefix bepaalt de volgorde in de listing):

| # | Bestand | Scherm | Toont |
|---|---------|--------|-------|
| 1 | `01_welkom.png`    | Onboarding      | Logo + "Welkom bij Alltrexx Mobile" + de 3 kernpunten (live delen, (bijna) real-time, privacy) + "Aan de slag" |
| 2 | `02_typekeuze.png` | Typeselectie    | "Wat wil je volgen met dit toestel?" — Persoon / Boot / Fiets / Auto / Trein / Vliegtuig |
| 3 | `03_status.png`    | Status          | "🧍 Persoon · Ed", 🟢 Tracking actief, sleutel, en de knoppen (Mijn kaart / Bekijk mij live / Instellingen / verwijderen) |
| 4 | `04_kaart.png`     | Tracking-kaart  | Topografische kaart (Persoon = OpenTopoMap + wandelroutes) met eigen positie + live windpijl (Beaufort), op de Veluwe |

## Formaat
- **1320 × 2868 px** — iPhone **6.9"** (iPhone 17 Pro Max-simulator, portret).
- Dit is de maat die Apple sinds 2024/2025 voor iPhone **vereist**. App Store Connect
  **schaalt deze set automatisch** naar de kleinere klassen (6.7"/6.5"), dus een aparte
  6.5"-set is niet nodig. (De app is iPhone-only, dus er zijn geen iPad-screenshots.)
- Schone statusbalk (09:41, vol signaal/wifi/batterij) via `simctl status_bar override`.

## Talen
Dezelfde vier screenshots staan in `nl-NL/`, `en-US/` en `de-DE/`. De app-UI is
**Nederlandstalig** (één taal), dus de screenshots zijn in alle locales gelijk — dat is
bewust. `nl-NL` is de primaire taal en dient sowieso als fallback voor locales zonder
eigen screenshots.

## Hoe ze gemaakt zijn (reproduceerbaar, géén productiedata)
Simulator-opnames met geïnjecteerde demo-state via launch-args (NSArgumentDomain), dus
**niets geschreven naar alltrexx.live**:
- Demo-token `ALLTX-9K2M4Q` is nep → de backend geeft er 403 op; er is geen tracker aangemaakt.
- Naam "Ed" en type PERSON via `-alltrexx-naam-per-type` / `-alltrexx-type`.
- Kaart: gesimuleerde locatie via `xcrun simctl location … set`.

Kort recept om opnieuw te genereren:
```bash
UDID=<iPhone 17 Pro Max udid>; BID=info.cafferata.alltrexxmobile
xcrun simctl boot "$UDID"
# build + install de .app, dan:
xcrun simctl privacy "$UDID" grant location-always "$BID"
xcrun simctl status_bar "$UDID" override --time 09:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4
# onboarding : launch zonder args
# typekeuze  : launch -alltrexx-onboarding-gezien 1
# status     : launch -alltrexx-onboarding-gezien 1 -alltrexx-token ALLTX-9K2M4Q -alltrexx-type PERSON -alltrexx-tracking-actief 1 -alltrexx-naam-per-type '{PERSON = "Ed";}'
# kaart      : idem + xcrun simctl location "$UDID" set <lat>,<lon>, tik "Mijn kaart", nieuwe fix voor autocentrering
# opnemen    : xcrun simctl io "$UDID" screenshot <bestand>.png
```

## Uploaden naar App Store Connect
De `screenshots_path` in `fastlane/Fastfile` wijst al naar `AppStore/Screenshots`.
- **Eerste indiening** (app nog niet live): de `release`-lane uploadt deze screenshots
  samen met de build (`skip_screenshots: false`, `screenshots_path`).
- De losse **`screenshots`-lane** gebruikt `edit_live: true` en werkt pas als er een
  **live** versie is — dus niet voor de allereerste submission.
- Vereist eerst de eenmalige Apple-setup (app-record + signing) uit `APP_STORE_READINESS.md`.

## Optioneel later
Apple accepteert deze "kale" toestel-screenshots prima. Wil je er marketing-frames met
bijschriften omheen (bijv. "Deel je positie live" / "Volg jezelf op de kaart"), dan kan
dat later met bijv. fastlane `frameit` of een los ontwerp — de bronopnames hierboven zijn
de basis.
