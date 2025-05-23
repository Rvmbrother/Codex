import Foundation

struct Task: Identifiable {
    var id: Int
    var line: String
    var isTask: Bool
    var isDone: Bool
    let indent: Int
    var scheduledTime: Date? = nil
    var duration: TimeInterval? = nil
    var elapsed: TimeInterval = 0
    var timerStart: Date? = nil
    var actualStart: Date? = nil
    var actualEnd: Date? = nil

    var text: String {
        var t = line.replacingOccurrences(of: "[x]", with: "")
            .replacingOccurrences(of: "[ ]", with: "")
            .trimmingCharacters(in: .whitespaces)
        if let range = t.range(of: "\\{[^}]+\\}\\s*$", options: .regularExpression) {
            t.removeSubrange(range)
            t = t.trimmingCharacters(in: .whitespaces)
        }
        if t.hasPrefix("-") {
            t = String(t.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        return t
    }

    var remainingTime: TimeInterval? {
        guard let duration else { return nil }
        let running = timerStart.map { Date().timeIntervalSince($0) } ?? 0
        let total = elapsed + running
        return max(0, duration - total)
    }
}

struct TaskParser {
    static func load(from url: URL) -> [Task] {
        guard let data = try? String(contentsOf: url) else { return [] }
        let lines = data.split(separator: "\n", omittingEmptySubsequences: false)
        var tasks: [Task] = []
        for (index, line) in lines.enumerated() {
            let str = String(line)
            let isTask = str.contains("[ ]") || str.contains("[x]")
            let isDone = isTask && str.contains("[x]")
            let indent = str.prefix { $0 == " " || $0 == "\t" }.count
            let scheduled = parseTime(from: str)
            let duration = parseDuration(from: str)
            tasks.append(Task(id: index,
                              line: str,
                              isTask: isTask,
                              isDone: isDone,
                              indent: indent,
                              scheduledTime: scheduled,
                              duration: duration,
                              timerStart: nil,
                              actualStart: nil,
                              actualEnd: nil))
        }
        return tasks
    }

    static func parseTime(from line: String) -> Date? {
        let regex = try? NSRegularExpression(pattern: "@([0-9]{1,2}:[0-9]{2})")
        guard let match = regex?.firstMatch(in: line,
                                           range: NSRange(line.startIndex..<line.endIndex, in: line)),
              let range = Range(match.range(at: 1), in: line) else {
            return nil
        }
        let timeString = String(line[range])

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let baseTime = formatter.date(from: timeString) else {
            return nil
        }

        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: baseTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        return Calendar.current.date(from: components)
    }

    static func parseDuration(from line: String) -> TimeInterval? {
        let pattern = "\\{\\s*(?:([0-9]+)h)?\\s*(?:([0-9]+)m)?\\s*\\}\\s*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        guard let match = regex?.firstMatch(in: line,
                                           range: NSRange(line.startIndex..<line.endIndex, in: line)) else {
            return nil
        }
        var seconds = 0
        if let hrRange = Range(match.range(at: 1), in: line),
           let hrs = Int(line[hrRange]) {
            seconds += hrs * 3600
        }
        if let minRange = Range(match.range(at: 2), in: line),
           let mins = Int(line[minRange]) {
            seconds += mins * 60
        }
        return seconds > 0 ? TimeInterval(seconds) : nil
    }

    static func save(_ tasks: [Task], to url: URL) {
        let text = tasks.map { $0.line }.joined(separator: "\n")
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }
}
