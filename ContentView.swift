import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BravesViewModel()

    // Braves colors
    private let bravesRed = Color(red: 206/255, green: 17/255, blue: 38/255)
    private let bravesNavy = Color(red: 12/255, green: 35/255, blue: 64/255)

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [bravesNavy.opacity(0.95), .black]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    headerImage

                    Text("Atlanta Braves")
                        .font(.custom(CustomFont.title, size: 36))
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    Group {
                        SectionHeader(title: "Team Info", color: bravesRed)
                        infoCard {
                            infoRow(label: "Team", value: vm.team?.name)
                            infoRow(label: "Location", value: vm.team?.locationName)
                            infoRow(label: "Short Name", value: "ATL Braves")
                        }

                        SectionHeader(title: "League", color: bravesRed)
                        infoCard {
                            infoRow(label: "League", value: vm.team?.league?.name)
                            infoRow(label: "Division", value: vm.team?.division?.name)
                        }

                        SectionHeader(title: "Venue", color: bravesRed)
                        infoCard {
                            infoRow(label: "Stadium", value: vm.team?.venue?.name)
                        }
                        
                        SectionHeader(title: "Season Record", color: bravesRed)
                        infoCard {
                            let stats = vm.seasonStats
                            infoRow(label: "Wins", value: stats?.wins.map { String($0) })
                            infoRow(label: "Losses", value: stats?.losses.map { String($0) })
                            infoRow(label: "Win %", value: stats?.winPercentage)
                            infoRow(label: "Games Played", value: stats?.gamesPlayed.map { String($0) })
                        }
                        
                        SectionHeader(title: "Roster", color: bravesRed)
                        infoCard {
                            if vm.roster.isEmpty {
                                Text("No active players available.")
                                    .font(.custom(CustomFont.body, size: 18))
                                    .foregroundStyle(.white)
                            } else {
                                // Show first 10 players for brevity
                                ForEach(vm.roster.prefix(10)) { entry in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.person.fullName ?? "Player")
                                            .font(.custom(CustomFont.body, size: 18))
                                            .foregroundStyle(.white)
                                        HStack(spacing: 12) {
                                            Text(entry.position?.abbreviation ?? "-")
                                                .font(.custom(CustomFont.heading, size: 14))
                                                .foregroundStyle(bravesRed)
                                            if let num = entry.jerseyNumber {
                                                Text("#\(num)")
                                                    .font(.custom(CustomFont.body, size: 14))
                                                    .foregroundStyle(.white.opacity(0.8))
                                            }
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    if entry.id != vm.roster.prefix(10).last?.id {
                                        Divider().background(.white.opacity(0.1))
                                    }
                                }
                            }
                        }
                    }

                    if vm.isLoading {
                        ProgressView().tint(.white).padding()
                    }
                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.custom(CustomFont.body, size: 16))
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .task { await vm.fetchTeam() }
    }

    private var headerImage: some View {
        // Prefer a local asset named "atlanta braves" if present; otherwise fall back to remote image.
        if UIImage(named: "Braves Image") != nil {
            return AnyView(
                Image("Braves Image")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipped()
                    .overlay(
                        LinearGradient(colors: [Color.black.opacity(0.0), bravesNavy.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 8)
                    .cornerRadius(16)
                    .padding(.horizontal)
            )
        } else {
            return AnyView(
                AsyncImage(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/7/79/Truist_Park.jpg")) { phase in
                    switch phase {
                    case .empty:
                        ZStack { Rectangle().fill(.gray.opacity(0.2)) ; ProgressView() }
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .overlay(
                                LinearGradient(colors: [Color.black.opacity(0.0), bravesNavy.opacity(0.6)], startPoint: .center, endPoint: .bottom)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 8)
                            .cornerRadius(16)
                            .padding(.horizontal)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal)
                    @unknown default:
                        EmptyView()
                    }
                }
            )
        }
    }

    private func infoCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            content()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }

    private func infoRow(label: String, value: String?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.custom(CustomFont.heading, size: 18))
                .foregroundStyle(bravesRed)
            Spacer(minLength: 16)
            Text(value ?? "—")
                .font(.custom(CustomFont.body, size: 18))
                .foregroundStyle(.white)
        }
        .lineSpacing(4)
    }
}

private struct SectionHeader: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.custom(CustomFont.heading, size: 22))
            .foregroundStyle(color)
            .padding(.horizontal)
            .padding(.top, 8)
    }
}

// Helper to keep font names centralized
enum CustomFont {
    // Replace these with your real font postscript names once added to the project bundle and Info.plist
    static let title = "Avenir-Black"      // placeholder custom font
    static let heading = "Avenir-Heavy"    // placeholder custom font
    static let body = "Avenir-Book"        // placeholder custom font
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}

