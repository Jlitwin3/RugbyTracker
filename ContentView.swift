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

struct SearchResultsView: View {
    @StateObject private var fetchAPI = FetchAPI.shared
    @Binding var searchText: String
    @State private var leagues: [League] = []
    @State private var teams: [Team] = []
    @State private var players: [Player] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var filteredResults: [(id: Int, name: String, type: String)] {
        let allData = leagues.map { ($0.id, $0.name, "League") } +
                      teams.map { ($0.id, $0.name, "Team") } +
                      players.map { ($0.id, $0.name, "Player") }
        
        if searchText.isEmpty {
            return allData
        } else {
            return allData.filter { $0.1.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let error = errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        fetchAllData()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredResults, id: \.id) { item in
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(.systemBackground))
                            
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            fetchAllData()
        }
    }
    
    private func fetchAllData() {
        isLoading = true
        errorMessage = nil
        
        let group = DispatchGroup()
        
        group.enter()
        fetchAPI.fetchLeagues { result in
            switch result {
            case .success(let data):
                self.leagues = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            group.leave()
        }
        
        group.enter()
        fetchAPI.fetchTeams { result in
            switch result {
            case .success(let data):
                self.teams = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            group.leave()
        }
        
        group.enter()
        fetchAPI.fetchPlayers { result in
            switch result {
            case .success(let data):
                self.players = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            isLoading = false
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


