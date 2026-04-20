import Foundation

struct RosterResponse: Codable {
    let roster: [RosterEntry]
}

struct RosterEntry: Codable, Identifiable {
    let person: RosterPerson
    let jerseyNumber: String?
    let position: RosterPosition?

    var id: Int { person.id }
}

struct RosterPerson: Codable {
    let id: Int
    let fullName: String?
}

struct RosterPosition: Codable {
    let code: String?
    let name: String?
    let abbreviation: String?
}
