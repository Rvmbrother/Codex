import Foundation

struct Task {
    var line: String
    var isDone: Bool
    var index: Int
}

struct TaskParser {
    static func load(from url: URL) -> [Task] {
        guard let content = try? String(contentsOf: url) else { return [] }
        var tasks: [Task] = []
        for (i, line) in content.components(separatedBy: .newlines).enumerated() {
            if line.contains("[ ]") {
                tasks.append(Task(line: line, isDone: false, index: i))
            } else if line.contains("[x]") {
                tasks.append(Task(line: line, isDone: true, index: i))
            }
        }
        return tasks
    }
}
