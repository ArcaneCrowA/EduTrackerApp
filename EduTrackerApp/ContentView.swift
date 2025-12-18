//
//  ContentView.swift
//  EduTrackerApp
//
//  Created by Adilet Beishekeyev on 18.12.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var apiService: APIService
    
    var body: some View {
        if apiService.token == nil {
            LoginView()
        } else {
            NavigationSplitView {
                List {
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    if apiService.currentUser?.isAdmin == true {
                        NavigationLink(destination: AdminDashboard()) {
                            Label("Admin Dashboard", systemImage: "shield.fill")
                        }
                    } else {
                        NavigationLink(destination: StudentDashboard()) {
                            Label("Student Dashboard", systemImage: "graduationcap.fill")
                        }
                    }
                }
                .navigationTitle("EduTracker")
            } detail: {
                NavigationStack {
                    if let user = apiService.currentUser {
                        if user.isAdmin {
                            AdminDashboard()
                        } else {
                            StudentDashboard()
                        }
                    } else {
                        ProgressView("Loading...")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
