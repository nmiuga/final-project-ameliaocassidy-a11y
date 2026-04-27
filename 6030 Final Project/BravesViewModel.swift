// BravesViewModel.swift
// Atlanta Braves App - MVVM ViewModel Layer

import Foundation
import Combine

@MainActor
class BravesViewModel: ObservableObject {

    // MARK: - Published State
    @Published var team: Team?
    @Published var roster: [RosterEntry] = []
    @Published var standingsRecord: TeamRecord?
    @Published var divisionStandings: [TeamRecord] = []
    @Published var recentGames: [Game] = []
    @Published var upcomingGames: [Game] = []

    @Published var isLoadingTeam = false
    @Published var isLoadingRoster = false
    @Published var isLoadingStandings = false
    @Published var isLoadingSchedule = false

    @Published var errorMessage: String?

    // MARK: - Constants
    private let baseURL = "https://statsapi.mlb.com/api/v1"
    private let bravesID = 144
    private let season = 2025

    // MARK: - Computed
    var isLoading: Bool {
        isLoadingTeam || isLoadingRoster || isLoadingStandings || isLoadingSchedule
    }

    var pitchers: [RosterEntry] {
        roster.filter { $0.position?.type == "Pitcher" }
    }

    var positionPlayers: [RosterEntry] {
        roster.filter { $0.position?.type != "Pitcher" && $0.position?.type != nil }
    }

    // MARK: - Load All
    func loadAll() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchTeamInfo() }
            group.addTask { await self.fetchRoster() }
            group.addTask { await self.fetchStandings() }
            group.addTask { await self.fetchSchedule() }
        }
    }

    // MARK: - Fetch Team Info
    func fetchTeamInfo() async {
        isLoadingTeam = true
        defer { isLoadingTeam = false }

        let urlString = "\(baseURL)/teams/\(bravesID)?season=\(season)&hydrate=venue,league,division,sport"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(TeamResponse.self, from: data)
            self.team = response.teams.first
        } catch {
            self.errorMessage = "Failed to load team info: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Roster
    func fetchRoster() async {
        isLoadingRoster = true
        defer { isLoadingRoster = false }

        let urlString = "\(baseURL)/teams/\(bravesID)/roster?season=\(season)&rosterType=active"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(RosterResponse.self, from: data)
            // Sort: players with jersey numbers first (by number), then those without
            self.roster = response.roster.sorted {
                let n0 = Int($0.jerseyNumber ?? "") ?? 999
                let n1 = Int($1.jerseyNumber ?? "") ?? 999
                return n0 < n1
            }
        } catch {
            self.errorMessage = "Failed to load roster: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Standings
    func fetchStandings() async {
        isLoadingStandings = true
        defer { isLoadingStandings = false }

        let urlString = "\(baseURL)/standings?leagueId=104&season=\(season)&standingsTypes=regularSeason&hydrate=team,division,league"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(StandingsResponse.self, from: data)

            // Find NL East (division 204)
            for record in response.records {
                if record.division?.id == 204 {
                    self.divisionStandings = record.teamRecords.sorted {
                        let r1 = Int($0.divisionRank ?? "99") ?? 99
                        let r2 = Int($1.divisionRank ?? "99") ?? 99
                        return r1 < r2
                    }
                    self.standingsRecord = record.teamRecords.first { $0.team.id == self.bravesID }
                    break
                }
            }
        } catch {
            self.errorMessage = "Failed to load standings: \(error.localizedDescription)"
        }
    }

    // MARK: - Fetch Schedule
    func fetchSchedule() async {
        isLoadingSchedule = true
        defer { isLoadingSchedule = false }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        // Wide window: 10 days back, 30 days forward to ensure we catch upcoming games
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -10, to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)

        // Use hydrate=team only — linescore hydration can cause decode failures mid-season
        let urlString = "\(baseURL)/schedule?teamId=\(bravesID)&season=\(season)&startDate=\(start)&endDate=\(end)&gameType=R&hydrate=team,venue"
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ScheduleResponse.self, from: data)

            var recent: [Game] = []
            var upcoming: [Game] = []

            for dateEntry in response.dates {
                for game in dateEntry.games {
                    let state = game.status?.abstractGameState ?? ""
                    switch state {
                    case "Final":
                        recent.append(game)
                    case "Live":
                        // In-progress games go to front of upcoming
                        upcoming.insert(game, at: 0)
                    default:
                        // "Preview", "Scheduled", "" etc. — all future/upcoming
                        upcoming.append(game)
                    }
                }
            }

            self.recentGames = Array(recent.suffix(5).reversed())
            self.upcomingGames = Array(upcoming.prefix(7))
        } catch {
            self.errorMessage = "Failed to load schedule: \(error.localizedDescription)"
            print("Schedule decode error: \(error)")
        }
    }

    // MARK: - Helpers
    func formattedGameDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "TBD" }

        // Try with fractional seconds first
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso.date(from: dateString) {
            return displayDate(date)
        }
        // Try without fractional seconds
        iso.formatOptions = [.withInternetDateTime]
        if let date = iso.date(from: dateString) {
            return displayDate(date)
        }
        // Fallback: just show the date portion
        return String(dateString.prefix(10))
    }

    private func displayDate(_ date: Date) -> String {
        let display = DateFormatter()
        display.dateFormat = "MMM d · h:mm a"
        display.timeZone = TimeZone.current
        return display.string(from: date)
    }
}
