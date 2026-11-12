import Foundation
import Observation
import SwiftUI
import WorldTimeKit

@MainActor
@Observable
final class ZoneList {
    private static let key = "zones"

    private(set) var places: [Place]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        places = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode([Place].self, from: $0) } ?? []
    }

    func add(_ place: Place) {
        guard !places.contains(where: { $0.id == place.id }) else { return }
        places.append(place)
        save()
    }

    func remove(_ place: Place) {
        places.removeAll { $0.id == place.id }
        save()
    }

    func remove(atOffsets offsets: IndexSet) {
        places.remove(atOffsets: offsets)
        save()
    }

    func move(fromOffsets source: IndexSet, toOffset destination: Int) {
        places.move(fromOffsets: source, toOffset: destination)
        save()
    }

    private func save() {
        defaults.set(try? JSONEncoder().encode(places), forKey: Self.key)
    }
}
