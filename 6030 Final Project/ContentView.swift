// ContentView.swift
// Atlanta Braves App - Root Tab Navigator

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = BravesViewModel()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            if vm.isLoadingTeam && vm.team == nil {
                BravesLoadingView()
                    .transition(.opacity)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)

                    RosterView()
                        .tabItem {
                            Label("Roster", systemImage: "person.3.fill")
                        }
                        .tag(1)

                    StandingsView()
                        .tabItem {
                            Label("Standings", systemImage: "list.number")
                        }
                        .tag(2)

                    ScheduleView()
                        .tabItem {
                            Label("Schedule", systemImage: "calendar")
                        }
                        .tag(3)
                }
                .environmentObject(vm)
                .tint(.bravesGold)
                .onAppear {
                    // Customize tab bar appearance
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(Color.bravesNavy)

                    // Normal item
                    let normalAttrs: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor(Color.bravesSubtext)
                    ]
                    appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttrs
                    appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.bravesSubtext)

                    // Selected item
                    let selectedAttrs: [NSAttributedString.Key: Any] = [
                        .foregroundColor: UIColor(Color.bravesGold)
                    ]
                    appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttrs
                    appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.bravesGold)

                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance

                    // Navigation bar
                    let navAppearance = UINavigationBarAppearance()
                    navAppearance.configureWithOpaqueBackground()
                    navAppearance.backgroundColor = UIColor(Color.bravesNavy)
                    navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                    navAppearance.largeTitleTextAttributes = [
                        .foregroundColor: UIColor.white,
                        .font: UIFont.systemFont(ofSize: 32, weight: .black)
                    ]
                    UINavigationBar.appearance().standardAppearance = navAppearance
                    UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
                }
            }
        }
        .task {
            await vm.loadAll()
        }
    }
}

#Preview {
    ContentView()
}
