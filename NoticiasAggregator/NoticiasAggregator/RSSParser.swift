//
//  RSSParser.swift
//  NoticiasAggregator
//
//  Created by admin on 1/7/26.
//

import Foundation

final class RSSParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentLink = ""
    private var currentGUID = ""
    private var currentPubDate = ""
    private var inItem = false

    private(set) var items: [FeedItem] = []
    private let sourceName: String

    init(sourceName: String) {
        self.sourceName = sourceName
    }

    func parse(data: Data) -> [FeedItem] {
        items = []
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    // MARK: - XMLParserDelegate

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName.lowercased()

        if currentElement == "item" {
            inItem = true
            currentTitle = ""
            currentLink = ""
            currentGUID = ""
            currentPubDate = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard inItem else { return }
        switch currentElement {
        case "title":   currentTitle += string
        case "link":    currentLink += string
        case "guid":    currentGUID += string
        case "pubdate": currentPubDate += string
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        let end = elementName.lowercased()
        if end == "item" {
            inItem = false

            let title = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
            let linkStr = currentLink.trimmingCharacters(in: .whitespacesAndNewlines)
            let guid = currentGUID.trimmingCharacters(in: .whitespacesAndNewlines)
            let pubDateStr = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)

            guard
                !title.isEmpty,
                let linkURL = URL(string: linkStr)
            else { return }

            let id = (!guid.isEmpty ? guid : linkStr)
            let pubDate = RSSDateParser.parse(pubDateStr)

            items.append(
                FeedItem(id: id, title: title, link: linkURL, pubDate: pubDate, sourceName: sourceName)
            )
        }
    }
}

enum RSSDateParser {
    // Common RSS date format: "Tue, 07 Jan 2026 12:34:56 +0000"
    private static let rfc822: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return df
    }()

    // Some feeds use single-digit day: "Tue, 7 Jan 2026 ..."
    private static let rfc822Alt: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
        return df
    }()

    static func parse(_ s: String) -> Date? {
        guard !s.isEmpty else { return nil }
        if let d = rfc822.date(from: s) { return d }
        if let d = rfc822Alt.date(from: s) { return d }
        return nil
    }
}
