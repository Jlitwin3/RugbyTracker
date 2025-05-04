//
//  Search.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import SwiftUI

let MyApiKey = "9449b27e60mshb3b0d52118a4be1p15b4fbjsn5d30f72e0fbd"

struct League: Identifiable, Codable {
    let id: Int
    let name: String
}

struct Team: Identifiable, Codable {
    let id: Int
    let name: String
}

struct Player: Identifiable, Codable {
    let id: Int
    let name: String
    let team: String?
}

struct SearchView: View {
    @State private var leagues: [League] = []
    @State private var teams: [Team] = []
    @State private var players: [Player] = []
    @State private var searchText = ""
    @State private var isExpanded = false
    
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
        VStack(spacing: 0) {
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
            .onTapGesture {
                isExpanded = true
            }
            
            // Results List (only shown when expanded)
            if isExpanded {
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
                            .onTapGesture {
                                isExpanded = false
                                // Handle item selection here
                            }
                            
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .transition(.move(edge: .top))
            }
            
            Spacer()
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

#Preview {
    SearchView()
}


