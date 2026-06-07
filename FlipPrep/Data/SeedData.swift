import CoreData

struct SeedData {
    static let cards: [(question: String, answer: String, category: String)] = [

        // MARK: - DSA
        ("What is the time complexity of binary search?",
         "O(log n) — each step halves the search space.",
         "DSA"),
        ("Explain the difference between BFS and DFS.",
         "BFS uses a queue and explores level by level. DFS uses a stack (or recursion) and goes deep before backtracking.",
         "DSA"),
        ("What is a hash collision and how is it handled?",
         "When two keys map to the same bucket. Handled via chaining (linked list per bucket) or open addressing (probe for next slot).",
         "DSA"),
        ("What is the difference between an array and a linked list?",
         "Arrays have O(1) random access but O(n) insert/delete. Linked lists have O(1) insert/delete at head but O(n) access.",
         "DSA"),
        ("What is dynamic programming?",
         "Breaking a problem into overlapping subproblems and storing results (memoization/tabulation) to avoid recomputation.",
         "DSA"),

        // MARK: - System Design
        ("What is horizontal vs vertical scaling?",
         "Vertical = bigger machine (more CPU/RAM). Horizontal = more machines. Horizontal is preferred for large-scale systems.",
         "System Design"),
        ("What is a load balancer and why is it used?",
         "Distributes incoming traffic across multiple servers to prevent overload and improve availability.",
         "System Design"),
        ("Explain CAP theorem.",
         "A distributed system can only guarantee 2 of 3: Consistency, Availability, Partition Tolerance.",
         "System Design"),
        ("What is the difference between SQL and NoSQL?",
         "SQL is relational, structured, ACID-compliant. NoSQL is flexible schema, scales horizontally, trades consistency for speed.",
         "System Design"),
        ("What is a CDN?",
         "Content Delivery Network — caches static assets at edge servers close to users to reduce latency.",
         "System Design"),

        // MARK: - Behavioral
        ("Tell me about a time you handled a conflict in a team.",
         "Use STAR: Situation, Task, Action, Result. Focus on communication, empathy, and resolution.",
         "Behavioral"),
        ("Describe a project where you had to learn something quickly.",
         "Use STAR. Highlight self-learning, resourcefulness, and the outcome delivered under time pressure.",
         "Behavioral"),
        ("Tell me about a time you failed.",
         "Use STAR. Be honest about the failure, focus on what you learned and how you improved afterward.",
         "Behavioral"),
        ("Why do you want to work at this company?",
         "Research the company. Mention specific products, mission, or tech stack. Tie it to your goals.",
         "Behavioral"),
        ("Where do you see yourself in 5 years?",
         "Show ambition but realism. Align your growth with the role — e.g. senior engineer, tech lead, or specialized domain.",
         "Behavioral"),

        // MARK: - Language
        ("What is the difference between a class and a struct in Swift?",
         "Classes are reference types (heap), structs are value types (stack). Structs are preferred in SwiftUI for immutability.",
         "Language"),
        ("What is optional chaining in Swift?",
         "Safely accessing properties on an optional. If the optional is nil, the whole chain returns nil instead of crashing.",
         "Language"),
        ("What is the difference between == and === in Swift?",
         "== checks value equality. === checks reference equality (same object in memory). Only applies to classes.",
         "Language"),
        ("What is a closure in Swift?",
         "A self-contained block of code that can capture and store references to variables from its surrounding context.",
         "Language"),
        ("What is the difference between let and var in Swift?",
         "let declares a constant (immutable). var declares a variable (mutable).",
         "Language")
    ]

    static func seedIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        let count = (try? context.fetch(request))?.count ?? 0
        guard count == 0 else { return }

        for card in cards {
            let flashcard = Flashcard(context: context)
            flashcard.id = UUID()
            flashcard.question = card.question
            flashcard.answer = card.answer
            flashcard.category = card.category
            flashcard.interval = 1
            flashcard.easeFactor = 2.5
            flashcard.nextReviewDate = Date()
            flashcard.ismastered = false
        }

        try? context.save()
        print("✅ Seed data inserted")
    }
}
