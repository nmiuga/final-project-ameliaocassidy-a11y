import Foundation
import SwiftUI
import Combine

@MainActor
final class BravesViewModel: ObservableObject {
    @Published var team: MLBTeam?
    @Published var roster: [RosterEntry] = []
    @Published var seasonStats: MLBTeamSeasonStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let teamURL = URL(string: "https://statsapi.mlb.com/api/v1/teams/144")
    private let rosterURL = URL(string: "https://statsapi.mlb.com/api/v1/teams/144/roster?rosterType=active")

    func fetchTeam() async {
        isLoading = true
        errorMessage = nil
        do {
            guard let teamURL = teamURL else {
                self.errorMessage = "Invalid team URL"
                isLoading = false
                return
            }
            let (data, response) = try await URLSession.shared.data(from: teamURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(MLBTeamsResponse.self, from: data)
            self.team = decoded.teams.first
        } catch {
            self.errorMessage = error.localizedDescription
        }
        // Fetch additional data
        await fetchRoster()
        await fetchSeasonStats()
        isLoading = false
    }

    func fetchRoster() async {
        guard let rosterURL = rosterURL else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: rosterURL)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(RosterResponse.self, from: data)
            self.roster = decoded.roster
        } catch {
            if self.errorMessage == nil {
                self.errorMessage = "Failed to load roster: \(error.localizedDescription)"
            }
        }
    }

    func fetchSeasonStats() async {
        guard let url = URL(string: "https://statsapi.mlb.com/api/v1/teams/144/stats?stats=season&group=team") else { return }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            let decoded = try JSONDecoder().decode(TeamStatsResponse.self, from: data)
            self.seasonStats = decoded.stats.first?.splits.first?.stat
        } catch {
            // Don't override other errors if season stats fail; just leave stats nil
            print("Season stats error: \(error.localizedDescription)")
        }
    }
}

