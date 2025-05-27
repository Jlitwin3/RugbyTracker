//
//  ContentView.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import SwiftUI
import Foundation

// Make sure FetchAPI is accessible
@_exported import struct Foundation.URL
@_exported import class Foundation.URLSession

struct ContentView: View {
    @StateObject private var fetchAPI = FetchAPI.shared
    @State private var isLoggedIn = false
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        if isLoggedIn {
            // Main Content
            VStack(spacing: 0) {
                // Title Bar
                Text("RugbyTracker.net")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search leagues, teams, players", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // TabView Content
                TabView(selection: $selectedTab) {
                    // Home Tab
                    VStack {
                        Text("Home")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(0)
                    
                    // Games Tab
                    RugbyMatchView()
                        .tabItem {
                            Image(systemName: "sportscourt.fill")
                            Text("Games")
                        }
                        .tag(1)
                    
                    // Leagues Tab
                    SearchResultsView(searchText: $searchText)
                        .tabItem {
                            Image(systemName: "trophy.fill")
                            Text("Leagues")
                        }
                        .tag(2)
                    
                    // Following Tab
                    VStack {
                        Text("Following")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                    }
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Following")
                    }
                    .tag(3)
                }
                .accentColor(.green)
            }
            .background(Color(.systemGray6))
        } else {
            // Login Screen
            LoginView(isLoggedIn: $isLoggedIn)
        }
    }
}

@main
struct RugbyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}


