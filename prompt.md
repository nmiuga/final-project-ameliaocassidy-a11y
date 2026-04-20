Build a single-screen iOS app using SwiftUI themed around the Atlanta Braves that displays team information using data from the MLB Stats API.
🔧 Core Requirements
1. API Integration
Use the MLB Stats API endpoint:
    https://statsapi.mlb.com/api/v1/teams/144"
Create Codable structs to model the JSON response.
Implement an ObservableObject ViewModel that:
Fetches data using URLSession
Stores and publishes the team data
Call the API when the view appears and update the UI dynamically.
🎨 UI / Design Requirements
2. Text Styling
Use a custom typeface (import and apply a custom font).
Include at least three types of text:
Title: App title (e.g., “Atlanta Braves”)
Heading: Section headers (e.g., “Team Info”)
Body/Subheading: Supporting details (e.g., venue, league, division)
Style rules:
Headings should use an accent color (Braves red or navy).
Apply padding and line spacing for readability.
3. Image
Include at least one .jpg image related to the Braves (team logo, stadium, or players).
Apply at least one visual modification, such as:
Overlay (color tint in Braves colors)
Opacity adjustment
Blur or shadow
Ensure images are:
Consistently sized
Properly scaled (e.g., .scaledToFill() or .aspectRatio)
Styled so they appear uniform on screen
4. Layout
Use a ScrollView containing a VStack.
Inside the VStack, display at least three similar elements (cards or sections), such as:
Team Info (name, location, league)
Venue Info (stadium name)
Division Info
Each element should:
Be visually grouped (card-style recommended)
Have padding, rounded corners, and subtle shadow
Ensure the layout is clean, spaced evenly, and scrollable.
📊 Content Requirements
Display at least three pieces of data from the API, such as:
Team Name
Location Name
League Name
Division Name
Venue Name
Season Record 
Current Players
Other Important Information
Repeat this structured layout for at least three sections/cards to maintain consistency.
🧠 Architecture
Follow MVVM pattern:
Model: Codable structs for API response
ViewModel: Handles API call and state
View: SwiftUI layout
Use best practices for:
State management (@StateObject, @Published)
Async data fetching (async/await preferred)
