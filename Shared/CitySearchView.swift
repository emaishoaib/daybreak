import MapKit
import SwiftUI
import WorldTimeKit

struct CitySearchView<Trailing: View>: View {
    let onPick: (Place) -> Void
    let trailing: Trailing

    @State private var search = CitySearch()
    @FocusState private var isFocused: Bool

    init(onPick: @escaping (Place) -> Void, @ViewBuilder trailing: () -> Trailing) {
        self.onPick = onPick
        self.trailing = trailing()
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Search for a city, country or time zone", text: $search.query)
                    .textFieldStyle(.roundedBorder)
                    .focused($isFocused)
                trailing
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            List {
                if !search.timeZones.isEmpty {
                    Section("Time zones") {
                        ForEach(search.timeZones) { place in
                            Button {
                                onPick(place)
                            } label: {
                                TimeZoneResult(place: place)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                ForEach(search.results, id: \.self) { completion in
                    Button {
                        Task {
                            guard let place = await search.place(for: completion) else { return }
                            onPick(place)
                        }
                    } label: {
                        CityResult(completion: completion)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .onAppear { isFocused = true }
    }
}

private struct CityResult: View {
    let completion: MKLocalSearchCompletion

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(completion.title)
            Text(completion.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

private struct TimeZoneResult: View {
    let place: Place

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(place.name)
            ResultSubtitle(detail: place.shortCode, timeZone: place.timeZone)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

private struct ResultSubtitle: View {
    let detail: String
    let timeZone: TimeZone?

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(text(at: context.date))
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func text(at date: Date) -> String {
        guard let timeZone else { return detail }
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = timeZone
        return [detail, date.formatted(style)].filter { !$0.isEmpty }.joined(separator: " · ")
    }
}
