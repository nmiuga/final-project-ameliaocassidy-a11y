// Models.swift
// Atlanta Braves App - MVVM Model Layer

import Foundation

// MARK: - Team Response
struct TeamResponse: Codable {
    let teams: [Team]
}

struct Team: Codable, Identifiable {
    let id: Int
    let name: String
    let locationName: String?
    let teamName: String?
    let abbreviation: String?
    let teamCode: String?
    let shortName: String?
    let franchiseName: String?
    let clubName: String?
    let firstYearOfPlay: String?
    let active: Bool?
    let venue: Venue?
    let league: LeagueInfo?
    let division: DivisionInfo?
    let sport: SportInfo?
}

struct Venue: Codable, Identifiable {
    let id: Int
    let name: String
    let link: String?
}

struct LeagueInfo: Codable, Identifiable {
    let id: Int
    let name: String?
    let link: String?
    let abbreviation: String?
    let nameShort: String?
}

struct DivisionInfo: Codable, Identifiable {
    let id: Int
    let name: String?
    let link: String?
    let nameShort: String?
    let abbreviation: String?
}

struct SportInfo: Codable, Identifiable {
    let id: Int
    let name: String?
    let link: String?
}

// MARK: - Roster Response
struct RosterResponse: Codable {
    let roster: [RosterEntry]
    let teamId: Int?
    let rosterType: String?
}

struct RosterEntry: Codable, Identifiable {
    let person: Person
    let jerseyNumber: String?
    let position: Position?
    let status: StatusInfo?

    var id: Int { person.id }
}

struct Person: Codable, Identifiable {
    let id: Int
    let fullName: String
    let link: String?
}

struct Position: Codable {
    let code: String?
    let name: String?
    let type: String?
    let abbreviation: String?
}

struct StatusInfo: Codable {
    let code: String?
    let description: String?
}

// MARK: - Standings Response
struct StandingsResponse: Codable {
    let records: [StandingsRecord]
}

struct StandingsRecord: Codable {
    let standingsType: String?
    let league: LeagueInfo?
    let division: DivisionInfo?
    let teamRecords: [TeamRecord]
}

struct TeamRecord: Codable, Identifiable {
    let team: TeamRef
    let wins: Int
    let losses: Int
    let pct: String?
    let gamesBack: String?
    let divisionRank: String?
    let leagueRank: String?
    let streak: StreakInfo?
    let runsScored: Int?
    let runsAllowed: Int?
    let winningPercentage: String?
    let records: RecordDetails?

    var id: Int { team.id }

    var winLoss: String { "\(wins)-\(losses)" }
    var gamesBackDisplay: String { gamesBack == "-" || gamesBack == nil ? "—" : gamesBack! }
}

struct TeamRef: Codable, Identifiable {
    let id: Int
    let name: String
    let link: String?
}

struct StreakInfo: Codable {
    let streakType: String?
    let streakNumber: Int?
    let streakCode: String?
}

struct RecordDetails: Codable {
    let splitRecords: [SplitRecord]?
    let divisionRecords: [DivisionRecord]?
    let overallRecords: [OverallRecord]?
}

struct SplitRecord: Codable {
    let wins: Int?
    let losses: Int?
    let type: String?
    let pct: String?
}

struct DivisionRecord: Codable {
    let wins: Int?
    let losses: Int?
    let pct: String?
    let division: DivisionInfo?
}

struct OverallRecord: Codable {
    let wins: Int?
    let losses: Int?
    let type: String?
    let pct: String?
}

// MARK: - Schedule Response
struct ScheduleResponse: Codable {
    let totalGames: Int?
    let totalGamesInProgress: Int?
    let dates: [ScheduleDate]
}

struct ScheduleDate: Codable {
    let date: String
    let games: [Game]
}

struct Game: Codable, Identifiable {
    let gamePk: Int
    let gameDate: String?
    let status: GameStatus?
    let teams: GameTeams?
    let venue: Venue?

    var id: Int { gamePk }
}

struct GameStatus: Codable {
    let abstractGameState: String?
    let detailedState: String?
    let statusCode: String?
}

struct GameTeams: Codable {
    let away: GameTeamEntry?
    let home: GameTeamEntry?
}

struct GameTeamEntry: Codable {
    let score: Int?
    let team: TeamRef?
    let isWinner: Bool?
    let leagueRecord: LeagueRecord?
}

struct LeagueRecord: Codable {
    let wins: Int?
    let losses: Int?
    let pct: String?
}
