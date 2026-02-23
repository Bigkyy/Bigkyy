# Apple Reading App Product Plan (iOS / iPadOS / macOS)

## 1) Product Vision
Build a bilingual (Chinese + English) cross-platform Apple reading app for importing and reading EPUB and similar document/novel formats, with an immersive reading experience, Apple-style UI polish, and extensible internationalization.

Working name: **LiquidLeaf Reader**.

## 2) Platforms and Technology
- **Framework**: SwiftUI + Combine + async/await.
- **Targets**:
  - iOS 17+
  - iPadOS 17+
  - macOS 14+
- **Architecture**: Feature modular MVVM.
- **Storage**:
  - SwiftData/Core Data for library metadata, history, and reading progress.
  - Local file sandbox + security-scoped bookmarks for imported files.

## 3) Supported Formats (MVP → Phase 2)
### MVP
- EPUB (reflowable)
- TXT
- PDF (basic reader mode)

### Phase 2
- MOBI/AZW import conversion pipeline (if legally and technically feasible)
- DOCX (read-only conversion)

## 4) UX + Apple Design Direction
To align with Apple’s contemporary visual language and the user request for “liquid glass” style:
- Use translucent materials (`.ultraThinMaterial`, `.regularMaterial`) for floating controls.
- Large, elegant typography with Dynamic Type support.
- Soft depth via layered cards + subtle shadowing.
- Smooth spring-based interactions for panel reveal/hide.
- Native-feeling toolbar collapse behavior based on scroll and tap focus mode.

## 5) Core Features Requested
### A. Import and Library Management
- Import via Files picker, drag/drop (iPad/macOS), and share sheet extension.
- Parse metadata (title, author, cover, language).
- Display books in grid/list with recent and pinned sections.

### B. Bilingual + Expandable Localization
- Initial localizations:
  - Simplified Chinese (`zh-Hans`)
  - English (`en`)
- Localization structure:
  - `Localizable.xcstrings` with modular string tables by feature.
  - No hardcoded text in views.
- Future expansion:
  - Add Traditional Chinese, Japanese, Korean, etc. without code refactor.

### C. Reading Experience
- Theme/background presets (at least 5):
  - Paper (warm white)
  - Sepia
  - Dark gray
  - Pure black (OLED)
  - Soft green
- Typography controls:
  - Font family
  - Font size
  - Line spacing
  - Margin width
- Reading modes:
  - Scroll mode
  - Pagination mode

### D. Skeuomorphic Page-Turning Animation
- Realistic page curl for pagination mode:
  - Gesture-driven corner/edge drag.
  - Shadow gradient + backside texture simulation.
  - Physics snap to complete/cancel page turn.
- Accessibility fallback:
  - Reduced motion mode switches to fade/slide transition.

### E. Hideable Bottom Tool/Feature Box
- Reader controls can auto-hide for immersive reading.
- Behavior:
  - Single tap toggles control visibility.
  - Controls dock to bottom and collapse on inactivity.
  - iPad landscape/portrait adaptive safe-area logic.
- On macOS:
  - Bottom inspector bar can collapse into compact mode.

### F. Reading Progress + Recent History System
- Track per-book:
  - Current chapter/page/CFI
  - Percentage completed
  - Last opened timestamp
  - Total reading time
- Home widgets/sections:
  - Continue reading
  - Recently opened
  - Most read this week
- In-reader progress indicator:
  - Minimal indicator in bottom edge or overlay HUD.

## 6) Information Architecture
1. **Library Tab**
   - All books, filters, sort, collections.
2. **Continue Tab**
   - Active books + quick resume.
3. **Reader View**
   - Full screen content, hidden controls by default after delay.
4. **Settings Tab**
   - Language, themes, animation preferences, sync options.

## 7) Suggested Technical Modules
- `ImportModule`: File intake, validation, parsing.
- `LibraryModule`: Metadata indexing + collections.
- `ReaderModule`: Rendering, pagination, gestures, theme engine.
- `ProgressModule`: Bookmark/progress/history tracking.
- `LocalizationModule`: Strings and locale switching.
- `DesignSystem`: Colors, spacing, glass components.

## 8) Data Model (Draft)
- `Book`
  - id, title, author, coverPath, format, language, createdAt
- `ReadingState`
  - bookId, locator(CFI/page), progressPercent, lastOpenedAt, readingSeconds
- `ReadingSession`
  - id, bookId, startedAt, endedAt, pagesRead
- `UserPreference`
  - themeId, fontSize, lineSpacing, animationMode, locale

## 9) Accessibility and Quality
- VoiceOver labels for reader controls.
- High contrast text/background combinations.
- Dynamic Type and Bold Text support.
- RTL/LTR readiness for future localization.
- Offline-first behavior.

## 10) Roadmap
### Phase 1 (MVP, 8–12 weeks)
- EPUB/TXT/PDF import
- Library + reader core
- Theme switching
- Reading progress + recent history
- Chinese/English localization
- Basic page-turn animation

### Phase 2
- Advanced skeuomorphic animation polish
- Cross-device sync (CloudKit)
- Highlights/notes/export
- Widgets and Siri shortcuts

### Phase 3
- AI-assisted summarization (optional)
- More language packs
- Plugin-style importer extensions

## 11) Acceptance Criteria for the Requested Scope
- User can import EPUB and start reading within 3 taps.
- App supports both Chinese and English UI text.
- Reader offers multiple background themes for eye comfort.
- Pagination mode includes realistic page-turn animation.
- Bottom controls can be hidden and do not obstruct iPad landscape reading.
- App persistently tracks and displays reading progress and recent history.

## 12) Next Build Step Recommendation
Start implementation with a SwiftUI multi-target workspace and deliver a clickable prototype of:
1) Library import flow,
2) Reader with hideable bottom controls,
3) Theme switching,
4) Progress persistence.
