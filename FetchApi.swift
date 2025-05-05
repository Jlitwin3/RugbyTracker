//
//  FetchApi.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import Foundation

class FetchAPI {
    static let shared = FetchAPI()
    private let apiKey = "9449b27e60mshb3b0d52118a4be1p15b4fbjsn5d30f72e0fbd"
    private let baseURL = "https://api-rugby.p.rapidapi.com"
    
    private init() {}
    
    func fetchLeagues(completion: @escaping (Result<[League], Error>) -> Void) {
        fetchData(endpoint: "/leagues", type: [League].self, completion: completion)
    }
    
    func fetchTeams(completion: @escaping (Result<[Team], Error>) -> Void) {
        fetchData(endpoint: "/teams", type: [Team].self, completion: completion)
    }
    
    func fetchPlayers(completion: @escaping (Result<[Player], Error>) -> Void) {
        fetchData(endpoint: "/players", type: [Player].self, completion: completion)
    }
    
    func fetchMatches(completion: @escaping (Result<[RugbyMatch], Error>) -> Void) {
        fetchData(endpoint: "/seasons", type: [RugbyMatch].self, completion: completion)
    }
    
    private func fetchData<T: Decodable>(endpoint: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("api-rugby.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct RugbyMatch: Codable {
    let matchID: Int
    let homeTeam: String
    let awayTeam: String
    let score: String?
}

struct RugbyMatchView: View {
    @State private var matches: [RugbyMatch] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading matches...")
            } else if let error = errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                    Button("Retry") {
                        fetchMatches()
                    }
                }
            } else {
                List(matches, id: \.matchID) { match in
                    VStack(alignment: .leading) {
                        Text("\(match.homeTeam) vs \(match.awayTeam)")
                            .font(.headline)
                        if let score = match.score {
                            Text("Score: \(score)")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchMatches()
        }
    }
    
    private func fetchMatches() {
        isLoading = true
        errorMessage = nil
        
        FetchAPI.shared.fetchMatches { result in
            isLoading = false
            switch result {
            case .success(let data):
                matches = data
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
}


