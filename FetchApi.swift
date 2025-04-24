//
//  FetchApi.swift
//  RugbyTracker
//
//  Created by jesse litwin on 4/2/25.
//

import Foundation
let MyAPiKey = "9449b27e60mshb3b0d52118a4be1p15b4fbjsn5d30f72e0fbd"
struct RugbyMatch: Codable {
    let matchID: Int
    let homeTeam: String
    let awayTeam: String
    let score: String?
}

func fetchMatches() {
    let urlStrign = "https://api-rugby.p.rapidapi.com/seasons"
    guard let url = URL(string: urlStrign) else { return }
    
    var request = URLRequest(url: url)
    request.addValue(MyAPiKey, forHTTPHeaderField: "X-RapidAPI-Key)
    request.addValue("application/json", forHTTPHeaderField: "Accept")
                     
    URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let matches = try JSONDecoder().decode([RugbyMatch].self, from: data)
                print(matches) // Use this data in your UI
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
}

struct RugbyMatchView: View {
    @State private var matches: [RugbyMatch] = []
    
    var body: some View {
        List(matches, id: \.matchID) { match in
            VStack(alignment: .leading){
                Text("\(match.homeTeam) vs \(match.awayTeam)")
                    .font(.headline)
                if let score = match.score {
                    Text("Score: \(score)")
                }
            }
        }
        .onAppear {
            fetchRugbyMatches()
        }
    }
}


