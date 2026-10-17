# NovelReader (iOS + iPadOS)

A SwiftUI novel reading app concept for iPhone and iPad that supports importing downloaded reading files and customizing readability.

## Features
- Import local files: **EPUB, TXT, MD, RTF**
- Read imported content in a distraction-free interface
- Adjustable **font size**
- Adjustable reading **background themes** (paper/night/mint/sky)
- Bilingual UI localization: **English** and **Simplified Chinese**
- Liquid-style glass UI cards using modern material effects

## Project structure
- `NovelReader/NovelReaderApp.swift` – app entry point
- `NovelReader/ContentView.swift` – split-view library + reader settings UI
- `NovelReader/Views/ReaderView.swift` – reading page
- `NovelReader/Services/DocumentImportService.swift` – file import/parsing
- `NovelReader/Models/ReaderDocument.swift` – reader models
- `NovelReader/Resources/*/Localizable.strings` – localization
- `Package.swift` – pinned ZIPFoundation dependency and import-layer test targets
- `Tests/NovelReaderImportTests` – generated archive and document import regression tests

## Build and validation
- The repository is a source scaffold, not an Xcode app project. Create an **iOS App** target in Xcode with an **iOS 17+** deployment target, add the Swift files under `NovelReader`, and include both localization folders as app resources.
- Add the Swift package `https://github.com/weichsel/ZIPFoundation.git` at exact version **0.9.20** and link its **ZIPFoundation** product to the app target. The root manifest declares the same dependency for import-layer tests; it does not build the SwiftUI app.
- On macOS 13+ with Xcode/Command Line Tools, run `swift test` from the repository root. Tests cover UTF-8 TXT/MD, RTF, stored/deflated EPUB chapters, chapter ordering, multiple extraction chunks, ignored non-text/symlink entries, and unreadable/corrupt archives.
- Build the app for an iPhone/iPad simulator in Xcode, then verify all four formats on a device using Files/iCloud Drive or another file provider. Try multi-selection containing both valid and unreadable files; valid files should still be added and failed imports should show an error. Repeat imports to check that scoped access is released on both success and failure. Package tests cannot reproduce Files-provider permissions.

## Notes
- EPUB support uses ZIPFoundation in process to read UTF-8 HTML/XHTML entries in path order, verify their checksums, and strip HTML tags for a quick MVP. No subprocess or temporary extraction directory is used. This retains the existing preview behavior rather than reading the EPUB spine/TOC.
- Each URL returned by `fileImporter` is accessed within a security scope for the entire synchronous import, with a matching stop only when access was granted. App-local URLs that do not need a scope are still read normally. Document text is kept in memory, so reading it later does not reopen the original URL.
- For production quality EPUB rendering, consider integrating a dedicated parser/rendering engine and chapter/TOC navigation.
