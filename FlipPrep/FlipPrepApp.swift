import SwiftUI

@main
struct FlipPrepApp: App {
    let persistence = PersistenceController.shared

    init() {
        SeedData.seedIfNeeded(context: persistence.context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.context)
        }
    }
}
