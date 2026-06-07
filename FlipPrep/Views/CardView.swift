import SwiftUI

struct CardView: View {
    let question: String
    let answer: String
    let color: Color

    @State private var isFlipped = false
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Back of card (Answer)
            CardFace(text: answer, label: "ANSWER", color: color, isAnswer: true)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(rotation - 180), axis: (x: 0, y: 1, z: 0))

            // Front of card (Question)
            CardFace(text: question, label: "QUESTION", color: color, isAnswer: false)
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
        }
        .onTapGesture {
            flipCard()
        }
    }

    func flipCard() {
        let duration = 0.4
        withAnimation(.easeInOut(duration: duration)) {
            rotation += 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            isFlipped.toggle()
        }
    }

    func resetCard() {
        isFlipped = false
        rotation = 0
    }
}

struct CardFace: View {
    let text: String
    let label: String
    let color: Color
    let isAnswer: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(isAnswer ? color : Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 4)

            VStack(spacing: 20) {
                // Label badge
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isAnswer ? .white.opacity(0.8) : color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(isAnswer ? Color.white.opacity(0.2) : color.opacity(0.12))
                    .cornerRadius(20)

                // Card text
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(isAnswer ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                if !isAnswer {
                    Text("Tap to reveal answer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 300)
        .padding(.horizontal, 24)
    }
}

#Preview {
    CardView(
        question: "What is the time complexity of binary search?",
        answer: "O(log n) — each step halves the search space.",
        color: .blue
    )
}//
//  CardView.swift
//  FlipPrep
//
//  Created by Himanshu Goswami on 6/6/26.
//

