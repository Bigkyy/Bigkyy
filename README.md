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

## Notes
- EPUB support is implemented as lightweight archive extraction + HTML text stripping for a quick MVP.
- For production quality EPUB rendering, consider integrating a dedicated parser/rendering engine and chapter/TOC navigation.
