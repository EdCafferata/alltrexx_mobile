# Alltrexx Mobile 1.0.1 — iOS + eerste macOS-versie

Stand 20 nov 2026: beide versies staan op **1.0.1 / PREPARE_FOR_SUBMISSION** in App Store Connect (record 1553691366),
**20 nov 21:53 door Ed ingediend: iOS 1.0.1 + macOS 1.0.1 + 3 fooien-IAP's → WAITING_FOR_REVIEW.**

**Moet Ed doen bij het indienen:**

- [x] **iOS 1.0.1: de 3 fooien-IAP's koppelen.** App Store Connect → iOS 1.0.1 → "In-App Purchases" →
      Kleine fooi, Gemiddelde fooi en Grote fooi aanvinken vóór je indient (staan op READY_TO_SUBMIT).
      Via de API kan dit niet; de eerste consumable moet samen met een app-versie mee. Tot dan toont de app
      "Donaties zijn binnenkort beschikbaar."
- [x] **App Privacy** (geldt voor iOS én macOS, zelfde record): staat al gepubliceerd (locatie + naam, app-functionaliteit,
      niet gekoppeld, geen tracking) — alleen even nakijken.
- [x] Beide versies indienen (iOS en macOS kunnen samen in één indiening).

**Gedaan:**

- [x] App-interface vertaald (19 nov): NL/EN/DE/FR/ES via `Localizable.xcstrings`.
- [x] Versie 1.0.1 (iOS + macOS), release-notes NL/EN/DE (iOS: talen + fooien; macOS: eerste Mac-versie).
- [x] **macOS via Mac Catalyst (#22)**: zelfde bundle-ID/record, iPhone-build blijft iPhone-only
      (`TARGETED_DEVICE_FAMILY[sdk=macosx*]=2`), App Sandbox + netwerk + locatie
      (`AlltrexxMobile-macOS.entitlements`), Mac-icoonset, `LSApplicationCategoryType` = navigation,
      `NSLocationUsageDescription` (5 talen), venster 440–720 pt breed, locatie *when in use* op de Mac
      (geen achtergrondmodus/significante-locatie daar).
- [x] Mac-build geüpload (fastlane `mac_beta`, cloud-signing via Admin-key 5R3497VHF5) en gekoppeld aan macOS 1.0.1.
- [x] macOS-listing (fastlane `mac_listing`): beschrijving aangepast voor de Mac, URL's naar cafferata.info/alltrexx/,
      4 screenshots 1440×900 in NL/EN/DE (`AppStore/Screenshots-macOS/`, zonder eigen locatie in beeld).
- [x] iOS-build 1.0.1 geüpload (fastlane `beta`) + iOS-versie 1.0.1 aangemaakt met metadata.

**Nog testen (door Ed, op echte toestellen):**

- [ ] iPhone: tracking op de achtergrond, Live-kaart, fooi kopen (sandbox), "Verwijder mijn gegevens".
- [ ] Mac (TestFlight): locatietoestemming, tracking starten/stoppen, Live-kaart, fooi kopen (sandbox).

Screenshots opnieuw maken: startargumenten `-screenshot-tab <0-2>` en `-screenshot-centrum "lat,lon,z"` (Live kaart
op een vaste uitsnede i.p.v. de eigen locatie).
