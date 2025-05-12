import Foundation

public struct League: Identifiable, Codable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct Team: Identifiable, Codable {
    public let id: Int
    public let name: String
    
    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct Player: Identifiable, Codable {
    public let id: Int
    public let name: String
    public let team: String?
    
    public init(id: Int, name: String, team: String?) {
        self.id = id
        self.name = name
        self.team = team
    }
} 