# CLAUDE.md - AI Assistant Development Guide for Melodic Stamp

## Project Overview

**Melodic Stamp** is a sophisticated native macOS music player and audio metadata editor application designed for macOS 15.0 Sequoia and above. It provides an elegant interface for playing local audio files, editing metadata, and displaying synchronized lyrics with advanced features like word-based lyrics (Apple Music style).

### Quick Facts
- **Primary Language**: Swift 6.0 (249 files, ~15,000 LOC)
- **Minimum macOS**: 15.0 Sequoia
- **Architecture**: MVVM + Observable State Management with SwiftUI
- **Build System**: Xcode with Swift Package Manager
- **Audio Engine**: SFBAudioEngine (40+ audio formats supported)
- **Lyrics Formats**: LRC, TTML (word-based), Plain Text

---

## Repository Structure

```
MelodicStamp/
├── MelodicStamp/                 # Main app bundle
│   ├── Models/                   # Content-specific models (PlayerModel, LibraryModel, etc.)
│   ├── Utilities/                # Helpers, extensions, observable patterns
│   ├── Assets.xcassets/          # App resources and icons
│   ├── MelodicStampApp.swift     # App entry point (@main)
│   ├── AppDelegate.swift         # macOS lifecycle management
│   └── Preview Content/          # SwiftUI preview environments
│
├── Models/                        # Shared data models (domain logic)
│   ├── Player/                   # Playback logic (Player protocol, PlaybackState, PlaybackTime)
│   ├── Metadata/                 # Audio metadata structures with modification tracking
│   ├── Lyrics/                   # Multi-format lyrics parsing (LRC, TTML, Raw)
│   ├── Playlist/                 # Playlist and Track models with Transferable support
│   ├── Indexing/                 # File indexing system
│   ├── Settings/                 # Settings models
│   ├── Sidebar/                  # Navigation models
│   └── Defaults/                 # User preferences (via Defaults library)
│
├── Interface/                     # SwiftUI view hierarchy
│   ├── Main/                     # Main window (Leaflet, Playlist, Inspectors)
│   ├── Player/                   # Player controls and cover art display
│   ├── Lyrics/                   # Lyrics display (AppleMusicLyricsView, DisplayLyricsView)
│   ├── Settings/                 # Preferences window
│   ├── Floating Windows/         # Floating player windows
│   ├── Functional/               # Commands, toolbars, presentations
│   ├── Auxiliary/                # Shared UI components
│   ├── Metadata Editor/          # Metadata editing controls
│   └── About/                    # About window
│
├── ModelsTests/                  # XCTest for Models
├── InterfaceTests/               # XCTest for Interface
├── MelodicStampTests/            # XCTest for main app
├── Docs/                         # Documentation and screenshots
├── .swiftformat                  # SwiftFormat configuration
├── Mintfile                      # SwiftFormat dependency
├── LICENSE                       # GPL-3.0 license
└── README.md                     # User-facing documentation
```

---

## Architecture & Design Patterns

### 1. MVVM + Observable State Management

The app uses **Model-View-ViewModel** with Swift 6.0's `@Observable` macro for reactive state management:

- **Models** (`Models/`): Domain logic, data structures, protocols
- **View Models** (`MelodicStamp/Models/Content/`): Observable state containers (e.g., `PlayerModel`, `LibraryModel`)
- **Views** (`Interface/`): SwiftUI views consuming observable state

**Key Pattern**:
```swift
@Observable @MainActor
class PlayerModel {
    var playbackState: PlaybackState = .paused
    var currentTrack: Track?
    // ... state properties
}
```

### 2. Protocol-Driven Design

Extensive use of protocols for abstraction and testability:
- `Player` - Playback interface (implemented by `BlankPlayer`)
- `LyricsParser` - Multi-format lyrics parsing
- `Restorable` - Undo/redo support for metadata
- `MetadataEditorProtocol` - Metadata editing abstraction
- `TypeNameReflectable` - Custom runtime type information

### 3. Entry-Based Modification Tracking

Metadata uses `MetadataEntry<V>` wrappers to track changes:
```swift
struct MetadataEntry<V> {
    var initialValue: V
    var currentValue: V
    var isModified: Bool { initialValue != currentValue }
}
```
This enables:
- Detection of unsaved changes
- Restore to original values
- Batch editing with `MetadataBatchEditingEntry`

### 4. Multi-Window Scene Architecture

Uses SwiftUI's scene-based API:
- `WindowGroup` - Main content window with custom `CreationParameters`
- `Window` - About window
- `Settings` - Preferences window
- Floating windows managed via `FloatingWindowsModel`

### 5. Audio Visualization with FFT

Real-time frequency spectrum analysis:
- `AudioVisualizerModel` - Configurable frequency bands (80 default)
- `RealtimeAnalyzer` - FFT processing
- `GradientVisualizerModel` - Animated gradients from album art

---

## Key Components & Models

### Core Models (`Models/`)

#### Metadata System
- **`Metadata.swift`** - Main audio file metadata container with state management
- **`MetadataEntry.swift`** - Generic wrapper for modification tracking
- **`AdditionalMetadata.swift`** - Extended metadata storage
- **`MetadataEditorProtocol.swift`** - Protocol for metadata editing

#### Audio Playback
- **`Player.swift`** - Playback protocol with `BlankPlayer` implementation
- **`PlaybackState.swift`** - Play/pause/stop state enum
- **`PlaybackTime.swift`** - Duration and elapsed time tracking
- **`PlaybackMode.swift`** - Repeat modes (none, all, single)

#### Lyrics System (Multi-Format)
- **`LyricsParser.swift`** - Protocol for parsing different formats
- **`LRC/LRCParser.swift`** - LRC format with tags `[mm:ss.xx]`
- **`TTML/TTMLParser.swift`** - Word-based lyrics (Apple Music style)
- **`Raw/RawLyricsParser.swift`** - Plain text fallback
- **`LyricsAttachments.swift`** - Metadata attachments for lyrics
- **`LyricsStorage.swift`** - Lyrics persistence

#### Playlist & Track Management
- **`Playlist.swift`** - Container supporting referenced and canonical modes
- **`Track.swift`** - Individual track implementing `Transferable` (drag & drop)
- **`TrackIndexer.swift`** - Efficient track indexing
- **`PlaylistIndexer.swift`** - Playlist indexing and persistence

### Content Models (`MelodicStamp/Models/Content/`)

#### Global State
- **`LibraryModel.swift`** - Manages all playlists with async loading
- **`FloatingWindowsModel.swift`** - Floating window coordination

#### Window Management
- **`WindowManagerModel.swift`** - Window styling, state, full-screen handling
- **`PresentationManagerModel.swift`** - Dialog and presentation coordination
- **`FileManagerModel.swift`** - File handling and imports

#### Player Integration
- **`PlayerModel.swift`** - Main player with audio visualization
- **`PlayerModel+NowPlaying.swift`** - Media player integration (macOS controls)
- **`PlayerModel+Auxiliary.swift`** - Helper methods

#### Content Management
- **`PlaylistModel.swift`** - Observable playlist wrapper with selection tracking
- **`MetadataEditorModel.swift`** - Batch metadata editing
- **`KeyboardControlModel.swift`** - Keyboard shortcut handling

### UI Components (`Interface/`)

#### Main Interface
- **`ContentView.swift`** - Window initialization and state setup (8 major models)
- **`InterfaceView.swift`** - View hierarchy orchestration
- **`Main/MainView.swift`** - Sidebar + content split view

#### Player Interface
- **`Player/PlayerView.swift`** - Main player controls
- **`Player/MiniPlayerView.swift`** - Compact player mode
- **`Player/Music Cover/`** - Album artwork display with interaction

#### Lyrics Display
- **`Lyrics/DisplayLyricsView.swift`** - Synchronized lyric rendering
- **`Lyrics/AppleMusicLyricsView.swift`** - Word-based lyrics (TTML)
- **`Lyrics/LyricsAnalyzerView.swift`** - Lyric editing interface

#### Functional Components
- **`Functional/Commands/`** - Menu command handlers (File, Edit, Player, Playlist, Window)
- **`Functional/Toolbars/`** - Context-specific toolbars
- **`Functional/Presentations/`** - File import and unsaved changes dialogs

---

## Application Flow

### Entry Point: `MelodicStampApp.swift`

```
@main
struct MelodicStampApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var floatingWindowsModel = FloatingWindowsModel()
    @State var libraryModel = LibraryModel()

    var body: some Scene {
        WindowGroup { ContentView() }
        Window("About") { AboutView() }
        Settings { SettingsView() }
        Commands { /* File, Edit, Player, etc. */ }
    }
}
```

### Initialization Sequence

1. **App Launch** → `MelodicStampApp` creates global `FloatingWindowsModel` and `LibraryModel`
2. **ContentView** initializes 8 major state models:
   - `WindowManagerModel`
   - `PresentationManagerModel`
   - `FileManagerModel`
   - `PlaylistModel`
   - `PlayerModel`
   - `KeyboardControlModel`
   - `MetadataEditorModel`
   - `AudioVisualizerModel`
3. **AppDelegate** handles lifecycle events (launch, open files, termination)
4. **LibraryModel** loads playlists asynchronously
5. **PlayerModel** initializes audio engine and output devices

### Main Window Layout

```
ContentView (SplitView)
├── Left Sidebar: Playlist navigation
├── Center: MainView
│   ├── Leaflet (Lyrics display)
│   └── Playlist (Track listing)
└── Right Inspector: Metadata/Library/Analytics
```

---

## Development Conventions

### 1. Code Style (SwiftFormat)

Configuration in `.swiftformat`:
- **Indentation**: 4 spaces (not tabs)
- **Swift Version**: 6.0
- **Line Width**: Unlimited
- **Acronyms**: ID, URL, UUID (always uppercase)
- **Rules**: See `.swiftformat` for full list

**Run formatting**:
```bash
mint run swiftformat .
```

### 2. Threading & Concurrency

**Critical Rules**:
- All UI models must be annotated `@MainActor`
- Observable models with UI interaction: `@Observable @MainActor`
- Use `Task { @MainActor in ... }` for async UI updates
- Player and audio operations can run on background threads

**Example**:
```swift
@Observable @MainActor
class PlaylistModel {
    var tracks: [Track] = []

    func loadTracks() async {
        // Heavy work on background thread
        let loaded = await Task.detached {
            // ... file I/O
        }.value

        // UI update on main actor
        self.tracks = loaded
    }
}
```

### 3. State Management Best Practices

**Observable Pattern**:
- Use `@Observable` macro (Swift 5.9+) instead of `ObservableObject`
- Avoid `@Published` and `@StateObject` (legacy SwiftUI)
- Environment injection for cross-view state

**Weak References**:
- Models often hold weak references to avoid retain cycles
- Example: `PlayerModel` has `weak var playlistModel: PlaylistModel?`

### 4. Metadata Editing Pattern

**Always use `MetadataEntry<V>` for mutable metadata**:
```swift
var title = MetadataEntry(wrappedValue: "Song Title")

// Modify
title.currentValue = "New Title"

// Check if modified
if title.isModified {
    // Save changes
}

// Restore to original
title.restore()
```

### 5. File Operations

**Use `FileManagerModel` for imports**:
```swift
fileManagerModel.importFiles(from: urls) { result in
    switch result {
    case .success(let tracks):
        playlist.tracks.append(contentsOf: tracks)
    case .failure(let error):
        // Handle error
    }
}
```

### 6. Lyrics Parsing

**Use appropriate parser based on format**:
```swift
let parser: LyricsParser
switch lyricsFormat {
case .lrc:
    parser = LRCParser()
case .ttml:
    parser = TTMLParser()
case .raw:
    parser = RawLyricsParser()
}

let lyrics = try parser.parse(from: lyricsString)
```

### 7. Testing

**Test Infrastructure**:
- Framework: XCTest with Swift Testing macros (`@Test`)
- Targets: `ModelsTests`, `InterfaceTests`, `MelodicStampTests`
- Currently minimal coverage (project in active development)

**Test Pattern**:
```swift
import Testing
@testable import Models

@Test func testMetadataModification() {
    var entry = MetadataEntry(wrappedValue: "Original")
    entry.currentValue = "Modified"
    #expect(entry.isModified == true)
}
```

---

## External Dependencies (SPM)

All dependencies managed via Swift Package Manager:

### Audio & Media
- **SFBAudioEngine** - Audio decoding (40+ formats)
- **CAAudioHardware** - Output device management
- **DominantColors** - Album art color extraction

### UI & Animation
- **Luminare** - UI utilities
- **Morphed** - Advanced animations
- **MeshGradient** - Gradient rendering
- **SwiftUIScrollOffset** - Scroll tracking
- **swiftui-introspect** - SwiftUI internals access

### Data & Utilities
- **Defaults** - User preferences persistence
- **SFSafeSymbols** - Safe SF Symbols access
- **SwiftSoup** - HTML parsing (for TTML)
- **smart-cache** - Efficient caching
- **swift-collections** - Additional collection types

---

## Common Development Tasks

### Adding a New Metadata Field

1. **Update `Metadata.swift`**: Add property with `MetadataEntry<T>`
2. **Update UI**: Add field in `Interface/Metadata Editor/CommonMetadataView.swift`
3. **Update parser**: Modify metadata reading in `Models/Metadata/`
4. **Test**: Ensure save/restore cycle works

### Adding a New Lyrics Format

1. **Create parser**: Implement `LyricsParser` protocol in `Models/Lyrics/`
2. **Update `LyricsAttachments.swift`**: Add format detection
3. **Create UI**: Add renderer in `Interface/Lyrics/`
4. **Update `Info.plist`**: Add file type if needed

### Adding a New Command

1. **Create command file**: In `Interface/Functional/Commands/`
2. **Implement `Commands` struct**: Define menu items and keyboard shortcuts
3. **Register in `MelodicStampApp.swift`**: Add to `commands` modifier
4. **Update localization**: Add strings to `Localizable.xcstrings`

### Modifying Player Behavior

1. **Update `Player` protocol**: In `Models/Player/Player.swift`
2. **Implement in `BlankPlayer`**: The concrete implementation
3. **Update `PlayerModel`**: In `MelodicStamp/Models/Content/PlayerModel.swift`
4. **Update UI**: In `Interface/Player/PlayerView.swift`

### Adding a New Window

1. **Create view**: In appropriate `Interface/` subdirectory
2. **Update `MelodicStampApp.swift`**: Add `Window` or `WindowGroup` scene
3. **Add command**: Create menu item to open window
4. **Manage state**: Use environment or `@Environment` for coordination

---

## Important Constraints & Considerations

### 1. macOS 15.0+ Only
- No backward compatibility needed
- Can use latest SwiftUI and Swift 6.0 features
- Leverage modern macOS APIs freely

### 2. SFBAudioEngine Integration
- Audio engine handles format detection and decoding
- Do not duplicate format handling logic
- Use engine's metadata reading capabilities

### 3. Sandboxing & Entitlements
- App requires file access entitlements
- Defined in `MelodicStamp.entitlements`
- Be mindful of sandbox restrictions

### 4. Performance Considerations
- **FFT visualization**: Runs at 10 FPS (0.1s interval)
- **Track indexing**: Uses efficient indexing system, avoid full scans
- **Metadata loading**: Can be I/O intensive, use async operations
- **SwiftUI performance**: Avoid unnecessary view updates, use `@Observable` correctly

### 5. Memory Management
- Large playlists: Be mindful of memory usage
- Album art: Images are cached, don't duplicate
- Audio buffers: Managed by SFBAudioEngine

### 6. Localization
- Strings in `Localizable.xcstrings`
- Currently supports: English, Simplified Chinese
- Use `String(localized:)` for all user-facing strings

---

## Things to Avoid

### 1. Breaking Changes to Playlist Format
- Playlists are persisted to disk
- Maintain backward compatibility for playlist indexing
- Test migration if changing `Playlist` or `Track` structures

### 2. Modifying `.swiftformat` Without Testing
- Format affects entire codebase
- Run `mint run swiftformat .` and review diffs before committing

### 3. Using Legacy SwiftUI Patterns
- Avoid `@ObservedObject`, `@StateObject`, `@EnvironmentObject`
- Use `@Observable` and `@Environment` instead
- No `@Published` properties

### 4. Blocking the Main Thread
- Audio operations can be expensive
- Always use async/await for I/O
- Wrap heavy computations in `Task.detached { }`

### 5. Hardcoding File Paths
- Use proper file access APIs
- Respect sandbox restrictions
- Use `FileManager` and user selection dialogs

### 6. Adding Dependencies Without Justification
- Project uses 13 SPM dependencies already
- Ensure new dependencies are necessary
- Check license compatibility (project is GPL-3.0)

---

## Testing & Quality Assurance

### Running Tests
```bash
xcodebuild test -scheme MelodicStamp -destination 'platform=macOS'
```

### Manual Testing Checklist
- [ ] Audio playback (all supported formats)
- [ ] Lyrics display (LRC, TTML, plain text)
- [ ] Metadata editing and persistence
- [ ] Playlist creation and management
- [ ] Keyboard shortcuts
- [ ] Window management (main, floating, settings)
- [ ] Audio visualization
- [ ] Album art display
- [ ] File import (drag & drop, file picker)

### SwiftUI Previews
- Use preview environments in `MelodicStamp/Utilities/Preview Content/`
- Preview modifier: `PreviewEnvironmentsModifier`
- Test UI components in isolation before integration

---

## Git Workflow

### Branch Strategy
- **Development branch**: `claude/add-claude-documentation-CZ1Oe`
- All changes should be committed to this branch
- Push with: `git push -u origin claude/add-claude-documentation-CZ1Oe`

### Commit Messages
- Follow conventional commit style
- Use emoji prefixes (seen in recent commits):
  - 🚚 `:truck:` - Move/rename files
  - 🔥 `:fire:` - Remove code/files
  - ♻️ `:recycle:` - Refactor code
  - 🎨 `:art:` - Format code
  - ✨ `:sparkles:` - New feature
  - 🐛 `:bug:` - Bug fix
  - 📝 `:memo:` - Documentation

### Before Committing
1. Run SwiftFormat: `mint run swiftformat .`
2. Build project: Ensure no compile errors
3. Run tests: `xcodebuild test`
4. Review changes: Check for unintended modifications

---

## Resources & Documentation

### Internal Documentation
- **README.md** - User-facing project overview
- **Docs/ADD_A_LOCALIZATION.md** - Localization guide
- **Models.docc** - Swift DocC for Models module
- **Interface.docc** - Swift DocC for Interface module

### External Resources
- [SFBAudioEngine](https://github.com/sbooth/SFBAudioEngine) - Audio engine documentation
- [Swift 6.0 Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)

### Key Specifications
- [LRC Format](https://en.wikipedia.org/wiki/LRC_(file_format)) - Lyrics format
- [TTML](https://en.wikipedia.org/wiki/Timed_Text_Markup_Language) - Word-based lyrics format

---

## AI Assistant Guidelines

### When Working on This Codebase

**DO**:
- Read existing code before proposing changes
- Follow established patterns (Observable, MetadataEntry, protocols)
- Use async/await for I/O operations
- Annotate UI models with `@MainActor`
- Use `MetadataEntry<T>` for editable metadata
- Test changes with SwiftUI previews
- Run SwiftFormat before committing
- Maintain localization for new strings
- Follow the emoji commit convention

**DON'T**:
- Use legacy SwiftUI patterns (`@ObservedObject`, `@StateObject`)
- Block the main thread with heavy operations
- Hardcode file paths or bypass sandbox
- Add dependencies without justification
- Break backward compatibility for playlists
- Ignore compilation warnings
- Skip testing new functionality
- Create unnecessary abstractions (keep it simple)

### Understanding the Codebase
1. **Start with `MelodicStampApp.swift`** - Entry point and scene setup
2. **Review `ContentView.swift`** - Main window initialization
3. **Explore `Models/`** - Domain logic and data structures
4. **Check `Interface/`** - UI implementation
5. **Read protocol definitions** - Understanding abstraction layers

### Making Changes
1. **Identify impact area**: Models, Interface, or both
2. **Check for protocols**: Implement existing abstractions before creating new ones
3. **Maintain state patterns**: Use `@Observable` and weak references correctly
4. **Test thoroughly**: UI, data persistence, edge cases
5. **Update documentation**: If adding major features, update this file

---

## Project Statistics

| Metric | Value |
|--------|-------|
| Swift Files | 249 |
| Models LOC | ~4,396 |
| Interface LOC | ~10,405 |
| Observable Models | 23+ |
| `@MainActor` Annotations | 78+ |
| External Dependencies | 13 |
| Supported Audio Formats | 40+ |
| Lyrics Formats | 3 |
| Swift Version | 6.0 |
| Minimum macOS | 15.0 Sequoia |

---

## Quick Reference

### Build & Run
```bash
# Open in Xcode
open "Melodic Stamp.xcodeproj"

# Build from command line
xcodebuild -scheme MelodicStamp

# Run tests
xcodebuild test -scheme MelodicStamp -destination 'platform=macOS'

# Format code
mint run swiftformat .
```

### Key Files to Know
- `MelodicStampApp.swift` - App entry point
- `ContentView.swift` - Main window setup
- `Models/Player/Player.swift` - Playback protocol
- `Models/Metadata/Metadata.swift` - Metadata container
- `Models/Lyrics/LyricsParser.swift` - Lyrics parsing protocol
- `MelodicStamp/Models/Content/PlayerModel.swift` - Main player implementation
- `Interface/Main/MainView.swift` - Main UI layout

### Common Patterns to Reference
- Observable state: `MelodicStamp/Models/Content/PlayerModel.swift`
- Metadata tracking: `Models/Metadata/MetadataEntry.swift`
- Protocol implementation: `Models/Player/BlankPlayer.swift`
- Multi-format parsing: `Models/Lyrics/*/Parser.swift`
- SwiftUI commands: `Interface/Functional/Commands/`

---

*This documentation is intended to help AI assistants understand and work effectively with the Melodic Stamp codebase. For user-facing documentation, see README.md.*

**Last Updated**: 2026-01-12
**Generated for**: Session `claude/add-claude-documentation-CZ1Oe`
