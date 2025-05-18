import Foundation

struct Task: Identifiable {
    let id: Int
    var line: String
    var isTask: Bool
    var isDone: Bool

    var text: String {
        line.replacingOccurrences(of: "[x]", with: "")
            .replacingOccurrences(of: "[ ]", with: "")
            .replacingOccurrences(of: "-", with: "")
            .trimmingCharacters(in: .whitespaces)
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
            tasks.append(Task(id: index, line: str, isTask: isTask, isDone: isDone))
        }
        return tasks
    }

    static func save(_ tasks: [Task], to url: URL) {
        let text = tasks.map { $0.line }.joined(separator: "\n")
        try? text.write(to: url, atomically: true, encoding: .utf8)
    }
}
