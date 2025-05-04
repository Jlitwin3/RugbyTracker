//
//  ContentView.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
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
                VStack {
                    Text("Games")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    Spacer()
                }
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
    }
}

struct SearchResultsView: View {
    @Binding var searchText: String
    @State private var leagues: [League] = []
    @State private var teams: [Team] = []
    @State private var players: [Player] = []
    
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
        .onAppear {
            fetchLeagues()
            fetchTeams()
            fetchPlayers()
        }
    }
    
    func fetchLeagues() {
        let urlString = "https://api-rugby.p.rapidapi.com/leagues"
        fetchData(urlString: urlString, type: [League].self) { self.leagues = $0 }
    }

    func fetchTeams() {
        let urlString = "https://api-rugby.p.rapidapi.com/teams"
        fetchData(urlString: urlString, type: [Team].self) { self.teams = $0 }
    }

    func fetchPlayers() {
        let urlString = "https://api-rugby.p.rapidapi.com/players"
        fetchData(urlString: urlString, type: [Player].self) { self.players = $0 }
    }

    func fetchData<T: Decodable>(urlString: String, type: T.Type, completion: @escaping (T) -> Void) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(decodedData)
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
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


