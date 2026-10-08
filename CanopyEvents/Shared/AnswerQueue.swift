import Foundation

/// Answers from the notification extension, kept in the App Group until
/// the app applies them (it does when it next becomes active). The
/// extension runs in its own process and can't reach the app's data; for
/// real, it will send the answer to the API itself, and this queue goes.
/// The latest answer for an event wins.
nonisolated enum AnswerQueue {
    private static var file: URL? { AppGroup.container?.appending(path: "queued-answers.json") }

    static func add(_ answer: QueuedAnswer) {
        var answers = read().filter { $0.eventId != answer.eventId }
        answers.append(answer)
        write(answers)
    }

    /// Every waiting answer, oldest first, and the queue emptied.
    static func takeAll() -> [QueuedAnswer] {
        let answers = read()
        if !answers.isEmpty { write([]) }
        return answers.sorted { $0.answeredAt < $1.answeredAt }
    }

    private static func read() -> [QueuedAnswer] {
        guard let file, let data = try? Data(contentsOf: file) else { return [] }
        return (try? JSONDecoder.eventsAPI.decode([QueuedAnswer].self, from: data)) ?? []
    }

    private static func write(_ answers: [QueuedAnswer]) {
        guard let file, let data = try? JSONEncoder.eventsAPI.encode(answers) else { return }
        try? data.write(to: file, options: .atomic)
    }
}
