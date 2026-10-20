---
name: pre-production-app-review-check
description: Pre-productie App Store / Google Play review-check — 1x draaien vlak vóór het op productie zetten van een nieuwe versie van DEZE app
---

Draai deze routine **1× handmatig, vlak vóór** je een nieuwe versie van **de app in deze repo** naar productie
stuurt (App Store / Google Play). Doel: voorkomen dat de release wordt afgekeurd of iets vergeten wordt.
Ontstaan uit Apples mail "Updated App Review Guidelines are now available" (okt 2026). Advies-routine: dien niet
zelf in; geef een GO/NO-GO. Verzin niets — wat je niet kunt verifiëren, zet je als handmatige check voor Ed.

> Er is ook een globale, identieke scheduled-task (`~/.claude/scheduled-tasks/pre-production-app-review-check`)
> en een 3-maandelijkse Guidelines-versiecheck (`apple-guidelines-quarterly-check`).

## 0. Welke app/platform?
De app = **deze repo** (leid naam/bundle-id/platform af uit de projectbestanden: `*.xcodeproj`/Info.plist voor iOS,
`build.gradle`/`AndroidManifest.xml` + `applicationId` voor Android). Twijfel je? Vraag het Ed.
ASC-API (iOS): KeyID G389F99P3B, issuer 69a6de7f-a9c3-47e3-e053-5b8c7c11a4d1,
key `~/.appstoreconnect/private_keys/AuthKey_G389F99P3B.p8`; app-id's via `/v1/apps`.

## 1. Actuele Guidelines + wijzigingen
Haal `https://developer.apple.com/app-store/review/guidelines/` op, lees de **"Last Updated"**-datum en vergelijk
met de baseline in `~/.claude/scheduled-tasks/apple-guidelines-quarterly-check/state.json`. Noem kort of er sinds de
vorige release iets nieuws is dat deze app raakt (o.a. 1.2 veiligheid/UGC, 2.3.14 creative assets, 2.5.19 verborgen/
dormant features, 3.1.1 in-app aankopen, 5.1.1 account/Sign in with Apple/account-verwijdering, 4.x design).
Voor Android: loop de Google Play-policies + het data-safety-formulier na.

## 2. Automatiseerbare checks — rapporteer ✅/⚠️/❌
**iOS (ASC-API):** metadata compleet per locale (naam/subtitle/beschrijving/keywords/promo, geen placeholder/"beta"/
"coming soon"); screenshots voor de vereiste formaten; privacybeleid-URL gezet én live 200 (→ `cafferata.info/<slug>/privacy.html`);
support-/marketing-URL idem (`/<slug>/support.html`, `/<slug>/`); App-Privacy-label in lijn met wat de app écht verzamelt;
export-compliance `ITSAppUsesNonExemptEncryption=NO`; leeftijdsclassificatie; build aanwezig + `VALID`; versienummer hoger
dan live; release-notes per locale.
**Android:** Play-listing compleet; data-safety-formulier klopt; privacybeleid-URL live; versionCode hoger; nieuwe AAB
getekend (signing uit `~/.gradle/gradle.properties`, LOKAAL bouwen — zie [[reference_android_release_workflow]]).

## 3. Handmatige punten (GO/▲/NO-GO per punt)
- **Crasht niet**: getest op een echt toestel (niet alleen simulator/emulator) — echte launch + kernflows.
- **Permissies**: elke gebruikte permissie heeft een duidelijke usage-omschrijving (`NS...UsageDescription` / Play-permissies).
- **Sign in with Apple** vereist als er ook een andere sociale login is (5.1.1); bij account-aanmaak moet
  **account-verwijdering in de app** zitten (5.1.1(v)).
- **In-app aankopen**: digitale content via StoreKit / Play Billing; "herstel aankopen"; geen externe betaallink voor digitale goederen.
- **Geen verborgen/dormant features** (2.5.19); niets dat reviewers niet kunnen bereiken.
- **Reviewer-toegang**: bij login een demo-account of duidelijke review-notes. (og-consent: de master-activatie-gate —
  geef de reviewer een werkende route; zie `docs/MASTER-ACTIVATIE-SETUP.md` in de oc-consent-repo.)
- **Links & content** werken; geen kapotte links of placeholder-schermen.
- **Laatste SDK**: gebouwd met de huidige vereiste Xcode/iOS-SDK (iOS) resp. target-SDK (Android).

## 4. Rapport
Beknopt **GO / NO-GO**-overzicht met per punt de status en concrete acties voor de ⚠️/❌-punten.
