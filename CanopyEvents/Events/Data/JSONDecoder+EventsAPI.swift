import Foundation

nonisolated extension JSONDecoder {
    /// A decoder for the events API's answers. Its times are ISO 8601 with
    /// milliseconds (`2026-10-31T03:00:00.000Z`), which the stock `.iso8601`
    /// strategy refuses; this takes them with or without.
    static var eventsAPI: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) {
                return date
            }
            if let date = try? Date(text, strategy: Date.ISO8601FormatStyle()) {
                return date
            }
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath, debugDescription: "Not an ISO 8601 time: \(text)"
            ))
        }
        return decoder
    }
}
