import MapKit
import Observation
import WorldTimeKit

@MainActor
@Observable
final class CitySearch: NSObject {
    private(set) var results: [MKLocalSearchCompletion] = []

    var query = "" {
        didSet { completer.queryFragment = query }
    }

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = .address
        completer.addressFilter = MKAddressFilter(including: [.locality, .subAdministrativeArea, .administrativeArea, .country])
        completer.delegate = self
    }

    func place(for completion: MKLocalSearchCompletion) async -> Place? {
        let request = MKLocalSearch.Request(completion: completion)
        request.resultTypes = .address
        guard let item = try? await MKLocalSearch(request: request).start().mapItems.first,
              let timeZone = item.timeZone else { return nil }
        let coordinate = item.location.coordinate
        return Place(
            name: item.name ?? completion.title,
            timeZoneIdentifier: timeZone.identifier,
            coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }
}

extension CitySearch: @MainActor MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        results = []
    }
}
