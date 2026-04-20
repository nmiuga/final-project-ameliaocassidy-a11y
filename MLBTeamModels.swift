import Foundation

// Root response from /api/v1/teams/{id}
struct MLBTeamsResponse: Codable {
    let teams: [MLBTeam]
}

struct MLBTeam: Codable, Identifiable {
    let id: Int
    let name: String
    let teamName: String?
    let locationName: String?
    let shortName: String?
    let venue: MLBVenue?
    let league: MLBLeague?
    let division: MLBDivision?
}

struct MLBVenue: Codable {
    let id: Int?
    let name: String?
}

struct MLBLeague: Codable {
    let id: Int?
    let name: String?
}

struct MLBDivision: Codable {
    let id: Int?
    let name: String?
}
