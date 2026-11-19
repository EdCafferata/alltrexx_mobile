# Alltrexx Mobile iOS 1.0.1 — niet vergeten (uit de pre-release-check van 19 nov 2026)

**Moet mee, anders blijft de fooienpot leeg:**

- [ ] **De 3 fooien-IAP's aan de versie koppelen.** In App Store Connect → versie 1.0.1 → "In-App Purchases" →
      Kleine fooi, Gemiddelde fooi en Grote fooi aanvinken vóór je indient. Ze staan op READY_TO_SUBMIT.
      Los indienen kan niet (Apple: de eerste consumable moet samen met een app-versie mee) en via de API
      koppelen kan ook niet. Tot dan toont de live app "Donaties zijn binnenkort beschikbaar."

**Verbeterpunten:**

- [x] **App-interface vertaald** (19 nov): alle ~70 UI-teksten via `String(localized:)` + `Localizable.xcstrings`
      in NL/EN/DE/FR/ES; in de simulator gecontroleerd (DE/FR). Optioneel: store-listing ook in FR/ES toevoegen.
- [ ] Versie + build ophogen (`MARKETING_VERSION` 1.0.1) en release-notes invullen (nl/en/de).
- [ ] Testen op een echt toestel: tracking op de achtergrond, Live-kaart, fooi kopen (sandbox), "Verwijder mijn gegevens".
- [ ] Pre-release-check draaien (skill `pre-release-app-review`) vóór indienen.

**macOS-versie (#22):** er staat een macOS 1.0-versie op PREPARE_FOR_SUBMISSION met verouderde metadata
(beschrijving van 86 tekens, support-/marketing-URL `alltrexx.live` in plaats van `cafferata.info/alltrexx/`,
alleen nl-NL, geen build). Bijwerken zodra de Mac-build er is.
