# Categorie-showcasekaarten

_Gegenereerd 6 nov 2026 (Claude). Eén tracking-kaart per tracker-type, elk met de
kaartstijl die bij die categorie hoort (zelfde presets als de alltrexx.live-webkaart)._

| Bestand | Type | Locatie | Kaartstijl |
|---|---|---|---|
| `1_voetganger.png` | 🧍 Persoon   | Veluwe            | OpenTopoMap + wandelroutes (Waymarked Trails) |
| `2_boot.png`       | ⛵ Boot      | Volendam (Markermeer) | Gewone kaart + vaarwegmarkeringen (OpenSeaMap) |
| `3_fiets.png`      | 🚴 Fiets     | Houten            | CyclOSM + fietsroutes (Waymarked Trails) |
| `4_auto.png`       | 🚗 Auto      | Knooppunt Oudenrijn | Gewone kaart (Apple) |
| `5_trein.png`      | 🚆 Trein     | Utrecht Centraal  | Gedempte kaart + spoorwegen (OpenRailwayMap) |
| `6_vliegtuig.png`  | ✈️ Vliegtuig | Schiphol          | Gedempte kaart (+ luchtvaartlaag OpenAIP met sleutel) |

Elke kaart toont de eigen positie met de live **windpijl** (Beaufort + knopen, via Open-Meteo).

**Formaat:** 1320 × 2868 px (iPhone 6.9"), schone 09:41-statusbalk, gesimuleerde locaties,
geen productiedata (demo-token → 403).

## Bruikbaar voor
- Keuze-materiaal voor de App Store-listing (je kunt één of meer hiervan in de
  hoofdset `../Screenshots/` zetten naast onboarding/typekeuze/status).
- Marketing/website (cafferata.info/alltrexx) om te laten zien dat de kaart zich
  aanpast aan wat je volgt.

## Let op (fix in deze commit)
De lichte ondergrond voor **Vliegtuig** en **Trein** kwam van CARTO
(`basemaps.cartocdn.com/light_all`). CARTO vereist nu een API-sleutel en gaf
"API KEY REQUIRED"-watermerktegels in de app. Opgelost door Apple's eigen
`MKMapType.mutedStandard` te gebruiken — geen sleutel, geen externe afhankelijkheid.
Deze screenshots tonen de gefixte situatie.

> Voor **Vliegtuig** is de OpenAIP-luchtvaartlaag (luchtruim/vliegvelden) niet zichtbaar
> omdat er geen OpenAIP-sleutel is ingesteld; met een sleutel (Instellingen) komt die
> laag er bovenop. De gedempte Schiphol-kaart staat er nu wel netjes onder.
