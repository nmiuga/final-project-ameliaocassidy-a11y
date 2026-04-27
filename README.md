# ⚾ Atlanta Braves iOS App

A SwiftUI iOS application built with MVVM architecture that displays live Atlanta Braves data from the MLB Stats API.

---

## 📁 Project Structure

```
BravesApp/
├── BravesApp.xcodeproj/
│   └── project.pbxproj          # Xcode project file
└── BravesApp/
    ├── BravesApp.swift           # @main App entry point
    ├── ContentView.swift         # Root TabView + app setup
    ├── Models.swift              # Codable data models
    ├── BravesViewModel.swift     # ObservableObject ViewModel
    ├── BravesTheme.swift         # Design system, colors, fonts
    ├── HomeView.swift            # Home/Overview tab
    ├── RosterView.swift          # Active Roster tab
    ├── StandingsView.swift       # NL East Standings tab
    └── ScheduleView.swift        # Schedule tab
```

---

## 🏗 Architecture: MVVM

### Model Layer (`Models.swift`)
All API response shapes are modeled as `Codable` structs:

| Struct | Purpose |
|---|---|
| `Team` / `TeamResponse` | Team details (name, location, venue, league, division) |
| `RosterEntry` / `Person` / `Position` | Active roster players |
| `TeamRecord` / `StandingsRecord` | Win/loss standings, splits |
| `Game` / `ScheduleDate` | Schedule, scores, game status |

### ViewModel Layer (`BravesViewModel.swift`)
`@MainActor class BravesViewModel: ObservableObject`

- `@Published` properties for team, roster, standings, schedule
- `async/await` + `URLSession` for all network calls
- Parallel loading via `withTaskGroup`
- Error handling with `@Published var errorMessage`

### View Layer (5 SwiftUI files)
- `ContentView` — `TabView` with 4 tabs, tab bar styling
- `HomeView` — hero header, team info cards, venue, standings preview
- `RosterView` — searchable/filterable player list
- `StandingsView` — NL East table, split records, streak
- `ScheduleView` — recent results and upcoming games

---

## 🎨 Design System (`BravesTheme.swift`)

### Colors
| Name | Hex | Usage |
|---|---|---|
| `bravesNavy` | `#002657` | Background, primary |
| `bravesRed` | `#CE1E30` | Accents, section headers |
| `bravesGold` | `#E0B44F` | Stats, highlights |
| `bravesCardBg` | dark blue | Card backgrounds |
| `bravesSubtext` | steel blue | Secondary text |

### Typography (`BravesFont`)
| Style | System Font | Usage |
|---|---|---|
| `.title()` | Black Serif | Hero title |
| `.heading()` | Bold Rounded | Section headers |
| `.subheading()` | Semibold Rounded | Card titles |
| `.body()` | Regular Rounded | General text |
| `.mono()` | Medium Monospaced | Stats/numbers |
| `.label()` | Bold Rounded | Uppercase labels |

### Reusable Components
- `StatBox` — stat value with label
- `SectionHeader` — icon + uppercase title + rule
- `InfoRow` — label/value pair
- `PositionBadge` — color-coded position abbreviation
- `BravesLoadingView` — animated spinner
- `.bravesCard()` — card modifier (background, corner radius, shadow)

---

## 🌐 API Endpoints Used

Base URL: `https://statsapi.mlb.com/api/v1`  
Team ID: `144` (Atlanta Braves)  
Season: `2025`

| Endpoint | Data Fetched |
|---|---|
| `/teams/144?hydrate=venue,league,division,sport` | Team info |
| `/teams/144/roster?rosterType=active` | Active roster |
| `/standings?leagueId=104` | NL standings |
| `/schedule?teamId=144&startDate=...&endDate=...` | Schedule |

---

## 📱 Tabs

### 🏠 Home
- Animated hero header with tomahawk logo
- Win/loss/PCT/GB stat bar
- Team Info card (name, location, franchise)
- Venue card (Truist Park) with baseball diamond graphic
- League & Division card (NL / NL East)
- Upcoming game preview card

### 👥 Roster
- Filter by All / Pitchers / Position Players
- Searchable player list
- Jersey number, full name, position badge
- Roster count chips
- Skeleton loading animation

### 📊 Standings
- Animated W/L record hero with win % bar
- Full NL East standings table (W/L/PCT/GB)
- Braves highlighted in the table
- Split records (Home/Away/Day/Night)
- Current streak card

### 📅 Schedule
- Toggle between Recent results and Upcoming games
- Game cards with score (final) or VS (upcoming)
- Venue name, home/away indicator
- Skeleton loading state

---

## 🚀 How to Run

1. **Open in Xcode:**
   ```
   open BravesApp.xcodeproj
   ```

2. **Select a target** — iPhone 15 Simulator or any iOS 17+ device

3. **Build & Run** — `⌘R`

4. The app loads all data on launch using `async/await` parallel fetches.

> **Note:** The MLB Stats API is public and does not require an API key.

---

## ✅ Requirements Checklist

- [x] MLB Stats API integration (4 endpoints)
- [x] `Codable` model structs
- [x] `ObservableObject` ViewModel with `@Published`
- [x] `async/await` network calls with `URLSession`
- [x] MVVM architecture
- [x] Multiple pages (4 tabs)
- [x] Custom font styling (3 tiers: title, heading, body)
- [x] Heading accent color (Braves red / gold)
- [x] Image/visual (baseball field Canvas drawing, hero logo)
- [x] Visual modifications (gradients, overlays, opacity)
- [x] ScrollView + VStack layout
- [x] 3+ card sections on home screen
- [x] Padding, rounded corners, shadows
- [x] 3+ data points from API displayed
- [x] `@StateObject` / `@EnvironmentObject` state management
- [x] Loading/skeleton states
- [x] Error handling

---

## 📦 Dependencies

None — pure SwiftUI + Foundation only.
