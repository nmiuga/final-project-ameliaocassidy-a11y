// BravesTheme.swift
// Atlanta Braves App - Design System & Theme

import SwiftUI

// MARK: - Braves Color Palette
extension Color {
    static let bravesNavy      = Color(red: 0.008, green: 0.161, blue: 0.329)  // #002657
    static let bravesRed       = Color(red: 0.796, green: 0.122, blue: 0.188)  // #CE1E30
    static let bravesGold      = Color(red: 0.878, green: 0.702, blue: 0.310)  // #E0B44F
    static let bravesLightNavy = Color(red: 0.06,  green: 0.22,  blue: 0.42)
    static let bravesCream     = Color(red: 0.98,  green: 0.96,  blue: 0.92)
    static let bravesCardBg    = Color(red: 0.04,  green: 0.13,  blue: 0.28)
    static let bravesSubtext   = Color(red: 0.65,  green: 0.75,  blue: 0.85)
}

// MARK: - Typography
struct BravesFont {
    // Title - large hero display
    static func title(_ size: CGFloat = 36) -> Font {
        .system(size: size, weight: .black, design: .serif)
    }

    // Heading - section headers
    static func heading(_ size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    // Subheading - card headers
    static func subheading(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    // Body - general text
    static func body(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    // Mono - stats/numbers
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    // Label - small caps/labels
    static func label(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

// MARK: - Card Modifier
struct BravesCardModifier: ViewModifier {
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.bravesCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.bravesGold.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func bravesCard(padding: CGFloat = 16) -> some View {
        self.modifier(BravesCardModifier(padding: padding))
    }
}

// MARK: - Stat Box Component
struct StatBox: View {
    let label: String
    let value: String
    var accent: Color = .bravesGold

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(BravesFont.mono(20))
                .fontWeight(.black)
                .foregroundColor(accent)
            Text(label)
                .font(BravesFont.label(10))
                .foregroundColor(.bravesSubtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.bravesNavy.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.bravesRed)
                .font(.system(size: 14, weight: .bold))
            Text(title.uppercased())
                .font(BravesFont.label(13))
                .foregroundColor(.bravesRed)
                .tracking(1.5)
            Spacer()
            Rectangle()
                .fill(Color.bravesRed.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Loading View
struct BravesLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.bravesNavy.ignoresSafeArea()
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color.bravesGold.opacity(0.2), lineWidth: 3)
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color.bravesRed, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                        .onAppear { rotation = 360 }
                }
                Text("Loading Braves Data...")
                    .font(BravesFont.subheading(14))
                    .foregroundColor(.bravesSubtext)
            }
        }
    }
}

// MARK: - Position Badge
struct PositionBadge: View {
    let abbreviation: String?

    var badgeColor: Color {
        switch abbreviation {
        case "SP", "RP", "CL": return .bravesRed
        case "C": return .bravesGold
        case "1B", "2B", "3B", "SS": return Color(red: 0.2, green: 0.6, blue: 0.9)
        case "LF", "CF", "RF", "OF": return Color(red: 0.2, green: 0.8, blue: 0.4)
        default: return .bravesSubtext
        }
    }

    var body: some View {
        Text(abbreviation ?? "—")
            .font(BravesFont.label(10))
            .foregroundColor(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(badgeColor)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
