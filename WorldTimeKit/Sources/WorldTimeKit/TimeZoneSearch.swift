import Foundation

public enum TimeZoneSearch {
    private static let resultLimit = 5
    private static let replacedIdentifiers = ["UTC": "Etc/UTC"]

    public static func places(matching query: String, locale: Locale = .current) -> [Place] {
        let query = query.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return [] }
        let matches = TimeZone.abbreviationDictionary.compactMap { abbreviation, listedIdentifier -> (rank: Int, place: Place)? in
            let identifier = replacedIdentifiers[listedIdentifier] ?? listedIdentifier
            guard let name = TimeZone(identifier: identifier).flatMap({ name(of: $0, locale: locale) }),
                  let rank = rank(of: query, abbreviation: abbreviation, name: name) else { return nil }
            return (rank, Place(name: name, timeZoneIdentifier: identifier, coordinate: nil))
        }
        var seen = Set<String>()
        return Array(
            matches
                .sorted { ($0.rank, $0.place.name) < ($1.rank, $1.place.name) }
                .map(\.place)
                .filter { seen.insert($0.id).inserted }
                .prefix(resultLimit)
        )
    }

    private static func name(of timeZone: TimeZone, locale: Locale) -> String? {
        let generic = timeZone.localizedName(for: .generic, locale: locale)
        guard let generic, generic.contains(where: \.isNumber) else { return generic }
        return timeZone.localizedName(for: .standard, locale: locale) ?? generic
    }

    private static func rank(of query: String, abbreviation: String, name: String) -> Int? {
        if abbreviation.caseInsensitiveCompare(query) == .orderedSame { return 0 }
        if abbreviation.lowercased().hasPrefix(query.lowercased()) { return 1 }
        if name.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil { return 2 }
        return nil
    }
}
