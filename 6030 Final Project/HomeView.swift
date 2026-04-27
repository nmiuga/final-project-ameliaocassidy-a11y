// HomeView.swift
// Atlanta Braves App - Home / Overview Tab

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var vm: BravesViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // MARK: - Hero Header
                HeroHeaderView()

                // MARK: - Content
                VStack(spacing: 24) {

                    // Quick Stats Bar
                    if let record = vm.standingsRecord {
                        QuickStatsBar(record: record)
                            .padding(.horizontal, 20)
                    }

                    // Team Info Card
                    if let team = vm.team {
                        SectionHeader(title: "Team Information", icon: "building.2.fill")
                        TeamInfoCard(team: team)
                            .padding(.horizontal, 20)
                    }

                    // Venue Card
                    if let venue = vm.team?.venue {
                        SectionHeader(title: "Home Ballpark", icon: "mappin.circle.fill")
                        VenueCard(venue: venue)
                            .padding(.horizontal, 20)
                    }

                    // League & Division Card
                    if let team = vm.team {
                        SectionHeader(title: "League & Division", icon: "trophy.fill")
                        LeagueDivisionCard(team: team)
                            .padding(.horizontal, 20)
                    }

                    // Upcoming Game Preview
                    if let nextGame = vm.upcomingGames.first {
                        SectionHeader(title: "Next Game", icon: "calendar.circle.fill")
                        NextGameCard(game: nextGame, vm: vm)
                            .padding(.horizontal, 20)
                    }

                    Spacer(minLength: 30)
                }
                .padding(.top, 24)
            }
        }
        .background(Color.bravesNavy.ignoresSafeArea())
    }
}

// MARK: - Hero Header
struct HeroHeaderView: View {
    @State private var appeared = false

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient with stadium image
            ZStack {
                // Deep navy gradient base
                LinearGradient(
                    colors: [
                        Color(red: 0.0, green: 0.08, blue: 0.20),
                        Color.bravesNavy
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Decorative diamond pattern
                GeometryReader { geo in
                    DiamondPattern()
                        .opacity(0.06)
                }

                // Red accent band
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.bravesRed.opacity(0.0), Color.bravesRed.opacity(0.25)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .frame(height: 100)
                }
            }
            .frame(height: 260)

            // Content
            VStack(spacing: 12) {
                // Braves logo using MLB CDN with fallback
                ZStack {
                    Image("Braves Image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 82, height: 82)
                                .frame(width: 82, height: 82)
                }
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0.0)

                VStack(spacing: 4) {
                    Text("ATLANTA")
                        .font(BravesFont.label(13))
                        .foregroundColor(.bravesGold)
                        .tracking(4)

                    Text("Braves")
                        .font(.system(size: 40, weight: .black, design: .serif))
                        .foregroundColor(.white)
                        .italic()

                    Text("Est. 1876")
                        .font(BravesFont.label(10))
                        .foregroundColor(.bravesSubtext)
                        .tracking(2)
                }
                .opacity(appeared ? 1.0 : 0.0)
                .offset(y: appeared ? 0 : 20)

                Spacer(minLength: 20)
            }
            .padding(.top, 60)
        }
        .frame(height: 260)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                appeared = true
            }
        }
    }
}

// MARK: - Diamond Pattern Background
struct DiamondPattern: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 40
            let diamondSize: CGFloat = 12

            var x: CGFloat = 0
            while x < size.width + spacing {
                var y: CGFloat = 0
                while y < size.height + spacing {
                    let path = Path { p in
                        p.move(to: CGPoint(x: x, y: y - diamondSize))
                        p.addLine(to: CGPoint(x: x + diamondSize * 0.6, y: y))
                        p.addLine(to: CGPoint(x: x, y: y + diamondSize))
                        p.addLine(to: CGPoint(x: x - diamondSize * 0.6, y: y))
                        p.closeSubpath()
                    }
                    context.stroke(path, with: .color(.bravesGold), lineWidth: 0.5)
                    y += spacing
                }
                x += spacing
            }
        }
    }
}

// MARK: - Quick Stats Bar
struct QuickStatsBar: View {
    let record: TeamRecord

    var body: some View {
        HStack(spacing: 8) {
            StatBox(label: "WINS", value: "\(record.wins)")
            StatBox(label: "LOSSES", value: "\(record.losses)", accent: .bravesSubtext)
            StatBox(label: "PCT", value: record.pct ?? ".---")
            StatBox(label: "GB", value: record.gamesBackDisplay, accent: .bravesRed)
        }
    }
}

// MARK: - Team Info Card
struct TeamInfoCard: View {
    let team: Team

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(BravesFont.heading(18))
                        .foregroundColor(.white)
                    if let location = team.locationName {
                        Text(location)
                            .font(BravesFont.body(13))
                            .foregroundColor(.bravesSubtext)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    if let abbr = team.abbreviation {
                        Text(abbr)
                            .font(BravesFont.mono(28))
                            .fontWeight(.black)
                            .foregroundColor(.bravesGold)
                    }
                    if let firstYear = team.firstYearOfPlay {
                        Text("Since \(firstYear)")
                            .font(BravesFont.label(10))
                            .foregroundColor(.bravesSubtext)
                    }
                }
            }

            Divider()
                .background(Color.bravesGold.opacity(0.2))
                .padding(.vertical, 12)

            // Detail rows
            VStack(spacing: 10) {
                if let franchise = team.franchiseName {
                    InfoRow(label: "Franchise", value: franchise)
                }
                if let club = team.clubName {
                    InfoRow(label: "Club Name", value: club)
                }
                if let short = team.shortName {
                    InfoRow(label: "Short Name", value: short)
                }
                if let active = team.active {
                    InfoRow(label: "Status", value: active ? "Active" : "Inactive",
                            valueColor: active ? Color(red: 0.2, green: 0.9, blue: 0.5) : .bravesRed)
                }
            }
        }
        .bravesCard()
    }
}

// MARK: - Venue Card
struct VenueCard: View {
    let venue: Venue

    var body: some View {
        VStack(spacing: 12) {
            // Stadium visual
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.bravesNavy, Color(red: 0.05, green: 0.3, blue: 0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 100)

                // Baseball diamond SVG-like overlay
                VStack {
                    HStack(spacing: 0) {
                        Spacer()
                        BaseballField()
                            .frame(width: 80, height: 70)
                            .opacity(0.4)
                        Spacer()
                    }
                }

                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "building.columns.fill")
                            .foregroundColor(.bravesGold)
                            .font(.system(size: 12))
                        Text("TRUIST PARK")
                            .font(BravesFont.label(11))
                            .foregroundColor(.bravesGold)
                            .tracking(2)
                    }
                    .padding(.bottom, 10)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.bravesGold.opacity(0.2), lineWidth: 1)
            )

            VStack(spacing: 8) {
                InfoRow(label: "Stadium", value: venue.name)
                InfoRow(label: "Location", value: "Cumberland, Georgia")
                InfoRow(label: "Opened", value: "2017")
                InfoRow(label: "Capacity", value: "41,084")
            }
        }
        .bravesCard()
    }
}

// MARK: - Baseball Field Shape
struct BaseballField: View {
    var body: some View {
        Canvas { context, size in
            let cx = size.width / 2
            let cy = size.height * 0.65
            let r = size.width * 0.45

            // Outfield arc
            let arc = Path { p in
                p.addArc(center: CGPoint(x: cx, y: cy), radius: r,
                         startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
            }
            context.stroke(arc, with: .color(.bravesGold), lineWidth: 1.5)

            // Diamond bases
            let baseSize: CGFloat = 5
            let bases: [CGPoint] = [
                CGPoint(x: cx, y: cy - r * 0.55),         // 2nd
                CGPoint(x: cx + r * 0.4, y: cy - r * 0.25), // 1st
                CGPoint(x: cx, y: cy),                     // Home
                CGPoint(x: cx - r * 0.4, y: cy - r * 0.25)  // 3rd
            ]

            for base in bases {
                let rect = CGRect(x: base.x - baseSize/2, y: base.y - baseSize/2,
                                  width: baseSize, height: baseSize)
                let sq = Path(rect)
                context.fill(sq, with: .color(.white))
            }

            // Base paths
            let diamond = Path { p in
                p.move(to: bases[2])
                p.addLine(to: bases[1])
                p.addLine(to: bases[0])
                p.addLine(to: bases[3])
                p.closeSubpath()
            }
            context.stroke(diamond, with: .color(.white.opacity(0.6)), lineWidth: 1)
        }
    }
}

// MARK: - League & Division Card
struct LeagueDivisionCard: View {
    let team: Team

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // League
                VStack(spacing: 8) {
                    Image(systemName: "rosette")
                        .font(.system(size: 24))
                        .foregroundColor(.bravesRed)
                    Text(team.league?.nameShort ?? team.league?.name ?? "NL")
                        .font(BravesFont.heading(16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("League")
                        .font(BravesFont.label(10))
                        .foregroundColor(.bravesSubtext)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bravesNavy.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                // Division
                VStack(spacing: 8) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.bravesGold)
                    Text(team.division?.nameShort ?? team.division?.name ?? "NL East")
                        .font(BravesFont.heading(16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("Division")
                        .font(BravesFont.label(10))
                        .foregroundColor(.bravesSubtext)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.bravesNavy.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            // Additional info
            VStack(spacing: 8) {
                if let sport = team.sport?.name {
                    InfoRow(label: "Sport", value: sport)
                }
                if let leagueName = team.league?.name {
                    InfoRow(label: "Full League", value: leagueName)
                }
                if let divName = team.division?.name {
                    InfoRow(label: "Full Division", value: divName)
                }
            }
        }
        .bravesCard()
    }
}

// MARK: - Next Game Card
struct NextGameCard: View {
    let game: Game
    let vm: BravesViewModel

    var homeTeam: String { game.teams?.home?.team?.name ?? "Home" }
    var awayTeam: String { game.teams?.away?.team?.name ?? "Away" }
    var venue: String { game.venue?.name ?? "TBD" }

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("UPCOMING")
                        .font(BravesFont.label(9))
                        .foregroundColor(.bravesRed)
                        .tracking(2)
                    Text(vm.formattedGameDate(game.gameDate))
                        .font(BravesFont.subheading(14))
                        .foregroundColor(.white)
                }
                Spacer()
                Image(systemName: "calendar")
                    .foregroundColor(.bravesGold)
            }

            // Matchup
            HStack {
                VStack(spacing: 4) {
                    Text(awayTeam)
                        .font(BravesFont.subheading(13))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("AWAY")
                        .font(BravesFont.label(9))
                        .foregroundColor(.bravesSubtext)
                }
                .frame(maxWidth: .infinity)

                Text("VS")
                    .font(BravesFont.mono(16))
                    .fontWeight(.black)
                    .foregroundColor(.bravesRed)
                    .padding(.horizontal, 12)

                VStack(spacing: 4) {
                    Text(homeTeam)
                        .font(BravesFont.subheading(13))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    Text("HOME")
                        .font(BravesFont.label(9))
                        .foregroundColor(.bravesSubtext)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 8)
            .background(Color.bravesNavy.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            InfoRow(label: "Venue", value: venue)
        }
        .bravesCard()
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white

    var body: some View {
        HStack {
            Text(label)
                .font(BravesFont.body(13))
                .foregroundColor(.bravesSubtext)
            Spacer()
            Text(value)
                .font(BravesFont.subheading(13))
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Braves Logo Fallback
// Drawn script "A" with tomahawk accent — shown when AsyncImage fails to load
struct BravesLogoFallback: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            let cx = w / 2
            let cy = h / 2

            // Red circle background
            let bgCircle = Path(ellipseIn: CGRect(x: 0, y: 0, width: w, height: h))
            context.fill(bgCircle, with: .color(.bravesRed))

            // White italic serif "A"
            context.withCGContext { cgCtx in
                cgCtx.setFillColor(UIColor.white.cgColor)
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: w * 0.52, weight: .black),
                    .foregroundColor: UIColor.white
                ]
                let str = NSAttributedString(string: "A", attributes: attrs)
                let line = CTLineCreateWithAttributedString(str)
                let bounds = CTLineGetBoundsWithOptions(line, [])
                cgCtx.textPosition = CGPoint(
                    x: cx - bounds.width / 2 - bounds.origin.x,
                    y: cy - bounds.height / 2 - bounds.origin.y
                )
                CTLineDraw(line, cgCtx)
            }

            // Gold tomahawk bar across the middle
            let barY = cy + h * 0.12
            let bar = Path(roundedRect: CGRect(x: w * 0.08, y: barY, width: w * 0.84, height: h * 0.07), cornerRadius: 2)
            context.fill(bar, with: .color(.bravesGold))

            // Tomahawk head (triangle on the right)
            let headPath = Path { p in
                let baseX = w * 0.78
                let tipX  = w * 0.95
                let midY  = barY + h * 0.035
                p.move(to: CGPoint(x: baseX, y: barY - h * 0.06))
                p.addLine(to: CGPoint(x: tipX, y: midY))
                p.addLine(to: CGPoint(x: baseX, y: barY + h * 0.13))
                p.closeSubpath()
            }
            context.fill(headPath, with: .color(.bravesGold))
        }
    }
}
