# Alltrexx Mobile — App Store-gereedheid & status

_Bijgewerkt 5 nov 2026 (Claude, autonome sessie). Doel van de app: de positie van
dit toestel (bijna) live doorsturen naar **alltrexx.live** en jezelf daar terugzien._

## Stand van zaken
De app is **functioneel compleet, gebouwd en geverifieerd**, en op `main` gecommit + gepusht.
Alle code-issues zijn opgelost. De **TestFlight-upload is geblokkeerd** op eenmalige
Apple-account-setup die jouw interactieve login (2FA) vereist — zie de checklist onderaan.

- ✅ Debug-simulatorbuild groen (exit 0)
- ✅ Release-build voor device (arm64, Release-config) groen (exit 0)
- ✅ Hele UI-flow in de simulator doorlopen (onboarding → typeselectie → status → instellingen → verwijderen → Live kaart → Tracking-kaart)
- ✅ Live backend-pijplijn geverifieerd tegen alltrexx.live: `POST /api/sleutel/gratis` → token (HTTP 200), `POST /api/mobiel/positie` **mét hoogte** (HTTP 200), ongeldig token → **HTTP 403**

## Wat deze sessie is gedaan (afgerond + gecommit)
| # | Onderwerp | Commit |
|---|---|---|
| #10 | ATS: `NSAllowsArbitraryLoads` weg (alles HTTPS) | 5402a36 |
| #11 | `armv7` → `arm64` | 5402a36 |
| #8 | `PrivacyInfo.xcprivacy` (precieze locatie = app-functionaliteit, geen tracking; UserDefaults CA92.1) | 5402a36 |
| #21 | Besluit **iPhone-only** (device family 1,2 → 1); versie-restant BVK 2.1.1/4 → 1.0.0/1 | 5402a36 |
| #13 | Posities (bijna) real-time doorsturen (gedebounced) i.p.v. elke 15 min + offline-inhaal | 059d715 |
| #14 | Snelheidsafhankelijk energie-/batterijprofiel | 059d715 |
| #15 | Achtergrond-herstart via significante-locatiewijzigingen + auto-hervatten | 059d715 |
| #19 | Hoogte meesturen + HTTP 403 (geweigerd token) apart afgehandeld | 059d715 |
| #16 | Rijker statusscherm (live status, laatste positie, wachtrij, snelheid) | 8179f39 |
| #17 | Knop 'Bekijk mij live' + 'Mijn kaart' (focus-op-zelf wacht op backend #26) | 8179f39 |
| #18 | Eenmalige onboarding + locatie-priming | 8179f39 |
| #12 | 'Verwijder mijn gegevens' (lokaal wissen; server-delete wacht op backend #25) | 8179f39 |
| #20 | Instellingen-scherm voor optionele OWM/OpenAIP-kaartsleutels | 8179f39 |
| #6 | Metadata BVK Tracker → Alltrexx Mobile (naam/subtitle/keywords/beschrijving/promo/notes/URLs, en-US/nl-NL/de-DE) | 88e09e4 |
| — | **11 gelokaliseerde `InfoPlist.strings`** (locatie-permissieteksten) OpenBVKTracker → Alltrexx (gevonden tijdens simulator-test) | 4865b94 |

## Nog open (bewust, met reden)
- **#7 screenshots** — ✅ **gemaakt** (6 nov): 4 formele screenshots op **6.9"** (1320×2868, iPhone 17 Pro Max) in `AppStore/Screenshots/{nl-NL,en-US,de-DE}/` — onboarding, typekeuze, status (tracking actief) en de tracking-kaart met live windpijl. 6.9" is de door Apple vereiste maat; ASC schaalt die automatisch naar 6.5"/6.7". Zie `AppStore/README.md`. Alleen het **uploaden** wacht nog op de app-record (`release`-lane uploadt ze mee met de build).
- **#9 App Privacy in ASC** — het xcprivacy-manifest is klaar; de App Privacy-'nutrition label' in App Store Connect moet dit nog spiegelen (Precieze locatie = App-functionaliteit, gekoppeld aan identiteit, niet voor tracking). Handmatige ASC-stap.
- **#12 server-delete** — lokaal wissen werkt; volledige server-side verwijdering vereist backend **alltrexx_live #25** (nodig voor richtlijn 5.1.1(v) vóór store-submission).
- **#17 focus-op-zelf** — knop opent de live kaart; direct inzoomen op de eigen tracker vereist backend **alltrexx_live #26** (tracker-id wordt al lokaal bewaard).
- Backend **alltrexx_live #25/#26/#27** — mobiele kant is voorbereid; endpoints nog te bouwen + deployen.
- **Fooienpot (in-app aankopen)** — Instellingen heeft nu een fooienpot (3 consumables) + een
  "Beoordeel"-knop + een "Neerslag tonen"-schakelaar. De **3 IAP-producten moeten nog in App Store
  Connect** worden aangemaakt (onder hetzelfde app-record) met exact deze product-ID's, anders toont
  het scherm "Donaties zijn binnenkort beschikbaar":
  `info.cafferata.alltrexx.tip.klein` (€0,99), `…tip.gemiddeld` (€2,99), `…tip.groot` (€5,99) — alle **Consumable**.
  Lokaal testen in Xcode kan meteen via `Fooien.storekit` (al in de scheme gekoppeld). De review-knop
  gebruikt nu een directe "schrijf een recensie"-link (`Fooienpot.appStoreId = 1553691366`).

## TestFlight — bestaand app-record hergebruikt (6 nov 2026)
Het app-record bestond al: **"AllTreXX for all your tracks"**, **app-id 1553691366**,
bundle-id **`info.cafferata.alltrexx`** (SKU gelijk, primaire taal NL). Er stond al een
**iOS 1.0-versie in "Prepare for Submission"** klaar (0 builds, 4+). Daarom is de app
omgezet van `info.cafferata.alltrexxmobile` → **`info.cafferata.alltrexx`** (pbxproj,
Fastfile, Appfile, tip-product-ID's, Fooien.storekit). Het "app-record aanmaken" is dus
**niet meer nodig** — die blokkade is weg.

**Nog te doen vóór upload:**
1. **Signing/profiel** voor `info.cafferata.alltrexx`: `fastlane match appstore` (certs-repo) zodat
   het profiel `match AppStore info.cafferata.alltrexx` bestaat — de `beta`-lane verwacht die naam.
   (De App ID staat al geregistreerd in het Developer-portal, want het record bestaat.)
2. **Controleer de overeenkomsten** in ASC (Agreements, Tax, and Banking) — moeten geaccepteerd zijn.
3. **Upload:** `fastlane beta` (increment build → build_app → upload_to_testflight, API-key G389F99P3B)
   → komt binnen op de iOS-versie van record 1553691366. Code bouwt groen in Release.
4. (Record is universeel: er is ook een ongebruikte macOS 1.0-slot — die blijft gewoon staan, niet indienen.)

## Testdata om op te ruimen (server-side)
Tijdens de live-verificatie zijn gratis TEST-trackers aangemaakt op alltrexx.live:
**id 216** ('TEST-Claude-verwijderen', PERSON, één testpositie ~52.4/5.4) + 'TEST-Claude-verwijderen2'.
Graag server-side verwijderen (er is nog geen app/CLI-manier — zie alltrexx_live #25). Genoteerd in alltrexx_live #27.
