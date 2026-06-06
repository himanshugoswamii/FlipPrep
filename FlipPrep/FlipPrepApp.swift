//
//  FlipPrepApp.swift
//  FlipPrep
//
//  Created by Himanshu Goswami on 6/6/26.
//

import SwiftUI
import CoreData

@main
struct FlipPrepApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
