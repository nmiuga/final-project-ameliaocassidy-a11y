Atlanta Braves iOS App — Project Reflection

Overview
This project involved building a multi-page SwiftUI iOS application that displays live Atlanta Braves data pulled from the public MLB Stats API. The app follows the MVVM architectural pattern and is organized across five Swift source files covering models, a view model, a design system, and four distinct tab views.

What I Built
The app consists of four tabs — Home, Roster, Standings, and Schedule — each backed by live API data fetched concurrently on launch. The Home tab presents a hero header with a decorative diamond pattern drawn using SwiftUI's Canvas API, followed by card-style sections for team info, venue details, and league/division metadata. The Roster tab renders the active 26-man roster with filtering by player type and a live search bar. The Standings tab shows the full NL East standings table with the Braves row highlighted, split records (home/away, day/night), and a current streak card. The Schedule tab toggles between recent results and upcoming games, showing scores and venue details for each.

Technical Decisions
MVVM Architecture was chosen from the start to keep concerns cleanly separated. All Codable model structs live in Models.swift, the BravesViewModel owns every API call and publishes state, and the views are purely reactive — they never touch the network directly.
Parallel data loading using withTaskGroup meant all four API endpoints (team info, roster, standings, schedule) fired simultaneously rather than sequentially. This significantly reduced the perceived load time since the bottleneck is the slowest single request rather than their sum.
@MainActor on the ViewModel eliminated a common SwiftUI pitfall — publishing UI updates from a background thread — without requiring manual DispatchQueue.main.async calls scattered throughout the fetching logic.
A centralized design system in BravesTheme.swift made it easy to stay visually consistent across all four tabs. Colors, font styles, the card modifier, and reusable components like StatBox, PositionBadge, and SectionHeader all live there, so any future tab would automatically inherit the same look.
SwiftUI Canvas was used for the baseball field graphic on the Venue card and the diamond grid in the hero header, both entirely code-drawn with no image assets required. This kept the bundle lightweight and made the visuals fully scalable.

Challenges
API response shape uncertainty was the main modeling challenge. The MLB Stats API returns deeply nested JSON with many optional fields — a team record might include division standings but omit split records depending on how early in the season the request is made. Handling this gracefully required making nearly every nested field optional and writing safe fallback displays throughout the views.
Standings filtering required identifying the correct division ID (204 for NL East) rather than relying on the team's own division reference, because the standings endpoint returns records grouped by division rather than by team.
Date parsing for the schedule was more involved than expected. The API returns ISO 8601 timestamps with fractional seconds, which requires ISO8601DateFormatter with the .withFractionalSeconds option rather than a simple DateFormatter.
Tab bar and navigation bar theming in SwiftUI still requires dropping into UIKit's appearance API. Setting UITabBar.appearance() and UINavigationBar.appearance() at launch in ContentView worked reliably, though it feels like a rough edge that pure SwiftUI hasn't fully smoothed over yet.

What Went Well
The async/await concurrency model made the networking code remarkably readable compared to callback-based approaches. The loadAll() method reads almost like a synchronous description of what happens, and errors propagate cleanly through do/catch blocks without pyramid-of-doom nesting.
The component-first approach to the design system paid off quickly. Once BravesCard, StatBox, and InfoRow were built, assembling new cards for the Home tab took only a few minutes each, with zero repeated styling code.
Skeleton loading states with shimmer animations added significant polish for minimal effort — a repeating easeInOut opacity animation on placeholder shapes makes the app feel responsive even before data arrives.
