import SwiftUI

/// Screen 1a: "What's your mood this week?" — pick one of four moods.
struct MoodCheckInView: View {
    @EnvironmentObject private var moodStore: MoodStore
    @State private var selection: Mood?

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("WEEKLY CHECK-IN")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(Theme.neon)
                Text("What's your mood\nthis week?")
                    .font(.system(size: 34, weight: .bold))
                Text("We'll build a playlist to match it.")
                    .foregroundStyle(Theme.secondaryText)
            }
            .padding(.top, 32)

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(Mood.allCases) { mood in
                    MoodTile(mood: mood, isSelected: selection == mood)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) { selection = mood }
                        }
                }
            }

            Spacer()

            Button {
                if let selection { moodStore.select(selection) }
            } label: {
                Text("Create my playlist")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Capsule().fill(selection == nil ? Theme.card : Theme.neon))
                    .foregroundStyle(selection == nil ? Theme.secondaryText : .white)
            }
            .disabled(selection == nil)
            .neonGlow(selection == nil ? .clear : Theme.neon)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
        .foregroundStyle(.white)
        .onAppear { selection = moodStore.currentMood }
    }
}

private struct MoodTile: View {
    let mood: Mood
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: mood.icon)
                .font(.title)
                .foregroundStyle(LinearGradient(colors: mood.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            Spacer()
            Text(mood.title)
                .font(.title3.weight(.bold))
            Text(mood.subtitle)
                .font(.caption)
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .overlay(
                    LinearGradient(colors: mood.colors.map { $0.opacity(isSelected ? 0.35 : 0.12) },
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Theme.neon : .white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
        )
        .neonGlow(isSelected ? Theme.neon : .clear, radius: 14)
        .scaleEffect(isSelected ? 1.03 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}
