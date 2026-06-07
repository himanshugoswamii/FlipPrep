import SwiftUI
import CoreData

struct HomeView: View {
    let categories = ["DSA", "System Design", "Behavioral", "Language"]
    let categoryIcons = ["DSA": "chevron.left.forwardslash.chevron.right",
                         "System Design": "server.rack",
                         "Behavioral": "person.2.fill",
                         "Language": "swift"]
    let categoryColors: [String: Color] = [
        "DSA": .blue,
        "System Design": .purple,
        "Behavioral": .orange,
        "Language": .pink
    ]

    @Environment(\.managedObjectContext) var context
    @State private var selectedCategory: String? = nil
    @AppStorage("lastStudyDate") private var lastStudyDateString: String = ""
    @AppStorage("streakCount") private var streakCount: Int = 0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("FlipPrep 🎯")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Spacer()
                        // Streak badge
                        HStack(spacing: 4) {
                            Text("🔥")
                            Text("\(streakCount) day\(streakCount == 1 ? "" : "s")")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(20)
                    }
                    Text("Pick a category to study")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .onAppear { updateStreak() }

                // Category Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: SessionView(category: category, color: categoryColors[category] ?? .blue)
                            .environment(\.managedObjectContext, context)) {
                            CategoryCard(
                                title: category,
                                icon: categoryIcons[category] ?? "square.stack",
                                color: categoryColors[category] ?? .blue,
                                context: context
                            )
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayString = formatter.string(from: today)

        if lastStudyDateString == todayString {
            return // already counted today
        }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let yesterdayString = formatter.string(from: yesterday)

        if lastStudyDateString == yesterdayString {
            streakCount += 1 // continued streak
        } else {
            streakCount = 1 // reset streak
        }

        lastStudyDateString = todayString
    }
}

struct CategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let context: NSManagedObjectContext

    var cardCount: Int {
        let request: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", title)
        return (try? context.fetch(request))?.count ?? 0
    }

    var masteredCount: Int {
        let request: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@ AND ismastered == true", title)
        return (try? context.fetch(request))?.count ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            // Progress
            Text("\(masteredCount)/\(cardCount) mastered")
                .font(.caption)
                .foregroundColor(.secondary)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: cardCount > 0 ? geo.size.width * CGFloat(masteredCount) / CGFloat(cardCount) : 0, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.shared.context)


}//
//  HomeView.swift
//  FlipPrep
//
//  Created by Himanshu Goswami on 6/6/26.
//

