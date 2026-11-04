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
- **#7 screenshots** — preview-captures gemaakt in de simulator; formele App Store-screenshots (6.9"/6.5", evt. met captions) nog te maken/kiezen.
- **#9 App Privacy in ASC** — het xcprivacy-manifest is klaar; de App Privacy-'nutrition label' in App Store Connect moet dit nog spiegelen (Precieze locatie = App-functionaliteit, gekoppeld aan identiteit, niet voor tracking). Handmatige ASC-stap.
- **#12 server-delete** — lokaal wissen werkt; volledige server-side verwijdering vereist backend **alltrexx_live #25** (nodig voor richtlijn 5.1.1(v) vóór store-submission).
- **#17 focus-op-zelf** — knop opent de live kaart; direct inzoomen op de eigen tracker vereist backend **alltrexx_live #26** (tracker-id wordt al lokaal bewaard).
- Backend **alltrexx_live #25/#26/#27** — mobiele kant is voorbereid; endpoints nog te bouwen + deployen.

## TestFlight — waarom geblokkeerd + jouw afrondlijstje
De bundle-id `info.cafferata.alltrexxmobile` is **nieuw**: geen app-record in App Store Connect
(`APP_EXISTS=false`), bundle-id nog niet geregistreerd (`BUNDLE_ID_REGISTERED=false`), en geen
`match`-profiel. De App Store Connect **API kan geen nieuwe app aanmaken** — dat eerste-keer-aanmaken
vereist Apple-ID-login met 2FA of de ASC-website. Daarom kon ik de upload niet solo afmaken zonder
jouw account-handelingen te forceren (ik heb niets op je account aangemaakt).

**Afronden (± 10 min, daarna upload):**
1. **App-record aanmaken** in App Store Connect → My Apps → **+** → New App: platform iOS, bundle-id `info.cafferata.alltrexxmobile`, naam **Alltrexx Mobile**, primaire taal Nederlands, SKU naar keuze. (Of `fastlane produce` met Apple-ID-login + 2FA.)
2. **Controleer de overeenkomsten** in ASC (Agreements, Tax, and Banking) — er was eerder een licentie-/overeenkomst-blokkade; die moet geaccepteerd zijn, anders faalt de upload.
3. **Signing/profiel** voor de nieuwe bundle-id: `fastlane match appstore` (jouw certs-repo) zodat het profiel `match AppStore info.cafferata.alltrexxmobile` bestaat — de `beta`-lane verwacht die naam.
4. **Upload:** `fastlane beta` (increment build → build_app → upload_to_testflight met API-key G389F99P3B). De code bouwt groen in Release; alleen de account-/signing-setup ontbrak.

## Testdata om op te ruimen (server-side)
Tijdens de live-verificatie zijn gratis TEST-trackers aangemaakt op alltrexx.live:
**id 216** ('TEST-Claude-verwijderen', PERSON, één testpositie ~52.4/5.4) + 'TEST-Claude-verwijderen2'.
Graag server-side verwijderen (er is nog geen app/CLI-manier — zie alltrexx_live #25). Genoteerd in alltrexx_live #27.
