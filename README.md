# SaltMusic iOS Native Skeleton

This repository contains a greenfield SwiftUI source skeleton for an authorized iOS native edition of Salt Player / 椒盐音乐.

The project intentionally does not include a generated `.xcodeproj` because this workspace is on Windows and cannot validate Xcode project files. Create the Xcode shell on macOS, then add the folders in this repository as source groups. See [Docs/XCODE_SETUP.md](Docs/XCODE_SETUP.md).

## Product Boundary

- Local music files, user-authorized folders, optional system media-library metadata, lyrics, artwork, and metadata enhancement.
- No built-in third-party online music playback source.
- No Android/KMP source dependency. Moriafly projects are used only as authorized product, visual, and behavior references.

## Stack

- iOS 17+
- SwiftUI
- AVFoundation / MediaPlayer
- SQLite3 C API through `SQLiteStore`
- No third-party Swift packages

## Current Implementation Shape

- `App`: app bootstrap, environment wiring, Info.plist, entitlements placeholder
- `Core`: models, SQLite storage, bookmark helpers
- `Services`: playback, import, metadata, lyrics, system media-library placeholders, theme
- `Features`: SwiftUI shell, library, player, lyrics, settings screens
- `Tests`: focused parser tests that can be added to an Xcode test target

