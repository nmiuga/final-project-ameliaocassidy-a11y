import Foundation

// Models for the team season stats endpoint: /api/v1/teams/{id}/stats?stats=season&season=YYYY
struct TeamStatsResponse: Codable {
    let stats: [TeamStatsGroup]
}

struct TeamStatsGroup: Codable {
    let splits: [TeamStatsSplit]
}

struct TeamStatsSplit: Codable {
    let stat: MLBTeamSeasonStats
}

struct MLBTeamSeasonStats: Codable {
    let wins: String?
    let losses: String?
    let gamesPlayed: String?
    let winPercentage: String?
}
