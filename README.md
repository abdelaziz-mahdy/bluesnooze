![Bluesnooze logo](images/icon.png)

# Bluesnooze

[Download the latest release][download-latest] or install via Homebrew:

```sh
brew install bluesnooze
```

Please note the latest release requires MacOS Monterey (12.0) or higher.

## Enjoying Bluesnooze? ❤️

Perhaps you could [buy me a coffee](https://www.buymeacoffee.com/odlp) to say thanks :coffee:

## About

**Bluesnooze prevents your sleeping Mac from connecting to Bluetooth accessories.**

If you pair Bluetooth headphones or speakers with both your phone & Mac it can be frustrating when your sleeping Mac connects intermittently and disrupts the audio.

With Bluesnooze the Bluetooth connection is switched off when your Mac sleeps, and switched on when your Mac wakes.

![Screenshot showing Bluesnooze in the status bar](images/screenshot.png)

You might also want to check-out Whisper – [the volume limiter for MacOS](https://apps.apple.com/gb/app/whisper-volume-limiter/id1438132944?mt=12).

## Installation

1. Download `Bluesnooze.zip` from the [latest release][download-latest]
1. In Finder, open `Bluesnooze.zip` in your `Downloads` directory
1. Drag `Bluesnooze.app` to your `Applications` directory
1. _Optional_: Configure 'Launch at login'

## Building from Source

If you want to build Bluesnooze from source, you can use the provided build script:

### Prerequisites

- Xcode command line tools: `xcode-select --install`
- Carthage: `brew install carthage`
- SwiftLint (optional): `brew install swiftlint`

### Building

```sh
# Basic build (auto-detects code signing)
./build.sh

# Clean build with dependencies
./build.sh --clean

# Development build without code signing
./build.sh --skip-codesign

# Debug build
./build.sh --debug

# Build and open the result
./build.sh --clean --open

# Show all options
./build.sh --help
```

The built application will be available in `build/export/Bluesnooze.app`.

**Note:** The build script automatically detects if you have valid code signing certificates. If not, it will build without code signing for development use. The resulting app will run locally but won't be distributable.

## Caveats

- Please note this app is not compatible with the “Allow your Apple Watch to unlock your Mac” feature.
- Unfortunately this app can't be distributed via the App Store because it uses a private API to switch Bluetooth on/off (but the release version is notarized by Apple).

[download-latest]: https://github.com/odlp/bluesnooze/releases/latest

## FAQs

### Can you add support for selectively disconnecting certain devices?

Bluesnooze is a really simple app which toggles the Bluetooth power on/off.
Disconnecting specific devices would require a complete rewrite, and I don't
need this functionality or the complexity it brings. Please feel free to fork &
experiment as you like ✌️

### How can I hide the Bluesnooze icon?

In your terminal run the following command:

```sh
defaults write com.oliverpeate.Bluesnooze hideIcon -bool true 
```

When you next relaunch the application there should be no icon in the menu bar.

### How can I restore the Bluesnooze icon?

In your terminal run the following command:

```sh
defaults delete com.oliverpeate.Bluesnooze hideIcon
```

When you next relaunch the application it should appear in the menu bar.
