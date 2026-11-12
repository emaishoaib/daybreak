import Foundation
import Observation
import SwiftUI
import WorldTimeKit

@MainActor
@Observable
final class ZoneList {
    private static let key = "zones"
    private static let swappedOutKey = "swappedOut"
    private static let menuBarKey = "menuBarPlaces"

    private(set) var places: [Place]
    private var swappedOut: [String: Place]
    private(set) var menuBarIDs: Set<String>

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        places = defaults.data(forKey: Self.key).flatMap { try? JSONDecoder().decode([Place].self, from: $0) } ?? []
        swappedOut = defaults.data(forKey: Self.swappedOutKey).flatMap { try? JSONDecoder().decode([String: Place].self, from: $0) } ?? [:]
        menuBarIDs = Set(defaults.stringArray(forKey: Self.menuBarKey) ?? [])
    }

    var menuBarPlaces: [Place] {
        places.filter { menuBarIDs.contains($0.id) }
    }

    func isInMenuBar(_ place: Place) -> Bool {
        menuBarIDs.contains(place.id)
    }

    func toggleMenuBar(_ place: Place) {
        if menuBarIDs.remove(place.id) == nil {
            menuBarIDs.insert(place.id)
        }
        save()
    }

    func travel(leaving left: Place, arrivingIn timeZoneIdentifier: String) {
        var swap = SmartSwap(places: places, swappedOut: swappedOut)
        swap.travel(leaving: left, arrivingIn: timeZoneIdentifier)
        places = swap.places
        swappedOut = swap.swappedOut
        save()
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
        defaults.set(try? JSONEncoder().encode(swappedOut), forKey: Self.swappedOutKey)
        menuBarIDs.formIntersection(places.map(\.id))
        defaults.set(Array(menuBarIDs), forKey: Self.menuBarKey)
    }
}
