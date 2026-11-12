import CoreLocation
import WorldTimeKit

enum CurrentLocation {
    private static let timeout: Duration = .seconds(20)

    @MainActor
    static func coordinate() async -> Coordinate? {
        #if os(macOS)
        let manager = CLLocationManager()
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        defer { withExtendedLifetime(manager) {} }
        #else
        let session = CLServiceSession(authorization: .whenInUse)
        defer { session.invalidate() }
        #endif

        return await withTaskGroup(of: Coordinate?.self) { group in
            group.addTask { await firstCoordinate() }
            group.addTask {
                try? await Task.sleep(for: timeout)
                return nil
            }
            defer { group.cancelAll() }
            return await group.next() ?? nil
        }
    }

    private static func firstCoordinate() async -> Coordinate? {
        guard let updates = try? CLLocationUpdate.liveUpdates() else { return nil }
        do {
            for try await update in updates {
                if let location = update.location {
                    return Coordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                }
                if update.authorizationDenied || update.authorizationDeniedGlobally || update.authorizationRestricted {
                    return nil
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
