fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build en upload naar TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Build, upload naar App Store en dien in ter beoordeling

### ios screenshots

```sh
[bundle exec] fastlane ios screenshots
```

Upload screenshots naar App Store Connect

### ios metadata

```sh
[bundle exec] fastlane ios metadata
```

Upload beschrijving en release notes naar App Store Connect

### ios promo

```sh
[bundle exec] fastlane ios promo
```

Update promotional tekst op de live versie

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
