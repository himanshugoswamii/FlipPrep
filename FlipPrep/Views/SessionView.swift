//
//  SessionView.swift
//  FlipPrep
//
//  Created by Himanshu Goswami on 6/6/26.
//

import SwiftUI
import CoreData

struct SessionView: View {
    let category: String
    let color: Color

    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss

    @State private var cards: [Flashcard] = []
    @State private var currentIndex = 0
    @State private var sessionComplete = false
    @State private var cardKey = UUID()

    var currentCard: Flashcard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    var progress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(currentIndex) / Double(cards.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 6)
            .padding(.horizontal, 24)
            .padding(.top, 12)

            Spacer()

            if sessionComplete {
                // Session complete screen
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 64))
                    Text("Session Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("You reviewed all \(cards.count) cards in \(category).")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: { dismiss() }) {
                        Text("Back to Home")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(color)
                            .cornerRadius(16)
                            .padding(.horizontal, 40)
                    }
                }
            } else if let card = currentCard {
                // Card
                CardView(
                    question: card.question ?? "",
                    answer: card.answer ?? "",
                    color: color
                )
                .id(cardKey)

                Spacer()

                // Action buttons
                HStack(spacing: 16) {
                    // Review Again
                    Button(action: { rateCard(known: false) }) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                            Text("Review Again")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(16)
                    }

                    // Got It
                    Button(action: { rateCard(known: true) }) {
                        VStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text("Got It!")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .onAppear { loadCards() }
    }

    func loadCards() {
        let request: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        request.predicate = NSPredicate(format: "category == %@", category)
        request.sortDescriptors = [NSSortDescriptor(key: "nextReviewDate", ascending: true)]
        cards = (try? context.fetch(request)) ?? []
    }

    func rateCard(known: Bool) {
        guard let card = currentCard else { return }
        applySpacedRepetition(card: card, known: known)

        withAnimation {
            if currentIndex + 1 >= cards.count {
                sessionComplete = true
            } else {
                currentIndex += 1
                cardKey = UUID()
            }
        }
    }

    func applySpacedRepetition(card: Flashcard, known: Bool) {
        if known {
            card.interval = max(card.interval * 2, 1)
            card.easeFactor = min(card.easeFactor + 0.1, 3.0)
            card.ismastered = card.interval >= 8
        } else {
            card.interval = 1
            card.easeFactor = max(card.easeFactor - 0.2, 1.3)
            card.ismastered = false
        }
        card.nextReviewDate = Calendar.current.date(
            byAdding: .day,
            value: Int(card.interval),
            to: Date()
        )
        try? context.save()
    }
}
