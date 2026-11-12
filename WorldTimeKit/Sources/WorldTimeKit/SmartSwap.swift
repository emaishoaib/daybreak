public struct SmartSwap: Equatable, Sendable {
    public private(set) var places: [Place]
    public private(set) var swappedOut: [String: Place]

    public init(places: [Place], swappedOut: [String: Place] = [:]) {
        self.places = places
        self.swappedOut = swappedOut
    }

    public mutating func travel(leaving left: Place, arrivingIn timeZoneIdentifier: String) {
        guard left.timeZoneIdentifier != timeZoneIdentifier else { return }
        let returning = swappedOut.removeValue(forKey: left.timeZoneIdentifier) ?? left

        if let index = places.firstIndex(where: { $0.timeZoneIdentifier == timeZoneIdentifier }) {
            swappedOut[timeZoneIdentifier] = places[index]
            places[index] = returning
            return
        }
        guard !places.contains(where: { $0.timeZoneIdentifier == returning.timeZoneIdentifier }) else { return }
        places.insert(returning, at: 0)
    }
}
