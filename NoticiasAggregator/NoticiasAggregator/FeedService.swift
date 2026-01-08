//
//  FeedService.swift
//  NoticiasAggregator
//
//  Created by admin on 1/7/26.
//

import Foundation

actor FeedService {
    func fetchItems(for source: FeedSource) async throws -> [FeedItem] {
        var req = URLRequest(url: source.url)
        req.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }

        let parser = RSSParser(sourceName: source.name)
        return parser.parse(data: data)
    }

    func fetchAll(sources: [FeedSource]) async -> [FeedItem] {
        await withTaskGroup(of: [FeedItem].self) { group in
            for src in sources {
                group.addTask {
                    do {
                        return try await self.fetchItems(for: src)
                    } catch {
                        // Silently fail per-source (you could surface errors in UI later)
                        return []
                    }
                }
            }

            var combined: [FeedItem] = []
            for await batch in group { combined += batch }

            // De-dupe by id, keep newest if duplicates show up
            var byID: [String: FeedItem] = [:]
            for item in combined {
                if let existing = byID[item.id] {
                    if item.sortDate > existing.sortDate { byID[item.id] = item }
                } else {
                    byID[item.id] = item
                }
            }

            return byID.values.sorted { $0.sortDate > $1.sortDate }
        }
    }
}
