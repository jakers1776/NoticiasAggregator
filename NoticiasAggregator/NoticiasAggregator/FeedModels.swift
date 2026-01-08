//
//  FeedModels.swift
//  NoticiasAggregator
//
//  Created by admin on 1/7/26.
//

import Foundation

struct FeedSource: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let url: URL
}

struct FeedItem: Identifiable, Hashable {
    // Use a stable id for de-dupe (guid if present, else link)
    let id: String
    let title: String
    let link: URL
    let pubDate: Date?
    let sourceName: String
}

extension FeedItem {
    var sortDate: Date { pubDate ?? .distantPast }
}
