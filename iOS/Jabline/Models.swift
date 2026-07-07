import Foundation

struct Vaccine: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var petName: String
    var vaccineName: String
    var dateGiven: Date = Date()
    var dueDate: Date?
}
