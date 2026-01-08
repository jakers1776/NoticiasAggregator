//
//  ContentView.swift
//  NoticiasAggregator
//
//  Created by admin on 1/7/26.
//

import SwiftUI
import SafariServices

struct ContentView: View {
    private let sources: [FeedSource] = [
        .init(name: "La Opinión", url: URL(string: "https://laopinion.com/feed/")!),
        // Pick one El País feed (Portada). You can add more from their RSS directory.
        .init(name: "El País", url: URL(string: "https://feeds.elpais.com/mrss-s/pages/ep/site/elpais.com/portada")!),
        .init(name: "Univision", url: URL(string: "https://www.univision.com/noticias/feed")!)
    ]

    @State private var items: [FeedItem] = []
    @State private var isLoading = false
    @State private var selectedURL: URL?

    private let service = FeedService()

    var body: some View {
        NavigationStack {
            List(items) { item in
                Button {
                    selectedURL = item.link
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: 10) {
                            Text(item.sourceName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if let d = item.pubDate {
                                Text(d.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Noticias")
            .overlay {
                if isLoading && items.isEmpty {
                    ProgressView("Cargando…")
                }
            }
            .refreshable {
                await load()
            }
            .task {
                if items.isEmpty {
                    await load()
                }
            }
            .sheet(item: Binding(
                get: { selectedURL.map { IdentifiedURL(url: $0) } },
                set: { selectedURL = $0?.url }
            )) { identified in
                SafariView(url: identified.url)
            }
        }
    }

    private func load() async {
        isLoading = true
        let result = await service.fetchAll(sources: sources)
        items = result
        isLoading = false
    }
}

private struct IdentifiedURL: Identifiable {
    let id = UUID()
    let url: URL
}

private struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
