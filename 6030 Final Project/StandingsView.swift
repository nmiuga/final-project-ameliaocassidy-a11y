// StandingsView.swift
// Atlanta Braves App - Standings Tab

import SwiftUI

struct StandingsView: View {
    @EnvironmentObject var vm: BravesViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.bravesNavy.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        // Braves record hero
                        if let record = vm.standingsRecord {
                            BravesRecordHero(record: record)
                                .padding(.horizontal, 20)
                        }

                        // Division standings table
                        SectionHeader(title: "NL East Standings", icon: "list.number")
                        DivisionStandingsTable(records: vm.divisionStandings, bravesID: 144)
                            .padding(.horizontal, 20)

                        // Braves split records
                        if let record = vm.standingsRecord {
                            SectionHeader(title: "Braves Records", icon: "chart.bar.fill")
                            SplitRecordsView(record: record)
                                .padding(.horizontal, 20)
                        }

                        // Streak info
                        if let streak = vm.standingsRecord?.streak {
                            SectionHeader(title: "Current Streak", icon: "flame.fill")
                            StreakCard(streak: streak)
                                .padding(.horizontal, 20)
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Standings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Braves Record Hero
struct BravesRecordHero: View {
    let record: TeamRecord
    @State private var appeared = false

    var winPct: Double {
        guard record.wins + record.losses > 0 else { return 0 }
        return Double(record.wins) / Double(record.wins + record.losses)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top - W/L
            ZStack {
                LinearGradient(
                    colors: [Color.bravesRed.opacity(0.8), Color.bravesNavy],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )

                VStack(spacing: 16) {
                    Text("2025 RECORD")
                        .font(BravesFont.label(11))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(3)

                    HStack(alignment: .lastTextBaseline, spacing: 8) {
                        Text("\(record.wins)")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                            .foregroundColor(.white)

                        Text("-")
                            .font(.system(size: 36, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))

                        Text("\(record.losses)")
                            .font(.system(size: 64, weight: .black, design: .monospaced))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    // Win percentage bar
                    VStack(spacing: 6) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.white.opacity(0.15))

                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color.bravesGold)
                                    .frame(width: appeared ? geo.size.width * CGFloat(winPct) : 0)
                                    .animation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.4), value: appeared)
                            }
                        }
                        .frame(height: 6)

                        HStack {
                            Text("Win %: \(record.pct ?? ".000")")
                                .font(BravesFont.label(11))
                                .foregroundColor(.bravesGold)
                            Spacer()
                            Text("Rank: #\(record.divisionRank ?? "?") in NL East")
                                .font(BravesFont.label(11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.bravesRed.opacity(0.3), radius: 12, x: 0, y: 6)
        }
        .onAppear { appeared = true }
    }
}

// MARK: - Division Standings Table
struct DivisionStandingsTable: View {
    let records: [TeamRecord]
    let bravesID: Int

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("TEAM")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("W")
                    .frame(width: 36)
                Text("L")
                    .frame(width: 36)
                Text("PCT")
                    .frame(width: 50)
                Text("GB")
                    .frame(width: 40)
            }
            .font(BravesFont.label(11))
            .foregroundColor(.bravesSubtext)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color.bravesNavy.opacity(0.8))

            Divider().background(Color.bravesGold.opacity(0.2))

            if records.isEmpty {
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(.bravesGold)
                    Text("Loading standings...")
                        .font(BravesFont.body(12))
                        .foregroundColor(.bravesSubtext)
                }
                .padding(.vertical, 30)
            } else {
                ForEach(Array(records.enumerated()), id: \.element.id) { idx, record in
                    StandingsRow(
                        record: record,
                        rank: idx + 1,
                        isBraves: record.team.id == bravesID
                    )

                    if idx < records.count - 1 {
                        Divider()
                            .background(Color.bravesGold.opacity(0.1))
                            .padding(.horizontal, 14)
                    }
                }
            }
        }
        .background(Color.bravesCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.bravesGold.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Standings Row
struct StandingsRow: View {
    let record: TeamRecord
    let rank: Int
    let isBraves: Bool

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                // Rank
                Text("\(rank)")
                    .font(BravesFont.mono(12))
                    .foregroundColor(isBraves ? .bravesGold : .bravesSubtext)
                    .frame(width: 18)

                Text(record.team.name)
                    .font(BravesFont.subheading(13))
                    .foregroundColor(isBraves ? .white : .white.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(record.wins)")
                .font(BravesFont.mono(13))
                .foregroundColor(isBraves ? .white : .white.opacity(0.8))
                .frame(width: 36)

            Text("\(record.losses)")
                .font(BravesFont.mono(13))
                .foregroundColor(isBraves ? .white : .white.opacity(0.8))
                .frame(width: 36)

            Text(record.pct ?? "—")
                .font(BravesFont.mono(13))
                .foregroundColor(isBraves ? .bravesGold : .white.opacity(0.7))
                .frame(width: 50)

            Text(record.gamesBackDisplay)
                .font(BravesFont.mono(13))
                .foregroundColor(isBraves ? .bravesRed : .bravesSubtext)
                .frame(width: 40)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(isBraves ? Color.bravesRed.opacity(0.12) : Color.clear)
    }
}

// MARK: - Split Records
struct SplitRecordsView: View {
    let record: TeamRecord

    var homeSplit: SplitRecord? {
        record.records?.splitRecords?.first { $0.type == "home" }
    }
    var awaySplit: SplitRecord? {
        record.records?.splitRecords?.first { $0.type == "away" }
    }
    var daySplit: SplitRecord? {
        record.records?.splitRecords?.first { $0.type == "day" }
    }
    var nightSplit: SplitRecord? {
        record.records?.splitRecords?.first { $0.type == "night" }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                if let home = homeSplit {
                    SplitCard(
                        title: "HOME",
                        wins: home.wins ?? 0,
                        losses: home.losses ?? 0,
                        pct: home.pct,
                        icon: "house.fill",
                        color: .bravesGold
                    )
                }
                if let away = awaySplit {
                    SplitCard(
                        title: "AWAY",
                        wins: away.wins ?? 0,
                        losses: away.losses ?? 0,
                        pct: away.pct,
                        icon: "airplane",
                        color: .bravesRed
                    )
                }
            }

            HStack(spacing: 12) {
                if let day = daySplit {
                    SplitCard(
                        title: "DAY",
                        wins: day.wins ?? 0,
                        losses: day.losses ?? 0,
                        pct: day.pct,
                        icon: "sun.max.fill",
                        color: .bravesGold
                    )
                }
                if let night = nightSplit {
                    SplitCard(
                        title: "NIGHT",
                        wins: night.wins ?? 0,
                        losses: night.losses ?? 0,
                        pct: night.pct,
                        icon: "moon.fill",
                        color: Color(red: 0.4, green: 0.5, blue: 0.9)
                    )
                }
            }
        }
    }
}

// MARK: - Split Card
struct SplitCard: View {
    let title: String
    let wins: Int
    let losses: Int
    let pct: String?
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12))
                Text(title)
                    .font(BravesFont.label(11))
                    .foregroundColor(.bravesSubtext)
                    .tracking(1.5)
            }

            Text("\(wins)-\(losses)")
                .font(BravesFont.mono(20))
                .fontWeight(.black)
                .foregroundColor(.white)

            if let pct = pct {
                Text(pct)
                    .font(BravesFont.label(11))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .bravesCard()
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let streak: StreakInfo

    var isWinStreak: Bool { streak.streakType == "wins" }
    var streakColor: Color { isWinStreak ? Color(red: 0.2, green: 0.85, blue: 0.4) : .bravesRed }
    var streakLabel: String { isWinStreak ? "WIN STREAK 🔥" : "LOSING STREAK" }

    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(streakLabel)
                    .font(BravesFont.label(12))
                    .foregroundColor(streakColor)
                    .tracking(1.5)
                Text(streak.streakCode ?? "—")
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
            Image(systemName: isWinStreak ? "flame.fill" : "arrow.down.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(streakColor.opacity(0.3))
        }
        .bravesCard()
    }
}
