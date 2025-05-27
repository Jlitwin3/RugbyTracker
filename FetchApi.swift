//
//  FetchApi.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import Foundation
import SwiftUI

public class FetchAPI: ObservableObject {
    public static let shared = FetchAPI()
    private let apiKey = "9449b27e60mshb3b0d52118a4be1p15b4fbjsn5d30f72e0fbd"
    private let baseURL = "https://api-rugby.p.rapidapi.com"
    
    private init() {}
    
    public func fetchLeagues(completion: @escaping (Result<[League], Error>) -> Void) {
        fetchData(endpoint: "/leagues", type: [League].self, completion: completion)
    }
    
    public func fetchTeams(completion: @escaping (Result<[Team], Error>) -> Void) {
        fetchData(endpoint: "/teams", type: [Team].self, completion: completion)
    }
    
    public func fetchPlayers(completion: @escaping (Result<[Player], Error>) -> Void) {
        fetchData(endpoint: "/players", type: [Player].self, completion: completion)
    }
    
    public func fetchMatches(completion: @escaping (Result<[RugbyMatch], Error>) -> Void) {
        fetchData(endpoint: "/matches", type: [RugbyMatch].self, completion: completion)
    }
    
    public func fetchLeagueDetails(leagueId: Int, completion: @escaping (Result<LeagueDetails, Error>) -> Void) {
        fetchData(endpoint: "/leagues/\(leagueId)", type: LeagueDetails.self, completion: completion)
    }
    
    public func fetchTeamDetails(teamId: Int, completion: @escaping (Result<TeamDetails, Error>) -> Void) {
        fetchData(endpoint: "/teams/\(teamId)", type: TeamDetails.self, completion: completion)
    }
    
    private func fetchData<T: Decodable>(endpoint: String, type: T.Type, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        request.addValue("api-rugby.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedData = try decoder.decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}

// Additional model for league details
public struct LeagueDetails: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let country: String
    public let season: String
    public let currentRound: Int?
    public let totalRounds: Int?
    
    public init(id: Int, name: String, country: String, season: String, currentRound: Int?, totalRounds: Int?) {
        self.id = id
        self.name = name
        self.country = country
        self.season = season
        self.currentRound = currentRound
        self.totalRounds = totalRounds
    }
}

// Additional model for team details
public struct TeamDetails: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let country: String
    public let league: String
    public let season: String
    public let position: Int?
    public let points: Int?
    
    public init(id: Int, name: String, country: String, league: String, season: String, position: Int?, points: Int?) {
        self.id = id
        self.name = name
        self.country = country
        self.league = league
        self.season = season
        self.position = position
        self.points = points
    }
}

// Update RugbyMatch model to match API response
public struct RugbyMatch: Codable, Identifiable {
    public let id: Int
    public let matchId: Int
    public let homeTeam: String
    public let awayTeam: String
    public let score: String?
    public let date: String?
    public let status: String?
    public let league: String?
    
    public init(id: Int, matchId: Int, homeTeam: String, awayTeam: String, score: String?, date: String?, status: String?, league: String?) {
        self.id = id
        self.matchId = matchId
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.score = score
        self.date = date
        self.status = status
        self.league = league
    }
}

// Update RugbyMatchView to show more match details
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
                List(matches, id: \.matchId) { match in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(match.homeTeam) vs \(match.awayTeam)")
                            .font(.headline)
                        if let score = match.score {
                            Text("Score: \(score)")
                                .font(.subheadline)
                        }
                        if let date = match.date {
                            Text("Date: \(date)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let status = match.status {
                            Text("Status: \(status)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        if let league = match.league {
                            Text("League: \(league)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
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


