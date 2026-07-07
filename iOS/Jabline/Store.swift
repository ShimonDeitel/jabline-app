import Foundation
import Combine

final class JablineStore: ObservableObject {
    static let freeTierLimit = 20

    @Published var vaccines: [Vaccine] = [] { didSet { persist() } }

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("jablinestore.json")
        load()
    }

    var isAtFreeLimit: Bool { vaccines.count >= Self.freeTierLimit }

    func canAdd(isPro: Bool) -> Bool {
        isPro || vaccines.count < Self.freeTierLimit
    }

    func add(_ entry: Vaccine, isPro: Bool) -> Bool {
        guard canAdd(isPro: isPro) else { return false }
        vaccines.append(entry)
        return true
    }

    func remove(at offsets: IndexSet) {
        vaccines.remove(atOffsets: offsets)
    }

    func update(_ entry: Vaccine) {
        if let idx = vaccines.firstIndex(where: { $0.id == entry.id }) {
            vaccines[idx] = entry
        }
    }

    private func seedIfNeeded() {
        if vaccines.isEmpty {
            vaccines = [Self.sampleSeed]
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(PersistedState(vaccines: vaccines)) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            seedIfNeeded()
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let state = try? decoder.decode(PersistedState.self, from: data) {
            self.vaccines = state.vaccines
            
        }
        seedIfNeeded()
    }

    struct PersistedState: Codable {
        var vaccines: [Vaccine]
        
    }
    static let sampleSeed = Vaccine(petName: "Buddy", vaccineName: "Rabies", dateGiven: Date(), dueDate: Calendar.current.date(byAdding: .year, value: 1, to: Date()))
}
