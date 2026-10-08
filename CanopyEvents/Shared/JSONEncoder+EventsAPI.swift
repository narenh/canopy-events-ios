import Foundation

nonisolated extension JSONEncoder {
    /// An encoder for request bodies to the events API: times as ISO 8601
    /// UTC with milliseconds, the way the API writes them.
    static var eventsAPI: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.formatted(Date.ISO8601FormatStyle(includingFractionalSeconds: true)))
        }
        return encoder
    }
}
