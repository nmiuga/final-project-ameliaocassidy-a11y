// RosterView.swift
// Atlanta Braves App - Active Roster Tab

import SwiftUI

struct RosterView: View {
    @EnvironmentObject var vm: BravesViewModel
    @State private var searchText = ""
    @State private var selectedFilter: RosterFilter = .all

    enum RosterFilter: String, CaseIterable {
        case all = "All"
        case pitchers = "Pitchers"
        case position = "Position"
    }

    var filteredRoster: [RosterEntry] {
        let filtered: [RosterEntry]
        switch selectedFilter {
        case .all:
            filtered = vm.roster
        case .pitchers:
            filtered = vm.pitchers
        case .position:
            filtered = vm.positionPlayers
        }

        if searchText.isEmpty { return filtered }
        return filtered.filter {
            $0.person.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.bravesNavy.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        // Filter pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(RosterFilter.allCases, id: \.self) { filter in
                                    FilterPill(
                                        label: filter.rawValue,
                                        isSelected: selectedFilter == filter,
                                        action: { selectedFilter = filter }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        // Stats summary
                        HStack(spacing: 8) {
                            RosterStatChip(label: "Total", value: "\(vm.roster.count)")
                            RosterStatChip(label: "Pitchers", value: "\(vm.pitchers.count)", color: .bravesRed)
                            RosterStatChip(label: "Position", value: "\(vm.positionPlayers.count)", color: .bravesGold)
                        }
                        .padding(.horizontal, 20)

                        // Roster list
                        if vm.isLoadingRoster {
                            ForEach(0..<10, id: \.self) { _ in
                                RosterRowSkeleton()
                                    .padding(.horizontal, 20)
                            }
                        } else if filteredRoster.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "person.slash")
                                    .font(.system(size: 40))
                                    .foregroundColor(.bravesSubtext)
                                Text("No players found")
                                    .font(BravesFont.subheading())
                                    .foregroundColor(.bravesSubtext)
                            }
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filteredRoster) { entry in
                                    RosterRow(entry: entry)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 16)
                }
                .searchable(text: $searchText, prompt: "Search players...")
            }
            .navigationTitle("Active Roster")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(BravesFont.label(12))
                .foregroundColor(isSelected ? .bravesNavy : .bravesSubtext)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.bravesGold : Color.bravesCardBg)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.bravesGold.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Roster Stat Chip
struct RosterStatChip: View {
    let label: String
    let value: String
    var color: Color = .white

    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(BravesFont.mono(16))
                .fontWeight(.black)
                .foregroundColor(color)
            Text(label)
                .font(BravesFont.label(11))
                .foregroundColor(.bravesSubtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .bravesCard()
    }
}

// MARK: - Roster Row
struct RosterRow: View {
    let entry: RosterEntry
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 14) {
            // Jersey number
            ZStack {
                Circle()
                    .fill(Color.bravesNavy)
                    .frame(width: 44, height: 44)
                    .overlay(Circle().strokeBorder(Color.bravesGold.opacity(0.3), lineWidth: 1))

                Text(entry.jerseyNumber.map { "#\($0)" } ?? "--")
                    .font(BravesFont.mono(entry.jerseyNumber != nil ? 14 : 11))
                    .fontWeight(.black)
                    .foregroundColor(entry.jerseyNumber != nil ? .bravesGold : .bravesSubtext)
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.person.fullName)
                    .font(BravesFont.subheading(14))
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    if let posType = entry.position?.type {
                        Text(posType)
                            .font(BravesFont.label(10))
                            .foregroundColor(.bravesSubtext)
                    }
                }
            }

            Spacer()

            // Position badge
            PositionBadge(abbreviation: entry.position?.abbreviation)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.bravesCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.bravesGold.opacity(0.1), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.05)) {
                appeared = true
            }
        }
    }
}

// MARK: - Skeleton Loading Row
struct RosterRowSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Color.bravesCardBg)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bravesCardBg)
                    .frame(width: 140, height: 14)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.bravesCardBg)
                    .frame(width: 80, height: 10)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.bravesCardBg)
                .frame(width: 32, height: 22)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(Color.bravesCardBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(shimmer ? 0.4 : 0.8)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: shimmer)
        .onAppear { shimmer = true }
    }
}
