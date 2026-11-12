import MapKit
import SwiftUI
import WorldTimeKit

struct CitySearchView: View {
    let onPick: (Place) -> Void

    @State private var search = CitySearch()
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            TextField("Search for a city or country", text: $search.query)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .padding(.horizontal, 16)
            List(search.results, id: \.self) { completion in
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
