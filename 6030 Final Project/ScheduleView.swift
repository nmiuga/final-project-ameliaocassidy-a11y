// ScheduleView.swift
// Atlanta Braves App - Schedule Tab

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var vm: BravesViewModel
    @State private var selectedTab: ScheduleTab = .upcoming

    enum ScheduleTab: String, CaseIterable {
        case recent = "Recent"
        case upcoming = "Upcoming"
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bravesNavy.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Segmented tab
                    HStack(spacing: 0) {
                        ForEach(ScheduleTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                    selectedTab = tab
                                }
                            } label: {
                                Text(tab.rawValue)
                                    .font(BravesFont.subheading(14))
                                    .foregroundColor(selectedTab == tab ? .bravesNavy : .bravesSubtext)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(selectedTab == tab ? Color.bravesGold : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.bravesCardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    // Content
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            if vm.isLoadingSchedule {
                                ForEach(0..<5, id: \.self) { _ in
                                    GameCardSkeleton()
                                        .padding(.horizontal, 20)
                                }
                            } else {
                                let games = selectedTab == .upcoming ? vm.upcomingGames : vm.recentGames

                                if games.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "calendar.badge.exclamationmark")
                                            .font(.system(size: 40))
                                            .foregroundColor(.bravesSubtext)
                                        Text("No \(selectedTab.rawValue.lowercased()) games")
                                            .font(BravesFont.subheading())
                                            .foregroundColor(.bravesSubtext)
                                    }
                                    .padding(.top, 60)
                                } else {
                                    ForEach(games) { game in
                                        GameCard(game: game, vm: vm, isRecent: selectedTab == .recent)
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            Spacer(minLength: 30)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Game Card
struct GameCard: View {
    let game: Game
    let vm: BravesViewModel
    let isRecent: Bool

    var homeTeam: GameTeamEntry? { game.teams?.home }
    var awayTeam: GameTeamEntry? { game.teams?.away }
    var homeTeamName: String { homeTeam?.team?.name ?? "Home" }
    var awayTeamName: String { awayTeam?.team?.name ?? "Away" }
    var isHomeGame: Bool { homeTeam?.team?.id == 144 }

    var gameResult: String? {
        guard isRecent else { return nil }
        let bravesTeam = isHomeGame ? homeTeam : awayTeam
        return bravesTeam?.isWinner == true ? "W" : "L"
    }

    var resultColor: Color {
        gameResult == "W" ? Color(red: 0.2, green: 0.85, blue: 0.4) : .bravesRed
    }

    var body: some View {
        VStack(spacing: 12) {
            // Date & Status
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(.bravesSubtext)
                    Text(vm.formattedGameDate(game.gameDate))
                        .font(BravesFont.body(12))
                        .foregroundColor(.bravesSubtext)
                }

                Spacer()

                // Status badge
                if isRecent {
                    if let result = gameResult {
                        Text(result)
                            .font(BravesFont.mono(14))
                            .fontWeight(.black)
                            .foregroundColor(resultColor)
                            .frame(width: 36, height: 24)
                            .background(resultColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    Text("FINAL")
                        .font(BravesFont.label(10))
                        .foregroundColor(.bravesSubtext)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.bravesCardBg.opacity(0.6))
                        .clipShape(Capsule())
                } else {
                    Text(game.status?.detailedState ?? "Scheduled")
                        .font(BravesFont.label(10))
                        .foregroundColor(.bravesGold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.bravesGold.opacity(0.15))
                        .clipShape(Capsule())
                }
            }

            // Matchup
            HStack(alignment: .center, spacing: 0) {
                // Away team
                VStack(spacing: 4) {
                    Text(awayTeamName)
                        .font(BravesFont.subheading(13))
                        .foregroundColor(awayTeam?.team?.id == 144 ? .white : .white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    if let rec = awayTeam?.leagueRecord {
                        Text("\(rec.wins ?? 0)-\(rec.losses ?? 0)")
                            .font(BravesFont.mono(11))
                            .foregroundColor(.bravesSubtext)
                    }
                }
                .frame(maxWidth: .infinity)

                // Score or VS
                VStack(spacing: 2) {
                    if isRecent,
                       let awayScore = awayTeam?.score,
                       let homeScore = homeTeam?.score {
                        HStack(alignment: .center, spacing: 6) {
                            Text("\(awayScore)")
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(awayTeam?.isWinner == true ? .white : .white.opacity(0.5))
                            Text("-")
                                .font(.system(size: 20, weight: .light, design: .monospaced))
                                .foregroundColor(.bravesSubtext)
                            Text("\(homeScore)")
                                .font(.system(size: 28, weight: .black, design: .monospaced))
                                .foregroundColor(homeTeam?.isWinner == true ? .white : .white.opacity(0.5))
                        }
                    } else {
                        Text("VS")
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.bravesRed)
                    }
                }
                .frame(width: 80)

                // Home team
                VStack(spacing: 4) {
                    Text(homeTeamName)
                        .font(BravesFont.subheading(13))
                        .foregroundColor(homeTeam?.team?.id == 144 ? .white : .white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    if let rec = homeTeam?.leagueRecord {
                        Text("\(rec.wins ?? 0)-\(rec.losses ?? 0)")
                            .font(BravesFont.mono(11))
                            .foregroundColor(.bravesSubtext)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 4)

            // Venue
            if let venueName = game.venue?.name {
                Divider().background(Color.bravesGold.opacity(0.15))
                HStack(spacing: 5) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.bravesSubtext)
                    Text(venueName)
                        .font(BravesFont.body(12))
                        .foregroundColor(.bravesSubtext)
                    Spacer()

                    if isHomeGame {
                        Text("HOME")
                            .font(BravesFont.label(9))
                            .foregroundColor(.bravesGold)
                            .tracking(1)
                    }
                }
            }
        }
        .bravesCard()
    }
}

// MARK: - Skeleton
struct GameCardSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bravesCardBg)
                    .frame(width: 120, height: 12)
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.bravesCardBg)
                    .frame(width: 60, height: 22)
            }
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.bravesCardBg)
                    .frame(height: 40)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.bravesCardBg)
                    .frame(width: 60, height: 30)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.bravesCardBg)
                    .frame(height: 40)
            }
        }
        .padding(16)
        .background(Color.bravesCardBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .opacity(shimmer ? 0.4 : 0.8)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: shimmer)
        .onAppear { shimmer = true }
    }
}
