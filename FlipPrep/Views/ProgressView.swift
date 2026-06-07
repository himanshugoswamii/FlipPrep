import SwiftUI
import CoreData
import Charts

struct ProgressScreen: View {
    @Environment(\.managedObjectContext) var context

    @FetchRequest(entity: Flashcard.entity(), sortDescriptors: [])
    var allCards: FetchedResults<Flashcard>

    @FetchRequest(entity: Flashcard.entity(), sortDescriptors: [],
                  predicate: NSPredicate(format: "ismastered == true"))
    var masteredCards: FetchedResults<Flashcard>

    let categories = ["DSA", "System Design", "Behavioral", "Language"]
    let categoryColors: [String: Color] = [
        "DSA": .blue,
        "System Design": .purple,
        "Behavioral": .orange,
        "Language": .pink
    ]

    var overallProgress: Double {
        guard allCards.count > 0 else { return 0 }
        return Double(masteredCards.count) / Double(allCards.count)
    }

    func cardCount(for category: String) -> Int {
        allCards.filter { $0.category == category }.count
    }

    func masteredCount(for category: String) -> Int {
        masteredCards.filter { $0.category == category }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Overall progress card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Overall Progress")
                            .font(.headline)

                        HStack(alignment: .bottom, spacing: 8) {
                            Text("\(Int(overallProgress * 100))%")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.blue)
                            Text("mastered")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 8)
                        }

                        ProgressView(value: overallProgress)
                            .tint(overallProgress == 0 ? .gray : .blue)
                            .scaleEffect(x: 1, y: 2, anchor: .center)

                        Text("\(masteredCards.count) of \(allCards.count) cards mastered")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Category")
                            .font(.headline)
                            .padding(.horizontal)

                        Chart {
                            ForEach(categories, id: \.self) { category in
                                BarMark(
                                    x: .value("Category", category),
                                    y: .value("Mastered", masteredCount(for: category))
                                )
                                .foregroundStyle(categoryColors[category] ?? .blue)
                                .cornerRadius(6)

                                BarMark(
                                    x: .value("Category", category),
                                    y: .value("Remaining", cardCount(for: category) - masteredCount(for: category))
                                )
                                .foregroundStyle(Color.gray.opacity(0.2))
                                .cornerRadius(6)
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    // Per category breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Breakdown")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(categories, id: \.self) { category in
                            let total = cardCount(for: category)
                            let mastered = masteredCount(for: category)
                            let progress = total > 0 ? Double(mastered) / Double(total) : 0

                            HStack(spacing: 16) {
                                Circle()
                                    .fill(categoryColors[category] ?? .blue)
                                    .frame(width: 12, height: 12)

                                Text(category)
                                    .font(.subheadline)
                                    .frame(width: 110, alignment: .leading)

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.15))
                                            .frame(height: 8)
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(categoryColors[category] ?? .blue)
                                            .frame(width: geo.size.width * progress, height: 8)
                                    }
                                }
                                .frame(height: 8)

                                Text("\(mastered)/\(total)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .frame(width: 36, alignment: .trailing)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
                    .padding(.horizontal)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .navigationTitle("Progress")
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ProgressScreen()
        .environment(\.managedObjectContext, PersistenceController.shared.context)
}
