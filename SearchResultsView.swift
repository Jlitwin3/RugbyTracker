import SwiftUI

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