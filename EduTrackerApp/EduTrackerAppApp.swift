//
//  EduTrackerAppApp.swift
//  EduTrackerApp
//
//  Created by Adilet Beishekeyev on 18.12.2025.
//

import SwiftUI

@main
struct EduTrackerAppApp: App {
    @StateObject private var apiService = APIService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(apiService)
        }
    }
}
