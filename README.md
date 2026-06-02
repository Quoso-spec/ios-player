# Salt Player iOS

A beautiful local music player for iOS, inspired by [Salt Player (椒盐音乐)](https://github.com/Moriafly/SaltPlayerSource).

## Features

- **Local Music Playback**: Play music files from your device (MP3, M4A, FLAC, AAC, WAV, AIFF, OGG)
- **AVAudioEngine**: High-quality audio playback with gapless support and crossfade
- **10-Band Equalizer**: Customize your audio with presets (Pop, Rock, Jazz, Classical, etc.)
- **Synchronized Lyrics**: Display lyrics from .lrc files
- **Album Art**: Extract and display embedded album artwork
- **Playlists**: Create and manage custom playlists
- **Dark Theme**: Beautiful dark interface inspired by Salt Player
- **Background Playback**: Continue playing when the app is in the background
- **Lock Screen Controls**: Full playback control from the lock screen and Control Center

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

### 1. Install XcodeGen

On macOS, install XcodeGen:

```bash
brew install xcodegen
```

### 2. Generate the Xcode Project

Navigate to the project directory and run:

```bash
cd SaltPlayeriOS
xcodegen generate
```

### 3. Open in Xcode

```bash
open SaltPlayeriOS.xcodeproj
```

### 4. Configure Signing

1. Select the `SaltPlayeriOS` target in Xcode
2. Go to "Signing & Capabilities"
3. Select your development team
4. Choose a bundle identifier (e.g., `com.yourname.SaltPlayer`)

### 5. Build and Run

Select a simulator or connected device and press **Cmd+R** to build and run.

## Dependencies

This project uses Swift Package Manager for dependencies:

- [ID3TagEditor](https://github.com/chicio/ID3TagEditor) - MP3 ID3 tag reading
- [SQLite.swift](https://github.com/stephencelis/SQLite.swift) - Database management
- [SnapKit](https://github.com/SnapKit/SnapKit) - Auto Layout DSL

## Project Structure

```
SaltPlayeriOS/
├── SaltPlayeriOS/
│   ├── App/               # App entry point and delegates
│   ├── Core/
│   │   ├── Audio/         # AVAudioEngine, Gapless, Crossfade, Equalizer
│   │   ├── Library/       # Music scanning, metadata reading
│   │   ├── Lyrics/        # LRC parsing, lyrics sync
│   │   └── Storage/       # SQLite, UserDefaults
│   ├── Features/
│   │   ├── Home/          # Home screen
│   │   ├── Library/       # Music library browser
│   │   ├── Player/        # Main player, mini player, lyrics
│   │   ├── Queue/         # Play queue management
│   │   ├── Playlist/      # Playlist management
│   │   ├── Equalizer/     # Equalizer UI
│   │   ├── Settings/       # Settings screen
│   │   └── FileImport/    # Document picker
│   ├── Components/         # Reusable UI components
│   ├── Design/            # Theme, colors, typography
│   ├── Extensions/        # Swift extensions
│   ├── Models/            # Data models
│   └── Resources/         # Assets, Info.plist
└── project.yml            # XcodeGen configuration
```

## Usage

### Importing Music

1. Tap the folder icon (+) in the Library tab
2. Select a folder containing your music files
3. The app will scan and import all supported audio files

### Playing Music

- Tap any song to start playing
- Use the mini player at the bottom to control playback
- Swipe up on the mini player for the full player view
- Toggle lyrics view with the text icon

### Creating Playlists

1. Go to the Playlists tab
2. Tap + to create a new playlist
3. Add songs from your library

### Equalizer

1. Go to Settings > Equalizer
2. Enable the equalizer
3. Select a preset or adjust individual bands

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

- **Models**: `Song`, `Album`, `Artist`, `Playlist`, `LyricLine`
- **ViewModels**: `PlayerViewModel`, `LibraryViewModel`, `PlaylistViewModel`, etc.
- **Views**: SwiftUI views for all UI components

Core audio functionality is managed by the `AudioEngine` singleton, which wraps `AVAudioEngine` with:
- Gapless playback via `GaplessPlayer`
- Crossfade via `CrossfadePlayer`
- 10-band equalizer via `AVAudioUnitEQ`

## Design

The app uses a dark theme inspired by Salt Player:
- Background: #0D0D0D
- Surface: #1A1A1A
- Accent: #5B7FFF
- Gradient: #5B7FFF to #9B7FFF

## License

This project is for educational and personal use. Salt Player (椒盐音乐) is a registered trademark of Xunxun Technology (Shanghai) Co., Ltd.

## Acknowledgments

- Inspired by [Salt Player](https://github.com/Moriafly/SaltPlayerSource) by Moriafly
- UI components from [SaltUI](https://github.com/Moriafly/SaltUI)
