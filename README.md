# NoticiasAggregator

A lightweight iOS news aggregator app built with **SwiftUI** that combines headlines from Spanish-language news outlets and opens articles directly on the publisher’s website.

Currently supported sources:
- **La Opinión**
- **El País**
- **Univision**

The app uses official RSS feeds where available and does **not** copy or republish article content.

---

## Features

- Unified timeline of headlines from multiple news sources
- Pull-to-refresh
- De-duplicated articles
- Sorted by most recent publication date
- Opens articles using Apple’s `SFSafariViewController`
- No third-party dependencies

---

## Tech Stack

- Swift
- SwiftUI
- URLSession
- XMLParser (RSS)
- iOS 17+
- Xcode 15+

---

## Getting Started

### Prerequisites
- macOS with **Xcode** installed
- iOS Simulator or physical iPhone

### Installation
1. Clone the repository:
   ```bash
    git clone https://github.com/YOUR_USERNAME/NoticiasAggregator.git
2. Open the project in Xcode:
    open NoticiasAggregator.xcodeproj
3. Select a simulator or device
    
4. Press Run 
