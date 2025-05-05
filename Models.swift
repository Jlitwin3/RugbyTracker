import Foundation

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